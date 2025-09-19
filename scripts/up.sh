#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CMD="$1"
if [ -z "$CMD" ]; then
echo "Usage: $0 task2|task3|task4"
exit 1
fi

case "$CMD" in
task2)
cd "$ROOT_DIR/solutions/task2/mongo-sharding"
bash "scripts/mongo-init.sh"
;;
task3)
cd "$ROOT_DIR/solutions/task3/mongo-sharding-repl"
bash "scripts/mongo-init.sh"
;;
task4)
cd "$ROOT_DIR/solutions/task4/sharding-repl-cache"
bash "scripts/mongo-init.sh"
;;
*)
echo "Unknown target: $CMD"
exit 1
;;
esac