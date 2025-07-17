# 入力値を取得
INPUT_TEXT="$SHORTCUT_INPUT"

# Notion APIでStatus: In progress & 最終更新が最新のページIDを取得
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

# ページが見つからなければ終了
if [ "$PAGE_ID" = "null" ] || [ -z "$PAGE_ID" ]; then
  echo "In progressなページが見つかりませんでした。"
  exit 1
fi

# 末尾に追記
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