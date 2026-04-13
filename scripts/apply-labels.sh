#!/usr/bin/env bash
# ==============================================================================
# apply-labels.sh
# labels/core.yml の内容を gh CLI でリポジトリに反映する
#
# 使い方:
#   ./scripts/apply-labels.sh <owner>/<repo>
#
# 前提:
#   - gh auth login 済みであること
#   - python3 がインストールされていること
# ==============================================================================

set -euo pipefail

REPO="${1:-}"
LABELS_FILE="$(dirname "$0")/../labels/core.yml"

if [ -z "$REPO" ]; then
  echo "Usage: $0 <owner>/<repo>"
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI がインストールされていません"
  echo "  brew install gh  でインストールしてください"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 がインストールされていません"
  exit 1
fi

echo "🏷️  ラベルを $REPO に反映します..."
echo ""

# YAMLをパースして gh label create を実行
python3 - "$LABELS_FILE" "$REPO" <<'PYTHON'
import sys
import yaml
import subprocess

labels_file = sys.argv[1]
repo = sys.argv[2]

with open(labels_file) as f:
    labels = yaml.safe_load(f)

for label in labels:
    name = label.get("name", "")
    color = label.get("color", "")
    description = label.get("description", "")

    if not name:
        continue

    cmd = [
        "gh", "label", "create", name,
        "--color", color,
        "--description", description,
        "--repo", repo,
        "--force",  # 既存ラベルも上書き更新
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        print(f"  ✅ {name}")
    else:
        print(f"  ❌ {name}: {result.stderr.strip()}")

print("")
print("完了しました。")
PYTHON
