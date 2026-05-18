# SAR Pattern Validation — Specification

## §G Goal

Recover UI polish + full measurement-validation toolbox from legacy dev branches onto `main-melanie`; regenerate all validation artifacts under current codebase; keep strict py3.9 Voila-frontend / uvx-py3.10+ backend separation throughout.

## §C Constraints

C1: Frontend (`notebooks/voila.ipynb`, `voila_frontend/ui.py`) runs in jupyter-math container → **python 3.9**. No walrus, no match-statement, no 3.10+ stdlib. All UI cherry-picks must pass `ty` type-check with py3.9 target.

C2: Backend (`workflows.py`, `plotting.py`, `report.py`, CLI) runs via **uvx python 3.10+**. Typing and language features at 3.10+ are fine there.

C3: Artifact regeneration runs against current `main-melanie` HEAD (not `develop` / legacy branches). Artifacts must be committed to LFS after regen.

C4: HTML report is pure Python (Jinja2 or stdlib string templates). No `pdflatex` runtime dependency for HTML path; LaTeX/PDF path stays as an optional CLI flag.

C5: LFS scope: measurement CSVs under `data/measurements/` and `data/database/`, artifact `.npz` under `tests/artifacts/`, plot PNGs under `tests/artifacts/measurement_validation/plots/`. All must remain LFS-tracked.

C6: The Voila UI must never re-run registration when only `power_level` changes between consecutive runs (same measured file, same reference, same noise_floor). Power rescaling must be instant (no button cycle). See V6 for the implementation contract.

C7: Adaptive noise floor for measurement validation — when `power_level_dbm ≤ 9`, use `noise_floor = 0.01 W/kg`; otherwise use `0.05 W/kg`. Rationale: at low-to-mid transmit power, SAR amplitudes are small enough that the 0.05 W/kg cutoff excludes too much valid signal and causes `MASK_TOO_SMALL` / `EMPTY_MEASURED_MASK` or inflated gamma failures. Threshold `LOW_POWER_THRESHOLD_DBM = 9`; implemented via `_case_noise_floor()` in `test_measurement_validation.py`.

## §MV Measurement Validation Overview

The measurement validation framework stress-tests the registration + gamma pipeline against real measured SAR data across multiple frequencies, power levels, distances, and averaging masses.

**Data sources**

| Pool | Location | Bands covered |
|------|----------|---------------|
| `BASELINE_CASES` | `data/measurements/D2450_*.csv` (compact format) | 2450 MHz, 10 mm, 1g/10g, 17 dBm, 9 pairs |
| `ROBUSTNESS_CASES` | hard-coded paths in test file | 900 / 1950 / 5800 MHz |
| `DISCOVERED_CASES` | auto-discovered from `data/measurements/` filesystem | all bands present on disk |

**File naming conventions** (two patterns coexist):

- Compact: `D{freq}_Flat_{dist}mm_{power}dBm_{mass}_{index}.csv` (e.g. `D2450_Flat_10mm_17dBm_1g_1.csv`)
- Spacey: `D{freq}_Flat HSL_{dist} mm_{power} dBm_{mass}_{index}.csv` (e.g. `D2450_Flat HSL_10 mm_17 dBm_1g_1.csv`)

`{freq}` may be a plain integer MHz (e.g. `2450`, `900`, `1950`) or `{N}GHz` notation (e.g. `5GHz` → 5800 MHz).

**Artifact layout**

```
tests/artifacts/measurement_validation/
  {frequency_key}/                  # e.g. 2450mhz, 900mhz, 5800mhz
    {power_level_key}/              # e.g. 17dbm, 10dbm
      {case_id}_metrics.json        # scalar metrics dict
      {case_id}.npz                 # gamma_map + evaluation_mask arrays
  plots/
    {case_id}/
      01_loader_comparison.png
      02_registered_measured.png
      02_registration_overlay.png
      03_gamma_map.png
```

Case IDs follow the pattern `{freq_mhz}_{dist}mm_{mass}_{power}dbm_{index}` (e.g. `2450_10mm_1g_17dbm_1`).

