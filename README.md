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

- 🏷️ **一貫性のあるラベル体系** — 6軸構成で Issue を多角的に分類
- 🔄 **他リポジトリへの自動同期** — GitHub Actions で労力ゼロの運用
- 📋 **Issue / PR テンプレート** — 起票ルールを仕組みで担保 *(予定)*
- ⚙️ **再利用可能な Workflows** — ラベル同期、自動アサインなど *(予定)*
- 📚 **運用ノウハウのドキュメント** — PM視点のベストプラクティス集

---

## 🚀 クイックスタート

### 1. ラベルを他のリポジトリに1コマンドで適用

```bash
# GitHub Personal Access Token を用意(repo権限)
export GITHUB_TOKEN=ghp_xxxxxxxxxxxx

# ラベル定義を適用
npx github-label-sync \
  --access-token $GITHUB_TOKEN \
  --labels https://raw.githubusercontent.com/<your-username>/github-toolkit/main/labels/core.yml \
  <owner>/<target-repo>
```

> 💡 初回は `--dry-run` を付けて事前確認を推奨します。

### 2. GitHub Actions で自動同期(推奨)

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
│   ├── core.yml                   # 全プロジェクト共通（6軸構成）
│   └── presets/
│       ├── web-app.yml            # Webアプリ向け拡張
│       ├── library.yml            # ライブラリ向け拡張
│       └── customer-support.yml   # サポート対応向け拡張
├── issue-templates/               # Issueテンプレート集(予定)
├── pr-templates/                  # PRテンプレート集(予定)
├── .github/workflows/
│   └── label-sync-reusable.yml    # ラベル同期用の再利用可能Workflow
├── project-templates/             # Projectsの設定例(予定)
└── docs/
    ├── labels.md                  # ラベル運用ガイド
    └── label-sync-setup.md        # 自動同期セットアップ手順
```

---

## 🏷️ ラベル体系の概要

**6軸構成**で Issue を多角的に分類できます。プレフィックス命名で検索性と視認性を両立。

| 軸 | プレフィックス | 役割 | 排他性 |
|---|---|---|---|
| Type | `type:` | 何の作業か(bug/feature/question等) | 1つだけ |
| Priority | `priority:` | 優先度(critical/high/medium/low) | 1つだけ |
| Status | `status:` | 現在の状態(triage/in-progress等) | 1つだけ |
| Estimate | `estimate:` | 作業量の見積もり(1/2/3/5/8/13pt) | 1つだけ |
| Area | `area:` | 技術領域(frontend/backend等) | 複数可 |
| Source | `source:` | 発生源(customer/internal等) | 複数可 |

### 使用例

```
type: bug + priority: high + status: in-progress + estimate: 3 + area: backend + source: customer
```

→「顧客から報告された、バックエンドの高優先度バグ。1日程度で対応中」が一目で分かる。

詳細な設計思想・アンチパターン・運用ルールは [docs/labels.md](./docs/labels.md) を参照。

---

## 📖 ドキュメント

| ドキュメント | 内容 |
|---|---|
| [labels.md](./docs/labels.md) | ラベル設計思想・使い方・アンチパターン集 |
| [label-sync-setup.md](./docs/label-sync-setup.md) | 他リポジトリへの自動同期セットアップ手順 |

---

## 📊 現在のステータス

| 機能 | ステータス |
|---|---|
| ラベル定義(core) | ✅ 利用可能 |
| ラベル定義(presets) | ✅ 利用可能(web-app / library / customer-support) |
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