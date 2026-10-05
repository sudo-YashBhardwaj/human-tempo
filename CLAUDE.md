# human-tempo

Phone videos of me putting a bowl on a plate become hundreds of physics-verified robot demos in LIBERO-Goal ("put the bowl on the plate"), which fine-tune SmolVLA.
- Question: what are a few minutes of my video worth against LIBERO's 50 teleop demos, on the official starts and under layout shift?
- Twist: can my own speed profile tell the robot where it may move faster than I did without failing?
- Deliverable: public GitHub repo with a README. Deadline Friday 9 October 2026, 23:59 BST.

## Engineering rules
- Minimal: the least code that does the job well. No speculative abstractions, unused options, dead or commented-out code.
- Readable: small functions, clear names, type hints, flat control flow. Comments explain why, never what.
- One source of truth: paths in env.sh, parameters in configs/*.yaml. Nothing defined twice.
- Units and frames in names: T_table_cam (4x4 homogeneous, metres), pos_m, yaw_rad.
- Fail loudly: assert shapes, frames and units. No bare except, no silent fallbacks.
- Reproducible: fixed seeds, pinned versions, every result produced by a written-down command.
- Verify, don't assume: run it and show real output before calling it done. Never invent numbers.
- Honest: report what was measured, failures included. No cherry-picking.
- No slop: no emojis, filler, hype or boilerplate in code, comments, commits or docs.
- Small commits with clear messages. Never commit data, videos, checkpoints, caches or secrets.

## Workflow
- Read the relevant existing code first. Extend it; don't duplicate it.
- For anything non-trivial, state a 3-5 line plan before writing code.
- Done means: it ran, the output was shown, ruff and pytest pass, NOTES.md has a dated entry, and it is committed.

## Layout
- human_tempo/: one module per pipeline stage
- configs/: YAML configs
- scripts/: thin shell entry points
- tests/: geometry and data-plumbing tests
- results/: small artifacts only (metrics, figures, GIFs)
- NOTES.md: dated lab notebook of what was tried, what worked, what failed
- Large files live under $HT_DATA, outside the repo.

## Environment
- source env.sh first. Python 3.12 venv; versions pinned in requirements.lock.
- MUJOCO_GL=egl, PYOPENGL_PLATFORM=egl. mujoco==3.3.7 (3.4+ breaks a LIBERO task).

## Known traps
- lerobot-eval with SmolVLA: always pass --policy.n_action_steps=10, --env.fps=20 and an explicit --rename_map.
- Generate demos at 20 Hz through LeRobot's LIBERO env wrapper, so keys, image orientation and action scaling match lerobot/libero.
- Never trust a task index alone; assert the task's language string.
- Delta actions: track waypoints closed-loop (recompute the delta to the target each step, clip to [-1, 1]). Never replay precomputed deltas open-loop.
- Anything published from my videos (GIFs, samples) has audio and metadata stripped.

## Machine
- sole.polytechnique.fr: AlmaLinux 9.8, Xeon w3-2435 (8 cores / 16 threads), 61 GiB RAM, one RTX 3090 (24 GiB, sm_86), driver 595.104.02 (CUDA 13.2).
- The GPU is power-capped at 130 W by the admins (stock 350 W), so expect lower throughput than a stock 3090. Only root can change it.
- Shared teaching-lab machine: others can log in at the console or over SSH, and it is a SLURM node (partition SallesInfo, 2 h job limit) where other users' jobs can take CPU and RAM. The GPU is not a SLURM resource. Check nvidia-smi and squeue -w sole before long runs.
- No root: never use sudo. Everything installs into the venv or under /Data.
- /Data is local NVMe (1 TB), shared with other students and not backed up; files untouched for 180 days are deleted. Push anything worth keeping to the Hugging Face Hub.
- Home (~) is NFS with a quota of 30 GB and 300k files; on 2026-10-05 about 19 GB and 237k files were used. No venvs, data or caches there; env.sh moves every cache to /Data.
- Headless EGL verified on 2026-10-05: EGL device 0 gives an OpenGL 4.6 context on the RTX 3090 with no X server. env.sh restricts glvnd to the NVIDIA vendor.
- ffmpeg: /usr/local/bin/ffmpeg is a static 9.0 build with libx264, libx265, libaom-av1 and NVENC H.264/HEVC, but no libsvtav1 or libdav1d. The system FFmpeg 7.1 libraries (/lib64/libavcodec.so.61) include SVT-AV1 and dav1d. The RTX 3090 cannot encode AV1 in hardware (av1_nvenc fails) but decodes it (av1_cuvid works).
- Paths, defined in env.sh: code ~/human-tempo; HT_DATA=/Data/yash.bhardwaj/human-tempo; HF_HOME=/Data/yash.bhardwaj/.cache/huggingface; venv /Data/yash.bhardwaj/venvs/human-tempo (UV_PROJECT_ENVIRONMENT, CPython 3.12.10); caches under /Data/yash.bhardwaj/.cache.
