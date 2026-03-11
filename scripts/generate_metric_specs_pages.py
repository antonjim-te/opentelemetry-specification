#!/usr/bin/env python3
"""Generate metric specs markdown pages with semconv snippets."""

from __future__ import annotations

import pathlib
import re
import sys

METRIC_ID_PATTERN = re.compile(r"^\s*-\s*id:\s*(metric\.[A-Za-z0-9_.-]+)\s*$")


def collect_metric_ids(metrics_yaml: pathlib.Path) -> list[str]:
    ids: list[str] = []
    for line in metrics_yaml.read_text(encoding="utf-8").splitlines():
        match = METRIC_ID_PATTERN.match(line)
        if match:
            ids.append(match.group(1))
    return ids


def build_page(target_file: pathlib.Path, metric_ids: list[str]) -> str:
    section_slug = target_file.stem.removesuffix("-metrics")
    lines = [
        f"# Semantic conventions for {section_slug} metrics",
        "",
        "This page documents metric semantic conventions for this ThousandEyes section.",
        "",
    ]

    for metric_id in metric_ids:
        lines.append(f"## `{metric_id}`")
        lines.append(f"<!-- semconv {metric_id} -->")
        lines.append("<!-- endsemconv -->")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def generate_one(registry_dir: pathlib.Path, target_file: pathlib.Path) -> bool:
    metric_ids = collect_metric_ids(registry_dir / "metrics.yaml")
    if not metric_ids:
        raise ValueError(f"No metric ids found in {registry_dir / 'metrics.yaml'}")

    target_file.parent.mkdir(parents=True, exist_ok=True)
    content = build_page(target_file, metric_ids)
    old_content = target_file.read_text(encoding="utf-8") if target_file.exists() else None

    if old_content == content:
        return False

    target_file.write_text(content, encoding="utf-8")
    return True


def main(argv: list[str]) -> int:
    if len(argv) < 3 or len(argv[1:]) % 2 != 0:
        print(
            "usage: generate_metric_specs_pages.py "
            "<registry_dir> <target_md> [<registry_dir> <target_md> ...]"
        )
        return 1

    pairs = list(zip(argv[1::2], argv[2::2]))
    for registry_raw, target_raw in pairs:
        registry_dir = pathlib.Path(registry_raw)
        target_file = pathlib.Path(target_raw)
        changed = generate_one(registry_dir, target_file)
        status = "updated" if changed else "unchanged"
        print(f"{status}: {target_file}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
