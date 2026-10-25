---
description: Close a task — run checks, update docs, list files, propose a commit message
---

1. Run the parse check: `tools/check_parse.sh` (or `tools\check_parse.bat` on Windows). Paste the real output.
2. Run all tests: `tools/run_tests.sh` (or `.bat`). Paste the real output. If a check could not run, say so explicitly — never claim it passed.
3. If the data validator exists (`tools/validate_data.gd`), run it and paste the output.
4. Update `docs/API_INDEX.md` for every public method/signal you added or changed, and `docs/PROGRESS.md` (done / in progress / known issues / next up).
5. List every file you created or modified. Confirm none are outside the task's ALLOW_LIST.
6. Give me a one-line commit message. Do not run `git commit` or `git push` yourself.
