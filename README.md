# Notion Journal Mac Shortcut

Macのショートカットアプリから、NotionのJournalデータベース（Status: In progress, 最終更新が最新のページ）に一行テキストを追記するためのシェルスクリプトです。

## 特徴

- **Mac専用**（ショートカットアプリ＋シェルスクリプト）
- Notion API v1対応
- Statusプロパティが「status型」のデータベースに対応
- 入力した一行を、In progressかつ最終更新が最新のページの末尾に自動追記

## 使い方

### 1. 事前準備

- [Notionインテグレーション](https://www.notion.so/my-integrations)を作成し、**シークレットトークン**を取得
- Journalデータベースの**データベースID**を取得
- インテグレーションにデータベースのアクセス権を付与
- Macに[jq](https://stedolan.github.io/jq/)をインストール（`brew install jq`）

### 2. ショートカットの作成

1. **「テキストを要求」**アクションを追加（追記したい一行を入力）
2. **「シェルスクリプトを実行」**アクションを追加し、`shortcut.sh`の内容を貼り付け
   - 「入力を渡す方法」は「stdinへ」
   - Notionトークンはスクリプト内の`{YOUR_INTEGRATION_TOKEN}`に記入

### 3. スクリプト例

`shortcut.sh`:

```bash
INPUT_TEXT="$SHORTCUT_INPUT"

PAGE_ID=$(curl -s -X POST "https://api.notion.com/v1/databases/130a58238daa809884c0ed1d6338ca32/query" \
  -H "Authorization: Bearer {YOUR_INTEGRATION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  --data '{
    "filter": {
      "property": "Status",
      "status": {
        "equals": "In progress"
      }
    },
    "sorts": [
      {
        "property": "Last edited time",
        "direction": "descending"
      }
    ],
    "page_size": 1
  }' | jq -r '.results[0].id')

if [ "$PAGE_ID" = "null" ] || [ -z "$PAGE_ID" ]; then
  echo "In progressなページが見つかりませんでした。"
  exit 1
fi

curl -s -X PATCH "https://api.notion.com/v1/blocks/$PAGE_ID/children" \
  -H "Authorization: Bearer {YOUR_INTEGRATION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  --data "{
    \"children\": [
      {
        \"object\": \"block\",
        \"type\": \"paragraph\",
        \"paragraph\": {
          \"rich_text\": [
            {
              \"type\": \"text\",
              \"text\": {
                \"content\": \"$INPUT_TEXT\"
              }
            }
          ]
        }
      }
    ]
  }"
```

### 4. 注意事項

- **Mac専用**です（iPhone/iPadのショートカットでは動作しません）
- Notion APIの仕様変更により動作しなくなる場合があります
- セキュリティのため、トークンの管理にはご注意ください

## ライセンス

MIT License

---

## 貢献

バグ報告・改善提案はIssueまたはPull Requestで歓迎します！