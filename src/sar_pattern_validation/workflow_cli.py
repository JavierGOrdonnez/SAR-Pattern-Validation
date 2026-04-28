from __future__ import annotations

import argparse
import json
import logging
import subprocess  # nosec B404
import sys
from dataclasses import asdict, is_dataclass
from pathlib import Path
from typing import Any

from sar_pattern_validation.workflows import (
    WorkflowResultCLIExcludedFields,
    complete_workflow,
)


def _serialize(obj: Any) -> Any:
    """
    Recursively convert objects into JSON-serializable structures.
    Handles:
      - dataclasses (excluding fields defined in WorkflowResultCLIExcludedFields)
      - pathlib.Path
      - nested dicts/lists
    """
    if is_dataclass(obj):
        excluded_fields = {field.value for field in WorkflowResultCLIExcludedFields}
        return {
            k: _serialize(v) for k, v in asdict(obj).items() if k not in excluded_fields
        }
    if isinstance(obj, Path):
        return str(obj)
    if isinstance(obj, dict):
        return {k: _serialize(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_serialize(v) for v in obj]
    return obj


def _configure_logging() -> None:
    """
    Ensure logs go to stderr (so stdout stays clean JSON).
    """
    logging.basicConfig(
        level=logging.INFO,
        stream=sys.stderr,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )


def _parse_report_args(args_list: list[str]) -> tuple[argparse.Namespace, list[str]]:
    """
    Extract report-generation args from argv, returning (report_ns, remaining_args).
    The remaining_args are passed unchanged to complete_workflow.
    """
    p = argparse.ArgumentParser(add_help=False)
    p.add_argument("--report_dir", type=str, default=None)
    p.add_argument("--report_antenna_type", type=str, default="dipole")
    p.add_argument("--report_frequency_mhz", type=int, default=0)
    p.add_argument("--report_distance_mm", type=int, default=0)
    p.add_argument("--report_mass_g", type=int, default=0)
    return p.parse_known_args(args_list)


def _build_config_for_report(remaining_args: list[str]):
    """Reconstruct a minimal WorkflowConfig from the workflow CLI args."""
    from sar_pattern_validation.workflow_config import WorkflowConfig

    p = argparse.ArgumentParser(add_help=False)
    p.add_argument("--measured_file_path", type=str, default="")
    p.add_argument("--reference_file_path", type=str, default="")
    p.add_argument("--power_level_dbm", type=float, default=0.0)
    p.add_argument("--noise_floor", type=float, default=0.01)
    ns, _ = p.parse_known_args(remaining_args)
    return WorkflowConfig(
        measured_file_path=ns.measured_file_path,
        reference_file_path=ns.reference_file_path,
        power_level_dbm=ns.power_level_dbm,
        noise_floor=ns.noise_floor,
    )


def main(argv: list[str] | None = None) -> int:
    """
    CLI entrypoint for sar-pattern-validation.

    - Parses CLI args (delegated to complete_workflow)
    - Runs workflow
    - Emits JSON result to stdout
    - Returns proper exit code

    Optional report generation args (stripped before passing to complete_workflow):
      --report_dir            Output directory for the LaTeX report
      --report_antenna_type   Antenna type string (default: "dipole")
      --report_frequency_mhz  Frequency in MHz (default: 0)
      --report_distance_mm    Distance in mm (default: 0)
      --report_mass_g         Averaging mass in g (default: 0)
    """
    _configure_logging()

    try:
        args_list = argv if argv is not None else sys.argv[1:]
        report_ns, remaining_args = _parse_report_args(args_list)

        result = complete_workflow(*remaining_args)

        payload: dict[str, Any] = {
            "status": "success",
            "result": _serialize(result),
        }

        if report_ns.report_dir:
            from sar_pattern_validation.report import generate_report

            config = _build_config_for_report(remaining_args)
            report_tex = generate_report(
                workflow_result=result,
                workflow_config=config,
                output_dir=report_ns.report_dir,
                antenna_type=report_ns.report_antenna_type,
                frequency_mhz=report_ns.report_frequency_mhz,
                distance_mm=report_ns.report_distance_mm,
                mass_g=report_ns.report_mass_g,
            )
            payload["report_tex_path"] = str(report_tex)
            payload["report_dir"] = str(report_tex.parent)

            # Compile LaTeX → PDF (run twice so cross-references resolve).
            # pdflatex is a trusted system binary invoked with a fixed argument list;
            # cwd is the report output directory we just created.
            pdf_path = report_tex.parent / "main.pdf"
            try:
                for _ in range(2):
                    subprocess.run(  # nosec B603 B607
                        ["pdflatex", "-interaction=nonstopmode", "main.tex"],
                        cwd=report_tex.parent,
                        capture_output=True,
                        timeout=60,
                    )
                if pdf_path.exists():
                    payload["report_pdf_path"] = str(pdf_path)
            except Exception:  # nosec B110
                pass  # PDF compilation is best-effort; .tex is always available

        print(json.dumps(payload, indent=2))
        return 0

    except Exception as exc:
        error_payload = {
            "status": "error",
            "error": {
                "type": type(exc).__name__,
                "message": str(exc),
            },
        }

        # Print error JSON to stdout (not stderr) so frontend can always parse stdout
        # Logs remain on stderr for debugging
        print(json.dumps(error_payload, indent=2))
        return 1


if __name__ == "__main__":
    sys.exit(main())
