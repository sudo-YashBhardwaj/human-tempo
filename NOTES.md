# NOTES

## 2026-10-05: machine survey and scaffold
- Surveyed sole.polytechnique.fr read-only; the facts that matter are in CLAUDE.md under Machine. Hugging Face download speed: 548 MB in 5.1 s (~107 MB/s) to /dev/null.
- Headless EGL: a ctypes probe with DISPLAY unset created an OpenGL 4.6 context on the RTX 3090 through EGL device 0. Unrestricted, glvnd also lists two Mesa devices (one fails with /dev/dri permission warnings, one is llvmpipe). With __EGL_VENDOR_LIBRARY_FILENAMES set to 10_nvidia.json only the NVIDIA device remains, so env.sh sets it.
- Video: h264_nvenc encodes; av1_nvenc fails (exit 187, "Invalid argument"); av1_cuvid decodes a libaom-av1 test stream (10 of 10 frames).
- SLURM: sole is a node of partition SallesInfo (2 h limit, cgroup-constrained, no GPU GRES). It was idle with no jobs.
- Scaffold: package, layout folders, MIT license, env.example.sh (env.sh stays local), CLAUDE.md. Git: repo-local identity, origin switched to SSH.
- Venv bootstrap (CPython 3.12.10 managed by uv):

      uv venv /Data/yash.bhardwaj/venvs/human-tempo --python 3.12
      source env.sh
      uv pip compile pyproject.toml --group dev -o requirements.lock
      uv pip sync requirements.lock && uv pip install --no-deps -e .

  Use uv pip, not uv sync or uv run: those resolve into their own uv.lock and ignore requirements.lock.
- Checks: ruff check passed; ruff format --check passed (2 files); pytest collected 0 items (exit 5), as there is no code to test yet.
- Cache check: after the install and the checks, no file under ~ changed outside the repo and the editor/agent directories; ruff, pytest and bytecode caches went to /Data/yash.bhardwaj/.cache.
