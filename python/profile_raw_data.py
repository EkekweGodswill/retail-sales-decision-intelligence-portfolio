"""Read-only pandas profile for the project's raw data layer."""

from __future__ import annotations

import json
import re
from pathlib import Path

import pandas as pd

RAW_DIR = Path(__file__).resolve().parents[1] / "data" / "raw"
DATE_NAME = re.compile(r"(?:date|start|end)$", re.IGNORECASE)
NUMERIC_NAME = re.compile(
    r"quantity|price|amount|cost|stock|percent|minimum|limit|rating|months|weight|year",
    re.IGNORECASE,
)


def date_profile(series: pd.Series) -> dict:
    values = series.dropna().astype(str).str.strip()
    pattern_counts = values.map(
        lambda v: "YYYY-MM-DD" if re.fullmatch(r"\d{4}-\d{2}-\d{2}", v)
        else "DD/MM/YYYY" if re.fullmatch(r"\d{2}/\d{2}/\d{4}", v)
        else "MM/DD/YYYY" if re.fullmatch(r"\d{2}/\d{2}/\d{4}", v)
        else "Other"
    ).value_counts().to_dict()
    parsed = pd.to_datetime(values, errors="coerce", format="mixed")
    return {
        "formats": pattern_counts,
        "invalid_count": int(parsed.isna().sum()),
        "min": None if parsed.dropna().empty else str(parsed.min().date()),
        "max": None if parsed.dropna().empty else str(parsed.max().date()),
    }


def numeric_profile(series: pd.Series) -> dict:
    converted = pd.to_numeric(series, errors="coerce")
    nonblank = series.notna() & series.astype(str).str.strip().ne("")
    invalid = int((nonblank & converted.isna()).sum())
    valid = converted.dropna()
    result = {"invalid_count": invalid}
    if not valid.empty:
        result.update({"min": float(valid.min()), "max": float(valid.max())})
        q1, q3 = valid.quantile([0.25, 0.75])
        iqr = q3 - q1
        if iqr > 0:
            low, high = q1 - 1.5 * iqr, q3 + 1.5 * iqr
            result["iqr_outlier_count"] = int(((valid < low) | (valid > high)).sum())
            result["iqr_bounds"] = [float(low), float(high)]
        else:
            result["iqr_outlier_count"] = 0
    return result


def profile_file(path: Path) -> dict:
    frame = pd.read_csv(path)
    columns = []
    for name in frame.columns:
        series = frame[name]
        item = {
            "name": name,
            "dtype": str(series.dtype),
            "missing": int(series.isna().sum()),
            "unique": int(series.nunique(dropna=True)),
        }
        if DATE_NAME.search(name):
            item["date"] = date_profile(series)
        if NUMERIC_NAME.search(name):
            item["numeric"] = numeric_profile(series)
        columns.append(item)
    return {
        "file": path.name,
        "rows": int(len(frame)),
        "columns": int(len(frame.columns)),
        "duplicate_rows": int(frame.duplicated().sum()),
        "possible_primary_keys": [
            name for name in frame.columns
            if frame[name].notna().all() and frame[name].nunique() == len(frame)
        ],
        "column_profile": columns,
    }


def main() -> None:
    files = sorted(RAW_DIR.glob("*.csv")) + sorted(RAW_DIR.glob("*.xls*"))
    profiles = [profile_file(p) for p in files]
    tables = {p.stem.replace("_data", ""): pd.read_csv(p) for p in files if p.suffix == ".csv"}
    orders = tables["orders"]
    items = tables["order_items"]
    promotions = tables["promotion"]
    returns = tables["order_returns"]
    line_totals = items.assign(line_total=items["quantity"] * items["unit_price"]).groupby("order_id")["line_total"].sum()
    comparable = orders[orders["order_id"].isin(line_totals.index)].copy()
    comparable["line_total"] = comparable["order_id"].map(line_totals)
    checks = {
        "orders_without_order_items": int((~orders["order_id"].isin(items["order_id"])).sum()),
        "order_items_with_unknown_order": int((~items["order_id"].isin(orders["order_id"])).sum()),
        "orders_with_item_totals_not_equal_to_total_amount": int(
            (comparable["line_total"].round(2) != comparable["total_amount"].round(2)).sum()
        ),
        "delivery_before_order": int((pd.to_datetime(orders["delivery_date"]) < pd.to_datetime(orders["order_date"])).sum()),
        "promotion_end_before_start": int(
            (pd.to_datetime(promotions["end_date"]) < pd.to_datetime(promotions["start_date"])).sum()
        ),
        "returns_with_unknown_order_item": int((~returns["order_items_id"].isin(items["order_item_id"])).sum()),
    }
    print(json.dumps({"raw_directory": str(RAW_DIR), "profiles": profiles, "relationship_checks": checks}, indent=2))


if __name__ == "__main__":
    main()
