#!/bin/bash

# --- 1. 必要なファイルをGitHubから直接ダウンロード ---
echo "▶ 必要なファイルをダウンロードしています..."
REPO_URL="https://raw.githubusercontent.com/rd-iwasaki/create-dev-environment/main"

# ダウンロード先のディレクトリを作成
mkdir -p certs src/scss src/js nginx/conf.d public/assets/css public/assets/js scripts php

# ファイルのリスト
declare -a FILES=(
    ".env.example"
    "docker-compose.yml"
    "vite.config.js"
    "nginx/conf.d/default.conf.template"
    "Dockerfile"
    "scripts/generate-certs.sh"
    "public/index.html"
    "src/js/main.js"
    "src/scss/style.scss"
)

# 各ファイルをダウンロード
for file in "${FILES[@]}"
do
    if [ ! -f "$file" ]; then
        curl -fsSL -o "$file" "${REPO_URL}/$file"
    fi
done
echo "✅ ファイルのダウンロードが完了しました。"

# --- 2. 必要なツールのチェック ---
echo "▶ 必要なツールのチェックを開始します..."
if ! command -v docker &> /dev/null; then
    echo "❌ Dockerが見つかりません。インストールしてください。"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.jsが見つかりません。インストールしてください。"
    exit 1
fi

# --- 3. .envファイルの作成 ---
if [ ! -f .env ]; then
    echo "▶ .envファイルを作成します。"

    # .env.exampleが存在しない場合、スクリプトを終了
    if [ ! -f .env.example ]; then
        echo "❌ .env.exampleファイルが見つかりません。スクリプトを終了します。"
        exit 1
    fi
    
    cp .env.example .env

    echo "✅ .envファイルを作成しました。続けて、このファイルを編集してください。"
    echo "編集が完了したら、保存してEnterキーを押してください..."
    
    # スクリプトを一時停止し、ユーザーの入力を待つ
    read -r -p "▶ "
fi

# .envファイルからVIEW_URLを読み込み
# -Eオプションで、=の前後の空白を無視して読み込む
export $(grep -v '^#' .env | xargs)
if [ -z "$VIEW_URL" ]; then
    echo "❌ .envファイルにVIEW_URLが設定されていません。"
    exit 1
fi

# --- 4. SSL証明書の自動生成と登録 ---
if [ "$SSL" == "true" ]; then
    echo "▶ SSL証明書を生成し、システムに登録します。"
    
    # generate-certs.shが存在しない場合、スクリプトを終了
    if [ ! -f ./scripts/generate-certs.sh ]; then
        echo "❌ ./scripts/generate-certs.shが見つかりません。スクリプトを終了します。"
        exit 1
    fi
    
    # 実行権限を付与してから実行
    chmod +x ./scripts/generate-certs.sh
    ./scripts/generate-certs.sh
fi

# --- 5. Dockerコンテナのビルドと起動 ---
echo "▶ Dockerコンテナをビルドし、起動します。"

# Dockerデスクトップアプリが起動しているか確認
if ! docker info &> /dev/null; then
    echo "❌ Dockerデスクトップアプリが起動していません。アプリケーションを起動してから再度スクリプトを実行してください。"
    exit 1
fi

docker-compose up --build -d

# --- 6. Node.jsパッケージのインストール ---
echo "▶ Node.jsパッケージをインストールします。"

# package.jsonが存在しない場合にnpm initを実行
if [ ! -f package.json ]; then
    echo "▶ package.jsonが見つかりません。新規作成します。"
    npm init -y > /dev/null
fi

# jqがインストールされているか確認
if ! command -v jq &> /dev/null; then
    echo "❌ jqが見つかりません。インストールしてください (例: brew install jq)。"
    exit 1
fi

# jqを使ってscriptsセクションにdevとbuildスクリプトを追記
# --argjson でJSON文字列を渡し、.scriptsに追加する
jq --argjson new_scripts '{"dev": "vite", "build": "vite build"}' \
   '.scripts += $new_scripts' package.json > package.tmp.json && mv package.tmp.json package.json

# 依存パッケージのインストール
npm install vite sass jquery --save-dev

npm install vite sass jquery --save-dev

echo "✅ 環境構築が完了しました。"
echo "手動でhostsファイルに以下を追記してください:"
echo "127.0.0.1   $VIEW_URL"
echo ""
echo "その後、Viteを起動するには、npm run dev を実行してください。"
echo "ブラウザで https://$VIEW_URL にアクセスしてください。"