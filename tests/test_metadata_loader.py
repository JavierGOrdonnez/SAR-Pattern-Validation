import json
from pathlib import Path

import pytest

from sar_pattern_validation.errors import MetadataFormatError
from sar_pattern_validation.metadata_loader import (
    MeasurementMetadata,
    companion_meta_path,
    load_meta_for_csv,
    merge_meta_into_config,
)


def _write_meta(path: Path, payload: dict) -> Path:
    path.write_text(json.dumps(payload), encoding="utf-8")
    return path


VALID_PAYLOAD = {
    "schema_version": "1.0",
    "frequency_hz": 9.0e8,
    "power_level_dbm": 10.0,
    "measurement_area_x_mm": 200.0,
    "measurement_area_y_mm": 150.0,
    "noise_floor_wkg": 0.05,
    "distance_mm": 15.0,
    "averaging_mass_g": "10g",
    "instrument": "DASY",
    "notes": "test fixture",
}


def test_companion_meta_path_uses_stem_plus_meta_json(tmp_path: Path) -> None:
    csv = tmp_path / "measurement.csv"
    assert companion_meta_path(csv) == tmp_path / "measurement.meta.json"


def test_load_meta_returns_none_when_no_companion(tmp_path: Path) -> None:
    csv = tmp_path / "measurement.csv"
    csv.write_text("x,y,sar\n0,0,1\n", encoding="utf-8")
    assert load_meta_for_csv(csv) is None


def test_load_meta_parses_valid_companion(tmp_path: Path) -> None:
    csv = tmp_path / "measurement.csv"
    csv.write_text("x,y,sar\n", encoding="utf-8")
    _write_meta(tmp_path / "measurement.meta.json", VALID_PAYLOAD)

    meta = load_meta_for_csv(csv)
    assert isinstance(meta, MeasurementMetadata)
    assert meta.frequency_hz == 9.0e8
    assert meta.measurement_area_x_mm == 200.0
    assert meta.averaging_mass_g == "10g"


def test_load_meta_rejects_invalid_json(tmp_path: Path) -> None:
    csv = tmp_path / "measurement.csv"
    csv.write_text("x,y,sar\n", encoding="utf-8")
    (tmp_path / "measurement.meta.json").write_text("{not json", encoding="utf-8")
    with pytest.raises(MetadataFormatError):
        load_meta_for_csv(csv)


def test_load_meta_rejects_unknown_schema_version(tmp_path: Path) -> None:
    csv = tmp_path / "measurement.csv"
    csv.write_text("x,y,sar\n", encoding="utf-8")
    payload = dict(VALID_PAYLOAD, schema_version="2.0")
    _write_meta(tmp_path / "measurement.meta.json", payload)
    with pytest.raises(MetadataFormatError):
        load_meta_for_csv(csv)


def test_load_meta_rejects_extra_fields(tmp_path: Path) -> None:
    csv = tmp_path / "measurement.csv"
    csv.write_text("x,y,sar\n", encoding="utf-8")
    payload = dict(VALID_PAYLOAD, unknown_typo_field=123)
    _write_meta(tmp_path / "measurement.meta.json", payload)
    with pytest.raises(MetadataFormatError):
        load_meta_for_csv(csv)


@pytest.mark.parametrize(
    "field,value",
    [
        ("measurement_area_x_mm", 22.0),  # at exclusive lower bound
        ("measurement_area_x_mm", 601.0),  # above max
        ("measurement_area_y_mm", 22.0),
        ("measurement_area_y_mm", 401.0),
        ("noise_floor_wkg", 0.5),  # above 0.1 max
        ("noise_floor_wkg", 0.0),  # below exclusive lower
        ("frequency_hz", -1.0),
    ],
)
def test_load_meta_rejects_out_of_range(
    tmp_path: Path, field: str, value: float
) -> None:
    csv = tmp_path / "measurement.csv"
    csv.write_text("x,y,sar\n", encoding="utf-8")
    payload = dict(VALID_PAYLOAD, **{field: value})
    _write_meta(tmp_path / "measurement.meta.json", payload)
    with pytest.raises(MetadataFormatError):
        load_meta_for_csv(csv)


def test_to_workflow_overrides_includes_optional_when_set() -> None:
    meta = MeasurementMetadata(**VALID_PAYLOAD)
    overrides = meta.to_workflow_overrides()
    assert overrides == {
        "power_level_dbm": 10.0,
        "measurement_area_x_mm": 200.0,
        "measurement_area_y_mm": 150.0,
        "noise_floor": 0.05,
    }


def test_to_workflow_overrides_skips_optional_when_unset() -> None:
    payload = dict(VALID_PAYLOAD)
    payload.pop("noise_floor_wkg")
    meta = MeasurementMetadata(**payload)
    overrides = meta.to_workflow_overrides()
    assert "noise_floor" not in overrides
    assert overrides["power_level_dbm"] == 10.0


def test_merge_meta_lets_manual_entry_take_precedence() -> None:
    raw = {"power_level_dbm": 30.0, "measurement_area_x_mm": None}
    meta = MeasurementMetadata(**VALID_PAYLOAD)
    merged = merge_meta_into_config(raw, meta)
    # Manual power_level_dbm preserved
    assert merged["power_level_dbm"] == 30.0
    # measurement_area_x_mm filled from meta because raw had None
    assert merged["measurement_area_x_mm"] == 200.0
    # raw not mutated
    assert raw == {"power_level_dbm": 30.0, "measurement_area_x_mm": None}
