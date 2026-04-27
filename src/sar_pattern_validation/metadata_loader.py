"""
Companion `*.meta.json` loader for measured / reference SAR CSVs.

Per MGD 2026-04-24 feedback (slide 8): support a DASY/cSAR3D-style convention
where a CSV `<stem>.csv` is paired with a metadata file `<stem>.meta.json`.
Both files are linked by name and auto-loaded together. Manual entry of the
same parameters remains supported and overrides the metadata.

Schema (v1)
-----------
- `schema_version`: literal "1.0"
- `frequency_hz`: float > 0
- `power_level_dbm`: float (the dBm reference of the measurement)
- `measurement_area_x_mm`: float, > 22, ≤ 600 (matches WorkflowConfigSchema)
- `measurement_area_y_mm`: float, > 22, ≤ 400
- `noise_floor_wkg`: optional, > 0 and ≤ 0.1
- `distance_mm`: optional, ≥ 0 (probe / phantom distance, free-form metadata)
- `averaging_mass_g`: optional ("1g" / "10g" — kept as freeform string)
- `instrument`: optional ("DASY" / "cSAR3D" / etc.)
- `notes`: optional free-form

Unknown fields are rejected (extra="forbid") so we catch typos early. Invalid
files raise MetadataFormatError; UI-side surfacing as a Task 6.6 warning is
expected to wrap the exception.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, ValidationError

from sar_pattern_validation.errors import MetadataFormatError

META_FILE_SUFFIX = ".meta.json"
SCHEMA_VERSION = "1.0"


class MeasurementMetadata(BaseModel):
    model_config = ConfigDict(extra="forbid")

    schema_version: Literal["1.0"] = SCHEMA_VERSION
    frequency_hz: float = Field(gt=0)
    power_level_dbm: float
    measurement_area_x_mm: float = Field(gt=22.0, le=600.0)
    measurement_area_y_mm: float = Field(gt=22.0, le=400.0)
    noise_floor_wkg: float | None = Field(default=None, gt=0, le=0.1)
    distance_mm: float | None = Field(default=None, ge=0)
    averaging_mass_g: str | None = None
    instrument: str | None = None
    notes: str | None = None

    def to_workflow_overrides(self) -> dict[str, Any]:
        """
        Return a dict of overrides suitable for merging into a raw workflow
        config dict. Keys correspond to WorkflowConfigSchema field names; only
        fields present in this metadata (non-None and applicable to the
        workflow) are included.
        """
        overrides: dict[str, Any] = {
            "power_level_dbm": self.power_level_dbm,
            "measurement_area_x_mm": self.measurement_area_x_mm,
            "measurement_area_y_mm": self.measurement_area_y_mm,
        }
        if self.noise_floor_wkg is not None:
            overrides["noise_floor"] = self.noise_floor_wkg
        return overrides


def companion_meta_path(csv_path: str | Path) -> Path:
    """Return the conventional `<stem>.meta.json` path for a given CSV path."""
    csv = Path(csv_path)
    return csv.with_name(csv.stem + META_FILE_SUFFIX)


def load_meta_for_csv(csv_path: str | Path) -> MeasurementMetadata | None:
    """
    Load and validate the companion `*.meta.json` for `csv_path`.

    Returns None when no companion file exists (manual entry path stays
    supported, no warning needed). Raises MetadataFormatError if the file
    exists but cannot be parsed or fails schema validation.
    """
    meta_path = companion_meta_path(csv_path)
    if not meta_path.is_file():
        return None

    try:
        raw = json.loads(meta_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise MetadataFormatError(
            f"Could not read or parse meta file: {meta_path}"
        ) from exc

    try:
        return MeasurementMetadata.model_validate(raw)
    except ValidationError as exc:
        raise MetadataFormatError(
            f"Meta file failed schema validation ({meta_path}): {exc}"
        ) from exc


def merge_meta_into_config(
    raw_config: dict[str, Any],
    meta: MeasurementMetadata,
) -> dict[str, Any]:
    """
    Return a copy of `raw_config` with metadata-derived defaults applied for
    keys that are absent or set to None in `raw_config`. Manual entries
    (anything explicitly set in raw_config) take precedence per the spec
    ("manual entry remains supported").
    """
    overrides = meta.to_workflow_overrides()
    merged = dict(raw_config)
    for key, value in overrides.items():
        if merged.get(key) is None:
            merged[key] = value
    return merged