**Thresholds** used in `test_measurement_validation.py`:
- `dose_to_agreement = 10 %`, `distance_to_agreement = 3 mm`, `gamma_cap = 2.0`
- `noise_floor`: adaptive via C7 — `0.01 W/kg` when `power_level_dbm ≤ 9`, else `0.05 W/kg`
- **Pass criterion: 100 % gamma pass rate** (`failed_pixel_count == 0`). See V11.

**HTML report** (`generate_measurement_validation_report_html.py`): produced from artifact JSON files; filterable by band, power level, pass/fail. Default thresholds: `scaling_error < 10 %`, `gamma_pass_rate = 100 %`.

## §I Interface

I1: `complete_workflow(measured_file_path, reference_file_path, ...)` — runs full registration + gamma pipeline; returns `WorkflowResult` on success, raises `WorkflowExecutionError` with `.issue: ValidationIssue | None` on structured failures.

I2: `ValidationIssue.code` is a machine-readable string (e.g. `MASK_TOO_SMALL`, `EMPTY_MEASURED_MASK`, `CSV_FORMAT_ERROR`). The Voila UI surfaces `issue.message` in the error/warning banner.

I3: `noise_floor` (W/kg) is the SAR floor below which pixels are excluded from the metric mask. Range [0, 0.1]. Must satisfy `noise_floor < measured_peak` for registration to proceed.

I4 (planned): `generate_html_report(results: list[CaseResult], output_path: Path)` — renders filterable HTML table of all measurement-validation cases with pass/fail, gamma pass-rate, and inline thumbnail links.

## §V Invariants

V1: ∀ registration call → `fixed_mask` active pixel count ≥ 1, else raise `ValidationIssue(code="EMPTY_MEASURED_MASK")` before `Execute()`. Applies at `workflows.py` after `make_metric_masks()`.

V2: ∀ `WorkflowExecutionError` raised inside `_complete_workflow` → `.issue` is preserved through exception handlers (no re-wrapping by generic `except Exception` clause). Applied via `except WorkflowExecutionError: raise` as first handler.

V3: `_apply_roi_policy` in `workflows.py` must receive `measured_mask_u8` (SAR ≥ noise cutoff, built by `loader.make_metric_masks()`) as its `measured_mask_u8` arg — never `measured_support_u8` (boundary-only). Gamma eval mask must exclude sub-cutoff (noise-filtered) pixels. Fix: `workflows.py:311`.

V4: ∀ MASK_TOO_SMALL condition (pre-registration on `measured_mask_u8` or post-registration on `evaluator.evaluation_mask`) → raises `WorkflowExecutionError` with `severity="error"` and `code="MASK_TOO_SMALL"`; workflow stops at the first failing check. Pre-registration check fires before `Rigid2DRegistration.run()`.

V5: ∀ cherry-picked frontend commit → must not introduce any python ≥ 3.10 syntax or imports. CI `ty` check with `--python-version 3.9` is the enforcement gate.

V6: When `handle_button_click` detects that only `power_level` changed (same measured-file hash, same reference path, same noise_floor) and a prior `WorkflowResult` exists in memory → skip re-running registration; rescale psSAR via `_update_analytical_results(self.workflow_results)` with the new power level; set banner "Power level updated — results rescaled from prior run." with `severity="info"`. Button must NOT cycle. E2E gate: `test_same_session_rerun_updates_results_after_power_change` detects this by waiting for the unique banner text (not a button cycle).

V7: ∀ artifact regeneration run → artifacts are committed to LFS and the commit message references the `main-melanie` HEAD hash used. Regen must not silently overwrite passing cases with failures without a §B backprop entry.

V8: ∀ E2E CI run → `notebooks/voila.ipynb` must execute in a Jupyter kernel without raising any exception before Playwright tests start. Verified by the `notebook_smoke`-marked pytest step in the `e2e-tests` CI job. Catches syntax errors, ImportErrors, and widget initialisation errors that otherwise surface only as Playwright timeouts.

V9: ∀ E2E Playwright locator targeting a number input by widget identity → must use label-anchored selector (`.widget-text` filtered by `label:has-text(...)`) not positional `nth()`. Positional indices shift whenever a new widget is added to the same DOM row.

