# Measurement Validation Test Suite

This document describes the measurement validation testing infrastructure and how to use it.

## Overview

The measurement validation test suite validates SAR (Specific Absorption Rate) pattern measurements against reference data using gamma-map analysis. Tests are organized by frequency for easier reporting and analysis.

## Test Organization

Tests are automatically grouped by frequency:
- `test_measurement_workflow_cases_900mhz_match_reference_artifacts`
- `test_measurement_workflow_cases_1950mhz_match_reference_artifacts`
- `test_measurement_workflow_cases_2450mhz_match_reference_artifacts`
- `test_measurement_workflow_cases_5800mhz_match_reference_artifacts`

Each frequency group contains multiple cases varying by:
- Distance (e.g., 10 mm, 15 mm, 25 mm)
- Averaging mass (1g, 10g)
- Power level (e.g., 1 dBm, 4 dBm, 10 dBm, 17 dBm, 20 dBm)

## Quick Usage

### Run tests for missing cases only (smart rerun)
```bash
python run_measurement_validation_tests.py
```
This will:
- Check which frequencies already have test artifacts
- Run only the tests for which artifacts are missing
- Generate a JSON report with aggregated results

### Force rerun specific frequencies
```bash
python run_measurement_validation_tests.py --rerun 5800mhz --rerun 2450mhz
```
This will run all 5800 MHz and 2450 MHz cases, regardless of existing artifacts.

### Regenerate all artifacts
```bash
python run_measurement_validation_tests.py --regenerate-artifacts
```
This will recompute all test cases and overwrite existing artifacts.

### Save visualization plots
```bash
python run_measurement_validation_tests.py --save-plots
```
This will save diagnostic plots (loader comparison, registration overlay, gamma maps) for each test case.

### Combine options
```bash
python run_measurement_validation_tests.py --rerun 5800mhz --save-plots
```

## Output Structure

### Artifacts Organization
Artifacts and logs are now organized by frequency:
```
tests/artifacts/measurement_validation/
├── 900mhz/
│   ├── case_id_metrics.json
│   └── case_id_gamma_field.npz
├── 1950mhz/
│   ├── case_id_metrics.json
│   └── case_id_gamma_field.npz
├── 2450mhz/
│   ├── case_id_metrics.json
│   └── case_id_gamma_field.npz
├── 5800mhz/
│   ├── case_id_metrics.json
│   └── case_id_gamma_field.npz
├── logs/
│   ├── 900mhz/
│   │   └── TIMESTAMP_testname_caseid.log
│   ├── 1950mhz/
│   │   └── ...
│   └── ...
└── plots/
    ├── 900mhz/
    │   └── caseid/
    │       ├── 01_loader_comparison.png
    │       ├── 02_registered_measured.png
    │       ├── 02_registration_overlay.png
    │       └── 03_gamma_map.png
    └── ...
```

### JSON Report
The test runner generates `tests/artifacts/measurement_validation/measurement_validation_report.json` with:
- Overall summary (total cases, pass/fail counts, aggregate pass rate)
- Per-frequency summaries and case details
- Run metadata (timestamp, duration, command-line args, platform info)

Example structure:
```json
{
  "schema_version": 1,
  "generated_at": "2026-04-09T...",
  "summary": {
    "case_count": 127,
    "passed_case_count": 111,
    "failed_case_count": 16,
    "frequency_count": 4,
    "aggregate_pass_rate_percent": 95.2
  },
  "frequencies": [
    {
      "frequency_key": "900mhz",
      "frequency_label": "900 MHz",
      "frequency_mhz": 900,
      "summary": {...},
      "case_ids": [...]
    }
  ],
  "cases": [
    {
      "case_id": "900_15mm_1g_10dbm_11",
      "status": "passed",
      "failed_pixel_count": 0,
      "pass_rate_percent": 100.0,
      ...
    }
  ],
  "run": {...}
}
```

## Generate HTML Dashboard

Generate the combined interactive dashboard from the per-frequency JSON reports:
```bash
python generate_and_open_measurement_validation_dashboard.py --no-open
```

Or run the HTML generator directly:
```bash
python generate_measurement_validation_report_html.py \
  --input-glob tests/artifacts/measurement_validation/reports/measurement_validation_report_*mhz.json \
  --output tests/artifacts/measurement_validation/reports/measurement_validation_dashboard.html
```

The dashboard is written to `tests/artifacts/measurement_validation/reports/measurement_validation_dashboard.html`.

The HTML dashboard shows:
- Summary cards with pass/fail statistics
- Color-coded results by frequency
- Detailed case tables with failure details
- Run metadata and metrics

Note: older notes may still refer to `tests/artifacts/measurement_validation/report.html`, but the current workflow writes the combined dashboard under `tests/artifacts/measurement_validation/reports/`.

## Case Naming

Cases follow the pattern: `{frequency}_{distance}mm_{mass}_{power}dbm_{index}`

Examples:
- `900_15mm_1g_10dbm_11` → 900 MHz, 15 mm distance, 1g averaging, 10 dBm power, index 11
- `2450_10mm_1g_17dbm_5` → 2450 MHz, 10 mm distance, 1g averaging, 17 dBm power, index 5
- `5800_10mm_10g_1dbm_22` → 5.8 GHz, 10 mm distance, 10g averaging, 1 dBm power, index 22

## Direct pytest Usage

You can also run tests directly with pytest:

```bash
# Run all tests
pytest tests/test_measurement_validation.py -v

# Run tests for a specific frequency
pytest tests/test_measurement_validation.py::test_measurement_workflow_cases_900mhz_match_reference_artifacts -v

# Run with regeneration
REGENERATE_MEASUREMENT_VALIDATION_ARTIFACTS=1 pytest tests/test_measurement_validation.py

# Run with specific marker
pytest tests/test_measurement_validation.py -m slow
```

