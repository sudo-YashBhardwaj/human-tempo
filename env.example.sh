# Template: copy to env.sh (gitignored), point these three paths at a large local disk, then: source env.sh
export HT_DATA=/path/to/large-disk/human-tempo
export XDG_CACHE_HOME=/path/to/large-disk/.cache
export UV_PROJECT_ENVIRONMENT=/path/to/large-disk/venvs/human-tempo

# Every cache lives under XDG_CACHE_HOME so nothing lands on the home quota.
export HF_HOME="$XDG_CACHE_HOME/huggingface"
export UV_CACHE_DIR="$XDG_CACHE_HOME/uv"
export PIP_CACHE_DIR="$XDG_CACHE_HOME/pip"
export TORCH_HOME="$XDG_CACHE_HOME/torch"
export TRITON_CACHE_DIR="$XDG_CACHE_HOME/triton"
export MPLCONFIGDIR="$XDG_CACHE_HOME/matplotlib"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv/ComputeCache"
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv/GLCache"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/pycache"
export RUFF_CACHE_DIR="$XDG_CACHE_HOME/ruff"
export PYTEST_ADDOPTS="-o cache_dir=$XDG_CACHE_HOME/pytest"
# Let both default under HF_HOME; TRANSFORMERS_CACHE is deprecated and splits model downloads.
unset TRANSFORMERS_CACHE HF_DATASETS_CACHE

export MUJOCO_GL=egl
export PYOPENGL_PLATFORM=egl
# NVIDIA only: a broken GPU path must fail, not fall back to Mesa's software renderer.
export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json

source "$UV_PROJECT_ENVIRONMENT/bin/activate"
