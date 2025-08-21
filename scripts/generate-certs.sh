#!/bin/bash

# setup.shからVIEW_URLを引数として受け取る
VIEW_URL=$1

# .envファイルから環境変数を読み込む
if [ -f .env ]; then
  export $(grep -E '^(VIEW_URL)' .env | xargs)
fi

# 証明書の出力ディレクトリ
CERTS_DIR="certs"
mkdir -p "${CERTS_DIR}"

# 証明書のファイル名
CERT_FILE="${CERTS_DIR}/${VIEW_URL}.crt"
KEY_FILE="${CERTS_DIR}/${VIEW_URL}.key"

# 証明書が既に存在する場合はスキップ
if [ -f "${CERT_FILE}" ] && [ -f "${KEY_FILE}" ]; then
  echo "SSL証明書は既に存在します: ${VIEW_URL}"
else
  echo "SSL証明書を生成します: ${VIEW_URL}"
  # opensslコマンドで自己署名証明書を生成
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${KEY_FILE}" \
    -out "${CERT_FILE}" \
    -subj "/C=JP/ST=Tokyo/L=Shinjuku/O=Local Development/OU=IT/CN=${VIEW_URL}"
  # 証明書をMacのキーチェーンに登録
  echo "▶ 証明書をMacのキーチェーンに登録します。管理者パスワードが必要です。"
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${CERT_FILE}"
  echo "✅ 証明書が登録されました。"
fi