## Notes

- Test cases are marked with `@pytest.mark.slow` and use xdist for parallel execution
- By default, only "missing" cases run (those without existing artifacts)
- Use `--regenerate-artifacts` to force recalculation
- Artifacts are organized by frequency for cleaner management
- Old artifacts with "zip_" prefix are automatically detected and migrated
- The JSON report is designed for both programmatic consumption and HTML visualization

## Milestone 6 — MGD 2026-04-24 feedback (changes affecting baselines)

Following [`Milestone 6 - Implement MGD Feedback - 2026-04-24`](https://github.com/JavierGOrdonnez/SAR-Pattern-Validation), the gamma comparison semantics changed in ways that affect every measurement-validation artifact. When upgrading past commit `4ed8d23` (Task 6.7), regenerate the artifacts:

```bash
REGENERATE_MEASUREMENT_VALIDATION_ARTIFACTS=1 \
  uv run pytest -n auto --dist loadscope tests/test_measurement_validation.py --run-slow
```

### What changed

- **Task 6.1 — Reversed registration direction.** The simulated (reference) sSAR is now registered onto the measured sSAR. Gamma is evaluated in the measured frame, so the failing region is visible in the original measurement coordinates. `WorkflowResult` carries the same fields, but `evaluated_pixel_count` and the spatial layout of `gamma_map` / `evaluation_mask` are now defined on the measured grid (different spacing / extent than the reference grid in many cases). The `GammaMapEvaluator` constructor argument was renamed `measured_to_reference_transform` → `reference_to_measured_transform` to match.
- **Task 6.4 — Noise-filtered pixels excluded from the evaluation mask.** The intersection ROI policy now uses the measured *metric* mask (≥ noise-floor cutoff) rather than the *support* mask (full grid). Pass-rate values may shift on cases where significant measured pixels sat below the cutoff; those pixels are no longer counted as evaluated.
- **Task 6.5 — Inscribed 22 × 22 mm square check.** `WorkflowResult` gained two fields: `min_inscribed_square_mm` (the threshold actually used, default 22 mm = 10 g cube face) and `mask_fits_min_inscribed_square` (boolean). When the inscribed square does not fit, the workflow logs a warning; UI surfacing through the warning channel is Task 6.6 (MEST).
- **Task 6.7 — `*.meta.json` companion files.** A measured CSV `<stem>.csv` may be paired with `<stem>.meta.json` carrying frequency, power, measurement area, and optional noise floor. See `src/sar_pattern_validation/metadata_loader.py` for the schema. Manual entry / explicit kwargs always override metadata-derived defaults.
- **Task 6.2 — Measurement area inputs.** `WorkflowConfig` gained `measurement_area_x_mm` and `measurement_area_y_mm` (must be set together; bounds `22 < x ≤ 600` and `22 < y ≤ 400`). When set, `plotting.window_mm` is derived as a centered square of side `max(x, y)` so the rectangular measurement region is inscribed.

### Baseline regeneration: empirical deltas

After running

```bash
REGENERATE_MEASUREMENT_VALIDATION_ARTIFACTS=1 \
  uv run pytest -n auto --dist loadscope tests/test_measurement_validation.py --run-slow
```

128 of 130 cases re-emitted artifacts successfully. The two failures are degenerate measurement cases that cannot be registered after the direction reversal because the measured grid has zero spacing on one axis (only one unique x value):

- `5800mhz/1dbm/5ghz_10mm_1g_1dbm_22` — no pre-existing baseline (was already an unevaluable case).
- `5800mhz/10dbm/5ghz_10mm_10g_10dbm_12` — had a pre-existing baseline; the same dataset now triggers `ITK ERROR: Zero-valued spacing` when used as the registration `fixed` image. Robust handling of degenerate spacing is in scope for [[Milestone 5 - Improving Robustness]] / [[Task 6.6]] (warning channel).

**Per-pixel evaluated counts dropped sharply across the suite** because Task 6.4 now uses the measured *metric* mask (≥ noise-floor cutoff) instead of the support mask. For low-power cases where the signal sits near the default 0.1 W/kg cutoff (`min(0.1, 2 × noise_floor)` with default `noise_floor=0.05`), the metric mask is sparse or empty:

- 900 MHz @ 10 dBm cases: `evaluated_pixel_count` collapsed from ~10 000–15 000 to **0** in every case. The measured SAR is essentially below the 0.1 W/kg cutoff for these low-power runs. These cases now log a `mask_fits_min_inscribed_square=False` warning (Task 6.5) and are effectively rejected as invalid.
- 900 MHz @ 20 dBm: ~75% reduction (e.g. 15 748 → 4 140), pass rates remain 100%.
- 1950 MHz @ 10 dBm: ~94% reduction (e.g. 8 772 → 542), pass rates 100%.
- 5800 MHz @ 10 dBm: ~92% reduction (e.g. 3 095 → 233), pass rates 100%.
- 5800 MHz @ 20 dBm: ~73% reduction (e.g. 5 369 → 1 417), pass rates 100%.

The reductions are the **expected consequence** of MGD's slide-6 instruction ("noise-filtered points must be excluded from the gamma mask"). For the cases that collapse to zero evaluated pixels, the proper fix is for the user to lower the noise floor via the new variable noise-floor input ([[Task 6.3 - Variable Noise Floor with Persistent History]], MEST scope) — the artifact regen reflects current default behavior at `noise_floor=0.05 W/kg`.

**No case regressed from passed → failed in terms of pass rate** within the cases that still have non-zero evaluated pixels.
