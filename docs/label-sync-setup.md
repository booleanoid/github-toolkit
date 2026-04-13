# 🏷️ ラベルを他のリポジトリに自動同期する（GitHub Actions）

このリポジトリのラベル定義を、他のプロジェクトに自動で同期する手順です。
一度セットアップすれば、`github-toolkit` のラベル定義が更新されるたびに、
対象リポジトリへ自動反映されます。

## 仕組みの概要

```
┌─────────────────────┐         ┌──────────────────────┐
│  github-toolkit     │         │  your-project        │
│  (このリポジトリ)    │         │  (適用先リポジトリ)   │
│                     │         │                      │
│  labels/core.yml    │◄────────┤  .github/workflows/  │
│  (配信元)            │  参照    │  label-sync.yml     │
│                     │         │  (週次で自動実行)     │
└─────────────────────┘         └──────────────────────┘
```

## セットアップ手順

### ステップ1: `github-toolkit` 側に再利用可能 Workflow を配置

このリポジトリ（`github-toolkit`）に以下のファイルを作成します。

**ファイルパス:** `.github/workflows/label-sync-reusable.yml`

```yaml
name: Label Sync (Reusable)

on:
  workflow_call:
    inputs:
      labels-url:
        description: "適用するラベル定義ファイルのURL"
        required: false
        type: string
        default: "https://raw.githubusercontent.com/<your-username>/github-toolkit/main/labels/core.yml"
      allow-added-labels:
        description: "既存ラベルを削除しない（既存プロジェクト移行時に推奨）"
        required: false
        type: boolean
        default: false

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Download labels file
        run: curl -sL "${{ inputs.labels-url }}" -o labels.yml

      - name: Sync labels
        run: |
          ARGS="--access-token ${{ secrets.GITHUB_TOKEN }} --labels labels.yml"
          if [ "${{ inputs.allow-added-labels }}" = "true" ]; then
            ARGS="$ARGS --allow-added-labels"
          fi
          npx github-label-sync $ARGS ${{ github.repository }}
```

> ⚠️ `<your-username>` を実際の GitHub ユーザー名/組織名に置き換えてください。

---

### ステップ2: 適用先リポジトリに呼び出し Workflow を配置

ラベルを同期したいリポジトリ（例: `your-project`）に以下のファイルを作成します。

**ファイルパス:** `.github/workflows/label-sync.yml`

```yaml
name: Sync Labels

on:
  # 手動実行可能
  workflow_dispatch:
  # 毎週月曜 9:00 JST（UTC 0:00）に自動実行
  schedule:
    - cron: "0 0 * * 1"

permissions:
  issues: write

jobs:
  sync:
    uses: <your-username>/github-toolkit/.github/workflows/label-sync-reusable.yml@main
    secrets: inherit
```

#### 既存プロジェクトに初めて導入する場合

既存ラベルを削除したくない場合は `allow-added-labels: true` を指定します:

```yaml
jobs:
  sync:
    uses: <your-username>/github-toolkit/.github/workflows/label-sync-reusable.yml@main
    with:
      allow-added-labels: true
    secrets: inherit
```

---

### ステップ3: 動作確認

適用先リポジトリの **Actions** タブから手動実行してみます。

1. GitHubの対象リポジトリを開く
2. **Actions** タブ → 左メニューの **Sync Labels** を選択
3. 右上の **Run workflow** ボタン → **Run workflow** で実行
4. 実行ログを確認して、エラーが出ていなければ成功
5. **Issues** タブ → **Labels** で反映されていることを確認

---

## 運用パターン

### シンプルな運用

全プロジェクトで共通のコアラベルを維持したい場合は、このシンプルな設定で十分です。

```yaml
jobs:
  sync:
    uses: <your-username>/github-toolkit/.github/workflows/label-sync-reusable.yml@main
    secrets: inherit
```

---

## トリガーの調整

### 実行タイミングの変更

`cron` 式で実行頻度を変えられます（時刻は UTC）:

| 頻度 | cron式 | 備考 |
|---|---|---|
| 毎週月曜 9:00 JST | `"0 0 * * 1"` | デフォルト |
| 毎日 9:00 JST | `"0 0 * * *"` | 頻繁に同期したい場合 |
| 毎月1日 9:00 JST | `"0 0 1 * *"` | 変更頻度が低い場合 |
| 手動実行のみ | `schedule` を削除 | 完全手動運用 |

### `github-toolkit` 更新時の即時反映

`github-toolkit` の `labels/` が変更されたら即座に全リポジトリに配信したい場合は、
`repository_dispatch` を使った高度な設定が可能です（別途解説）。

---

## トラブルシューティング

### ❌ `Resource not accessible by integration`

**原因:** Workflow にラベル操作権限がない

**対処:** 呼び出し側の Workflow に `permissions` を追加
```yaml
permissions:
  issues: write
```

### ❌ `Bad credentials`

**原因:** `GITHUB_TOKEN` が渡っていない

**対処:** 呼び出し側で `secrets: inherit` を指定しているか確認

### ❌ 既存ラベルが意図せず削除された

**原因:** `allow-added-labels: true` を付けていなかった

**対処:** GitHub の監査ログからは復元不可。事前に `--dry-run` でローカル確認してから運用開始するのが安全。初回は必ず `allow-added-labels: true` で導入する。

### ⚠️ ラベル変更のテストをしたい

本番適用前にローカルでドライランを推奨:

```bash
npx github-label-sync \
  --access-token $GITHUB_TOKEN \
  --labels https://raw.githubusercontent.com/<your-username>/github-toolkit/main/labels/core.yml \
  --dry-run \
  <owner>/<target-repo>
```

---

## よくある質問

**Q. `github-toolkit` のラベル定義を変更したら、適用先にいつ反映されますか？**
A. 次回の `schedule` 実行時、または手動実行時に反映されます。即時反映したい場合は対象リポジトリの Actions から手動実行してください。

**Q. Issue に付与済みのラベルは消えますか？**
A. 消えません。ラベルの色や説明が更新されるだけで、Issue との紐付けは維持されます。

**Q. 複数リポジトリに一括適用したい**
A. 各リポジトリに Workflow ファイルを配置する必要があります。組織単位で配布するには [GitHub の Organization テンプレート機能](https://docs.github.com/en/communities/creating-templates-for-your-repositories) や、セットアップスクリプトの利用を検討してください。

**Q. `main` ブランチ以外を参照したい**
A. 呼び出し側の `uses:` 行末の `@main` をブランチ名・タグ名・コミットSHAに変更します。本番運用では `@v1.0.0` のようなタグ固定を推奨します。