V10: ∀ `_compute_case` call in `test_measurement_validation.py` → `noise_floor` must be set adaptively via `_case_noise_floor(case)`: `NOISE_FLOOR_LOW_POWER_WKG = 0.01 W/kg` if `case.power_level_dbm ≤ LOW_POWER_THRESHOLD_DBM = 9`, else `NOISE_FLOOR_WKG = 0.05 W/kg`. Artifact payload records the actual noise floor used.

V11: ∀ measurement validation case → the pass criterion is strictly 100 % gamma pass rate (`failed_pixel_count == 0`). Any failed pixel in the evaluated region is a test failure. Artifacts are not written for failing cases. The HTML report `gamma_pass_rate_threshold_pct` is a display/filter knob and must not be used to soften the per-case assertion.

## §T Tasks

Stream A — UI adjustments branch (`jgo/ui-adjustments` from `main-melanie`):

| ID | Status | Task | Cites |
|----|--------|------|-------|
| T1 | x | Create `jgo/ui-adjustments` from `main-melanie` HEAD | |
| T2 | x | Cherry-pick plotting renames + overlays from `develop`: `12cdd09` (Simulated→Reference title), `9746b05` (cropped-area dark-gray overlay + legend), `d24c9d8` (noise-floor medium-gray overlay all 6 panels) | C1,C2,V5 |
| T3 | x | Cherry-pick notebook layout from `develop`: `d774c11` (table below, center plots), `aed839e` (inline banner, swap tables, drop pass/fail button), `264c2d6` (stretch antenna grid to right-column height) | C1,V5 |
| T4 | x | Port boxed log widget + radio-button height limit from `86d7889` (`6.3-noise-floor`); verify py3.9 compat; test scrollable output widget in voila | C1,V5 |
| T5 | x | Run full test suite on `jgo/ui-adjustments`; fix any failures; open PR → `main-melanie` | V5 |

Stream B — Measurement validation toolbox (`main-melanie` direct or sub-branch):

| ID | Status | Task | Cites |
|----|--------|------|-------|
| T7 | x | Recover additional measurement CSVs (1950 / 5800 / 900 MHz bands) + `data/database/` reference CSVs from `develop` or "main"; verify LFS tracking | C5 |
| T8 | x | Extend `test_measurement_validation.py` with recovered bands; add `MeasurementValidationCase` entries for each new dataset | C2,C5 |
| T9 | x | Recover scripts to generate measurement validation HTML report by frequency band and various filtering | C2,C4,I4 |
| T10 | ~ | Regenerate all `tests/artifacts/measurement_validation/` (`.npz` + `_metrics.json` + plot PNGs) under `main-melanie` HEAD with `REGENERATE_MEASUREMENT_VALIDATION_ARTIFACTS=1 SAVE_MEASUREMENT_VALIDATION_PLOTS=1` | C3,C5,V7 |
| T11 | . | Run HTML report over regenerated artifacts; document which cases pass / fail / regress vs `develop` baseline; backprop any new failures via §B | V7,I4 |
| T12 | x | Implement adaptive noise floor in `_compute_case`: `noise_floor = 0.01` when `power_level_dbm ≤ 3`, else `0.05`; re-run T10 for affected cases | C7,V10 |

## §M Merge Log

Records every branch merged into `main-melanie`. Critical for squash-merge workflows: a squash-merge rewrites the tip hash, so once a PR is squash-merged the original branch tip listed here is the only reliable way to know what content was included.

| Date | Branch | Tip at merge | What it brought |
|------|--------|-------------|-----------------|
| 2026-05-15 | `jgo/6.6-validation-issue-channel` | `497c17c` | Task 6.6: `ValidationIssue` dataclass + `MASK_TOO_SMALL` / `CSV_FORMAT_ERROR` emit sites; notebook issues-aware banner; banner stdout fix + `status:error` guard; `MASK_TOO_SMALL` E2E test; backprop §B1–§B4, §V1–§V4 |
| 2026-05-15 | `jgo/m6-results-table` | `b84e9a8` | M6 Task 5: two-table results layout in Voila notebook; widget notation fix; CI Voila E2E timeout + dependency updates |
| 2026-05-17 | `jgo/ui-adjustments` | `ee0e493` | T2–T5: plotting renames + overlays (cropped-area + noise-floor), notebook layout (table below, inline banner, stretch grid), boxed log widget + radio-button height limit; power-level fast-path (V6); build backend → hatchling |
| 2026-05-17 | `port/6.2-measurement-area-inputs` | `9606cb5` | Measurement-area X/Y inputs in Voila UI + config validation (gt=22, le=600/400); plot canvas centering; notebook smoke test; label-anchored E2E selectors (V9); §V8–§V9, §B5–§B10 |

