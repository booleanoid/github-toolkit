# 🧰 github-toolkit

> GitHub プロジェクト運用のためのラベル・テンプレート・Workflow 集
> Opinionated defaults for GitHub project management.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/<your-username>/github-toolkit?style=social)](https://github.com/<your-username>/github-toolkit)

GitHub リポジトリの運用をスマートにするための、**再利用可能な設定集**です。
ラベル体系、Issue テンプレート、PR テンプレート、GitHub Actions Workflow などを
一箇所にまとめ、複数プロジェクトへ一貫して適用できるようにしています。

---

## ✨ このリポジトリで得られるもの

- 🏷️ **一貫性のあるラベル体系** — 9つのコアラベルで Issue を分類
- 🔄 **他リポジトリへの自動同期** — GitHub Actions で労力ゼロの運用
- 📋 **Issue / PR テンプレート** — 起票ルールを仕組みで担保 *(予定)*
- ⚙️ **再利用可能な Workflows** — ラベル同期、自動アサインなど *(予定)*
- 📚 **運用ノウハウのドキュメント** — PM視点のベストプラクティス集

---

## 🚀 クイックスタート

### ⭐ gh CLI で即時反映（推奨）

PAT 不要。`gh` にログイン済みであればそのまま実行できます。

```bash
# このリポジトリをクローン
git clone https://github.com/<your-username>/github-toolkit.git
cd github-toolkit

# ラベルを反映（既存ラベルも上書き更新）
./scripts/apply-labels.sh <owner>/<target-repo>

# 例
./scripts/apply-labels.sh booleanoid/my-project
```

**前提条件:**
- `gh auth login` でログイン済みであること
- `python3` がインストールされていること（macOS 標準で入っています）

`labels/core.yml` を読み込んで全ラベルを反映します。既存ラベルは `--force` で上書き更新されます（削除はしません）。

---

### GitHub Actions で自動同期

ラベル定義の更新を複数リポジトリへ自動反映したい場合は、Workflow を使います。
適用先リポジトリに以下のファイルを配置するだけ:

```yaml
# .github/workflows/label-sync.yml
name: Sync Labels

on:
  workflow_dispatch:
  schedule:
    - cron: "0 0 * * 1"  # 毎週月曜 9:00 JST

jobs:
  sync:
    uses: <your-username>/github-toolkit/.github/workflows/label-sync-reusable.yml@main
    secrets: inherit
```

詳細は [docs/label-sync-setup.md](./docs/label-sync-setup.md) を参照。

---

## 📂 ディレクトリ構成

```
github-toolkit/
├── labels/                        # ラベル定義
│   └── core.yml                   # 9つのコアラベル定義
├── scripts/
│   └── apply-labels.sh            # gh CLI でラベルを即時反映するスクリプト
├── .github/workflows/
│   └── label-sync-reusable.yml    # ラベル同期用の再利用可能Workflow
└── docs/
    └── label-sync-setup.md        # 自動同期セットアップ手順
```

---

## 🏷️ ラベル体系の概要

9つのシンプルなコアラベルで Issue を分類します。

| ラベル | 色 | 用途 |
|---|---|---|
| bug | `d73a4a` (赤) | 不具合・バグ修正 |
| feature | `a2eeef` (青) | 新規開発・新機能追加 |
| enhancement | `84b6eb` (薄青) | 既存機能の改善・修正 |
| question | `d876e3` (紫) | 問い合わせ・質問対応 |
| investigation | `fbca04` (黄) | 調査タスク（原因究明、技術検証など） |
| refactor | `c5def5` (薄青) | リファクタリング（機能変更なし） |
| docs | `0075ca` (紺) | ドキュメント追加・修正 |
| chore | `cfd3d7` (灰) | 雑務・環境整備・依存更新など |
| estimate | `f9d0c4` (ピンク) | お見積り書の作成 |

各プロジェクトの必要に応じて、これらのラベルを組み合わせて利用できます。

---

## 📖 ドキュメント

| ドキュメント | 内容 |
|---|---|
| [label-sync-setup.md](./docs/label-sync-setup.md) | 他リポジトリへの自動同期セットアップ手順 |

---

## 📊 現在のステータス

| 機能 | ステータス |
|---|---|
| ラベル定義(core) | ✅ 利用可能 |
| ラベル同期 Workflow | ✅ 利用可能 |
| Issue テンプレート | 🚧 開発中 |
| PR テンプレート | 🚧 開発中 |
| Projects テンプレート | 📋 計画中 |
| 自動アサイン Workflow | 📋 計画中 |

---

## 🎯 設計思想

このリポジトリが大切にしている原則です。

### 1. Opinionated（意見を持つ）
「迷わないこと」を最優先にしています。中立的で全員に合う設定ではなく、
多くのプロジェクトで機能する**特定の運用スタイル**を提案します。

### 2. 組み合わせ可能（Composable）
コア定義 + プリセット のレイヤー構造。プロジェクトの性質に応じて
必要なものだけを足せるようになっています。

### 3. 運用知見を資産化（Knowledge as Code）
設定ファイルだけでなく、**なぜそうしたか**をドキュメントに残しています。
新メンバーのオンボーディングや、他チームへの展開で効きます。

### 4. 段階導入可能（Incremental Adoption）
既存プロジェクトにも `--allow-added-labels` で衝突なく導入できます。
「すべてを一度に」を強いません。

---

## 🤝 コントリビューション

改善提案・バグ報告・プリセット追加提案など、歓迎しています。

- 🐛 **バグや問題を見つけた** → [Issue](https://github.com/<your-username>/github-toolkit/issues/new) で報告
- 💡 **新しいプリセットの提案** → Issue でディスカッション後、PR歓迎
- 📝 **ドキュメント改善** → PR で直接送ってください

### 開発ワークフロー

1. Fork & clone
2. ブランチ作成(`feat/xxx` または `fix/xxx`)
3. 変更 & コミット(Conventional Commits 推奨)
4. PR 作成

---

## 📜 ライセンス

[MIT License](./LICENSE) — 自由に利用・改変・再配布してください。

---

## 🙏 謝辞・参考

このプロジェクトは以下のツール・アイデアの上に成り立っています。

- [github-label-sync](https://github.com/Financial-Times/github-label-sync) — Financial Timesによるラベル同期ツール
- [Conventional Commits](https://www.conventionalcommits.org/) — コミットメッセージの規約
- GitHub の[デフォルトラベル](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels#about-default-labels) — 色やネーミングの参考

---

<p align="center">
  Made with 🧰 for better GitHub project management.
</p>