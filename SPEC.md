# SAR Pattern Validation — Specification

## §I Interface

I1: `complete_workflow(measured_file_path, reference_file_path, ...)` — runs full registration + gamma pipeline; returns `WorkflowResult` on success, raises `WorkflowExecutionError` with `.issue: ValidationIssue | None` on structured failures.

I2: `ValidationIssue.code` is a machine-readable string (e.g. `MASK_TOO_SMALL`, `EMPTY_MEASURED_MASK`, `CSV_FORMAT_ERROR`). The Voila UI surfaces `issue.message` in the error/warning banner.

I3: `noise_floor` (W/kg) is the SAR floor below which pixels are excluded from the metric mask. Range [0, 0.1]. Must satisfy `noise_floor < measured_peak` for registration to proceed.

## §V Invariants

V1: ∀ registration call → `fixed_mask` active pixel count ≥ 1, else raise `ValidationIssue(code="EMPTY_MEASURED_MASK")` before `Execute()`. Applies at `workflows.py` after `make_metric_masks()`.

V2: ∀ `WorkflowExecutionError` raised inside `_complete_workflow` → `.issue` is preserved through exception handlers (no re-wrapping by generic `except Exception` clause). Applied via `except WorkflowExecutionError: raise` as first handler.

V3: ∀ MASK_TOO_SMALL condition (pre-registration on `measured_mask_u8` or post-registration on `evaluator.evaluation_mask`) → raises `WorkflowExecutionError` with `severity="error"` and `code="MASK_TOO_SMALL"`; workflow stops at the first failing check. Pre-registration check fires before `Rigid2DRegistration.run()`.

V4: ∀ E2E CI run → `notebooks/voila.ipynb` must execute in a Jupyter kernel without raising any exception before Playwright tests start. Verified by the `notebook_smoke`-marked pytest step in the `e2e-tests` CI job. Catches syntax errors, ImportErrors, and widget initialisation errors that otherwise surface only as Playwright timeouts.

V5: ∀ E2E Playwright locator targeting a number input by widget identity → must use label-anchored selector (`.widget-text` filtered by `label:has-text(...)`) not positional `nth()`. Positional indices shift whenever a new widget is added to the same DOM row.

## §B Bug Log

| ID | Date | Root cause | Invariant |
|----|------|-----------|-----------|
| B1 | 2026-05-15 | `noise_floor ≥ measured peak` → empty fixed mask → `VirtualSampledPointSet must have 1 or more points` crash in SimpleITK, surfaced as raw ITK traceback in Voila banner | V1 |
| B2 | 2026-05-15 | `_complete_workflow` generic `except Exception` handler re-wrapped `WorkflowExecutionError` raised from inside the `try` block, discarding `.issue` | V2 |
| B3 | 2026-05-15 | MASK_TOO_SMALL checked only post-registration; pre-registration noise-filtered `measured_mask_u8` never verified against `min_inscribed_square_mm` | V3 |
| B4 | 2026-05-15 | MASK_TOO_SMALL emitted as `severity="warning"` appended to `issues`, allowing workflow to complete; physically it is a hard validity gate — comparison on a sub-22mm mask is invalid | V3 |
| B5 | 2026-05-15 | `widgets.Layout(align_items="flex_start")` — underscore instead of CSS hyphen — caused voila to fail at startup; all E2E Playwright tests timed out rather than showing a useful error | V4 |
| B6 | 2026-05-16 | `84ae861` merge on `jgo/m6-results-table` silently dropped 5 noise_floor lines: method def (→ AttributeError), run-key entry (→ stale cache on floor change), `restore_state` read+set (→ lost on reload), `top_row` flex_item (→ widget invisible in UI) | V4 |
| B7 | 2026-05-16 | `_set_meas_area` and two upper-bound tests used `input[type='number'].nth(1/2)`; adding `noise_floor` widget to `top_row` (§B6 fix) shifted DOM order → inputs resolved to wrong widget, values clamped to 0.1 max, tests timed out | V5 |
| B8 | 2026-05-16 | `test_workflow_produces_square_plots` unpacked `voila_server` as 2-tuple (`_, workspace_root`) but fixture yields 3-tuple; raised `ValueError: too many values to unpack` | — |
| B9 | 2026-05-16 | `84ae861` merge dropped `measurement_area_row` from `left_setup_section` in `create_ui`; `measurement_area_x/y` widgets were defined but never added to the DOM → Playwright locators timed out finding them | V5 |