Branches already incorporated before this log began (via GitHub PRs, squash-merged onto `main` / `main-melanie`):

| PR | Commit on main-melanie | What it brought |
|----|----------------------|-----------------|
| #18 | `4514399` | Bump actions/checkout 4→6 |
| #17 | `28ede53` | Bump actions/upload-artifact 4→7 |
| #16 | `b44255c` | Update measurement-validation test artifacts after registration direction change |
| #15 | `7b3c702` | User-configurable noise floor input (0 ≤ noise_floor ≤ 0.1 W/kg) |
| #13 | `61c3454` | Task 6.5: inscribed 22×22 mm square mask validity check |
| #8  | `fd5e4c3` | Vectorise gamma; `--output-dir`; lock deps; lint+type CI job; GitLFS for E2E |
| #7  | `ad1595d` | Task 6.4: feedback banners |
| #6  | `ea30322` | Task 6.1: reverse registration direction (gamma in measured frame) |
| #5  | `cf15668` | Scan-for-buttons grid fix; parallel CI stages |
| #4  | `7e33b2a` | Voila E2E Playwright test suite |
| #3  | `69d2bb7` | Run on oSPARC compatibility |
| #1  | `cc77226` | Fix numerical errors in CI |

## §B Bug Log

| ID | Date | Root cause | Invariant |
|----|------|-----------|-----------|
| B1 | 2026-05-15 | `noise_floor ≥ measured peak` → empty fixed mask → `VirtualSampledPointSet must have 1 or more points` crash in SimpleITK, surfaced as raw ITK traceback in Voila banner | V1 |
| B2 | 2026-05-15 | `_complete_workflow` generic `except Exception` handler re-wrapped `WorkflowExecutionError` raised from inside the `try` block, discarding `.issue` | V2 |
| B3 | 2026-05-15 | `workflows.py:311` passes `measured_support_u8` (boundary-only) to `_apply_roi_policy` instead of `measured_mask_u8`; noise-filtered (SAR < cutoff) pixels included in gamma eval mask → inflated pass rate (Task 6.4) | V3 |
| B4 | 2026-05-15 | MASK_TOO_SMALL checked only post-registration; pre-registration noise-filtered `measured_mask_u8` never verified against `min_inscribed_square_mm` | V4 |
| B5 | 2026-05-15 | MASK_TOO_SMALL emitted as `severity="warning"` appended to `issues`, allowing workflow to complete; physically it is a hard validity gate — comparison on a sub-22mm mask is invalid | V4 |
| B6 | 2026-05-15 | `widgets.Layout(align_items="flex_start")` — underscore instead of CSS hyphen — caused voila to fail at startup; all E2E Playwright tests timed out rather than showing a useful error | V8 |
| B7 | 2026-05-16 | `84ae861` merge on `jgo/m6-results-table` silently dropped 5 noise_floor lines: method def (→ AttributeError), run-key entry (→ stale cache on floor change), `restore_state` read+set (→ lost on reload), `top_row` flex_item (→ widget invisible in UI) | V8 |
| B8 | 2026-05-16 | `_set_meas_area` and two upper-bound tests used `input[type='number'].nth(1/2)`; adding `noise_floor` widget to `top_row` (§B7 fix) shifted DOM order → inputs resolved to wrong widget, values clamped to 0.1 max, tests timed out | V9 |
| B9 | 2026-05-16 | `test_workflow_produces_square_plots` unpacked `voila_server` as 2-tuple (`_, workspace_root`) but fixture yields 3-tuple; raised `ValueError: too many values to unpack` | — |
| B10 | 2026-05-16 | `84ae861` merge dropped `measurement_area_row` from `left_setup_section` in `create_ui`; `measurement_area_x/y` widgets were defined but never added to the DOM → Playwright locators timed out finding them | V9 |
