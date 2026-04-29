#!/usr/bin/env python3
"""Filter stdin → stdout: redact patterns that commonly indicate secrets in hook/tool output.

Patterns align with docs/security/sensitive-content-handling.md. Prefer false positives
over emitting probable credentials in SessionStart / transcript surfaces."""

from __future__ import annotations

import re
import sys

# Order matters: broader patterns after specific ones where relevant.
_PATTERNS: tuple[re.Pattern[str], ...] = (
    re.compile(r"(?i)bearer\s+[a-z0-9._~+/=-]+"),
    re.compile(
        r"eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*"
    ),  # JWT shape
    re.compile(r"\bsk-(?:live|test|proj|ant|svc)-[a-zA-Z0-9]{20,}"),
    re.compile(r"\bsk-[a-zA-Z0-9]{20,}"),
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(
        r"\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,24}\b"
    ),
)


def redact(text: str) -> str:
    out = text
    for pat in _PATTERNS:
        out = pat.sub("[REDACTED]", out)
    return out


def main() -> None:
    data = sys.stdin.read()
    try:
        sys.stdout.write(redact(data))
    except BrokenPipeError:
        sys.exit(0)


if __name__ == "__main__":
    main()
