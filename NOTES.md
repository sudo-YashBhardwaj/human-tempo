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

## 2026-10-05: LeRobot/LIBERO trial (reverted), detached jobs
- Tried LeRobot 0.6.1 with the libero and smolvla extras plus mujoco==3.3.7: uv pip compile pinned 163 packages (torch 2.11.0+cu130, transformers 5.5.4, hf-libero 0.1.4, robosuite 1.4.0, robomimic 0.2.0). It installed, torch ran on the RTX 3090, and a LIBERO-Goal reset and step rendered both 256x256 cameras on EGL. The trial (code, venv, data and caches) was then reverted; the next step rebuilds the environment with uv sync.
- LIBERO traps for that rebuild:
  - ~/.libero/config.yaml already exists on this account and points to /Data/yash.bhardwaj/LIBERO, which does not exist on sole. Point LIBERO_CONFIG_PATH at a fresh directory; hf-libero then asks an interactive question on first import (answering N writes the default config).
  - hf-libero downloads its assets (lerobot/libero-assets, 422 MB, 586 files) to ~/.cache/libero/assets, on the home quota, unless libero/libero/assets exists inside the installed package.
- Video: torchcodec 0.11.1 failed to load because the system FFmpeg 7.1 has no libavdevice.so.61; LeRobot then falls back to pyav after printing the whole traceback. PyAV 15.1.0 bundles FFmpeg 7.1 with SVT-AV1 and dav1d.
- lerobot-eval, read from the 0.6.1 source: LiberoProcessorStep rotates both images 180 degrees and builds the 8-D state [eef_pos, axis-angle, gripper qpos]; the eval env renders 360x360 unless told otherwise, while lerobot/libero is 256x256; output_dir defaults to outputs/eval inside the repo.
- lerobot/libero (revision a1aaacb) labels its fps as 10, while LIBERO controls at 20 Hz. "put the bowl on the plate" is task_index 10 there and task 8 of the libero_goal suite.
- Official checkpoint HuggingFaceVLA/smolvla_libero (revision 6721902) on task 8, one episode per official init state: 41/50 successes (82%), 115 s of evaluation. Not yet reproducible from the repo: the eval script was reverted with the trial. Command, run in the trial's environment:

      lerobot-eval --policy.path=HuggingFaceVLA/smolvla_libero --policy.n_action_steps=10 \
          --env.type=libero --env.task=libero_goal '--env.task_ids=[8]' --env.fps=20 \
          --env.observation_height=256 --env.observation_width=256 \
          --eval.n_episodes=50 --eval.batch_size=10 --seed=1000 \
          --rename_map='{"observation.images.image": "observation.images.image", "observation.images.image2": "observation.images.image2"}' \
          --output_dir=$HT_DATA/eval/smolvla_libero_official

- Long jobs: Claude's shell has job control on, so setsid forks and a saved $! names a parent that exits at once. scripts/detach.sh has the job write its own PID, which equals its process group. Tested: a Python job logged its output live and ended with "exit 0"; a two-process job survived the launching shell, and kill -- -$(cat <job>.pid) stopped all four processes; a reused job name is refused.
- CLAUDE.md now builds the venv with uv sync from uv.lock (scripts/setup.sh, next step), superseding the uv pip bootstrap above; requirements.lock stays until then.
- Removed the .gitkeep placeholders; folders appear with their first real file. Until the first test lands, pytest warns that testpaths (tests/) matches nothing and exits 5.
