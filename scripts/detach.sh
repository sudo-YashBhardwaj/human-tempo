#!/usr/bin/env bash
# Start a long job in its own session so a dropped remote connection cannot kill it.
# Usage: scripts/detach.sh <job> <command...>
set -euo pipefail
if (($# < 2)); then
    echo "usage: $0 <job> <command...>" >&2
    exit 2
fi
job=$1
shift
if [[ ! $job =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "job name must match [A-Za-z0-9._-]+, got: $job" >&2
    exit 2
fi

source "$(dirname "$0")/../env.sh"
logs="$HT_DATA/logs"
log="$logs/$job.log"
pid="$logs/$job.pid"
for f in "$log" "$pid"; do
    if [[ -e $f ]]; then
        echo "$f already exists; choose another job name" >&2
        exit 1
    fi
done
mkdir -p "$logs"

# $! is unreliable when setsid has to fork, so the job writes its own PID; as session
# leader that PID is also its process group. Unbuffered Python keeps the log current.
PYTHONUNBUFFERED=1 setsid nohup bash -c '
    echo $$ > "$1"
    shift
    echo "[detach] $(date "+%F %T") start in $PWD: $(printf "%q " "$@")"
    "$@"
    status=$?
    echo "[detach] $(date "+%F %T") exit $status"
    exit $status
' detach "$pid" "$@" > "$log" 2>&1 < /dev/null &

for _ in {1..50}; do
    [[ -s $pid ]] && break
    sleep 0.1
done
if [[ ! -s $pid ]]; then
    echo "job did not record its PID; see $log" >&2
    exit 1
fi
echo "log: $log"
echo "pid: $pid ($(cat "$pid"))"
