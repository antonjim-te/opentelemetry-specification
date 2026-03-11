#!/usr/bin/env python3
"""Add a stable span specs link to generated traces registry READMEs."""

from __future__ import annotations

import pathlib
import sys

ATTRIBUTES_LINK = "- [Attributes](attributes/README.md)\n"
ENTITIES_LINK = "- [Entities](entities/README.md)\n"
SPAN_SPECS_LINK_LABEL = "Span Specs"


def span_specs_link(path: pathlib.Path) -> str:
    section_name = path.parent.name
    return f"- [{SPAN_SPECS_LINK_LABEL}]({section_name}-spans.md)\n"


def ensure_span_specs_link(path: pathlib.Path) -> bool:
    content = path.read_text(encoding="utf-8")
    has_entities_page = (path.parent / "entities" / "README.md").exists()
    specs_link = span_specs_link(path)

    lines = content.splitlines(keepends=True)
    new_lines = []
    seen_entities = False
    seen_specs = False

    for line in lines:
        if line == ENTITIES_LINK:
            if not has_entities_page or seen_entities:
                continue
            seen_entities = True
            new_lines.append(line)
            continue

        if line == specs_link:
            if seen_specs:
                continue
            seen_specs = True
            new_lines.append(line)
            continue

        new_lines.append(line)

    if not seen_specs:
        insertion_index = None

        if has_entities_page:
            for idx, line in enumerate(new_lines):
                if line == ENTITIES_LINK:
                    insertion_index = idx + 1
                    break

        if insertion_index is None:
            for idx, line in enumerate(new_lines):
                if line == ATTRIBUTES_LINK:
                    insertion_index = idx + 1
                    break

        if insertion_index is None:
            insertion_index = len(new_lines)
            if new_lines and new_lines[-1] != "\n":
                new_lines.append("\n")
                insertion_index = len(new_lines)

        new_lines[insertion_index:insertion_index] = [specs_link]

    new_content = "".join(new_lines)
    if new_content == content:
        return False

    path.write_text(new_content, encoding="utf-8")
    return True


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: link_span_specs_in_registry_readme.py <README.md> [<README.md> ...]")
        return 1

    for raw_path in argv[1:]:
        readme_path = pathlib.Path(raw_path)
        changed = ensure_span_specs_link(readme_path)
        status = "updated" if changed else "unchanged"
        print(f"{status}: {readme_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
