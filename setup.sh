#!/bin/bash

# --- 1. 必要なファイルをGitHubから直接ダウンロード ---
echo "▶ 必要なファイルをダウンロードしています..."
REPO_URL="https://raw.githubusercontent.com/rd-iwasaki/create-dev-environment/main"

# ダウンロード先のディレクトリを作成
mkdir -p certs src/scss src/js nginx/conf.d public/assets/css public/assets/js scripts php

if [ ! -f .env.example ]; then
    curl -fsSL -o .env.example "${REPO_URL}/.env.example"
fi
if [ ! -f docker-compose.yml ]; then
    curl -fsSL -o docker-compose.yml "${REPO_URL}/docker-compose.yml"
fi
if [ ! -f docker-compose.yml ]; then
    curl -fsSL -o vite.config.js "${REPO_URL}/vite.config.js"
fi
if [ ! -f nginx/conf.d/default.conf ]; then
    curl -fsSL -o nginx/conf.d/default.conf "${REPO_URL}/nginx/conf.d/default.conf"
fi
if [ ! -f Dockerfile ]; then
    curl -fsSL -o Dockerfile "${REPO_URL}/Dockerfile"
fi
if [ ! -f scripts/generate-certs.sh ]; then
    curl -fsSL -o scripts/generate-certs.sh "${REPO_URL}/scripts/generate-certs.sh"
fi
if [ ! -f public/index.php ]; then
    curl -fsSL -o public/index.php "${REPO_URL}/public/index.php"
fi
if [ ! -f src/js/main.js ]; then
    curl -fsSL -o src/js/main.js "${REPO_URL}/src/js/main.js"
fi
if [ ! -f src/scss/style.scss ]; then
    curl -fsSL -o src/scss/style.scss "${REPO_URL}/src/scss/style.scss"
fi
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

# --- 4. SSL証明書の自動生成 ---
if [ "$SSL" == "true" ]; then
    echo "▶ SSL証明書を生成します。"
    
    # generate-certs.shが存在しない場合、スクリプトを終了
    if [ ! -f ./scripts/generate-certs.sh ]; then
        echo "❌ ./scripts/generate-certs.shが見つかりません。スクリプトを終了します。"
        exit 1
    fi
    
    ./scripts/generate-certs.sh
fi

# --- 5. Dockerコンテナのビルドと起動 ---
echo "▶ Dockerコンテナをビルドし、起動します。"
docker-compose up --build -d

# --- 6. Node.jsパッケージのインストール ---
echo "▶ Node.jsパッケージをインストールします。"
npm install

echo "✅ 環境構築が完了しました。"
echo "手動でhostsファイルに以下を追記してください:"
echo "127.0.0.1   $VIEW_URL"
echo ""
echo "その後、Viteを起動するには、npm run dev を実行してください。"
echo "ブラウザで https://$VIEW_URL にアクセスしてください。"