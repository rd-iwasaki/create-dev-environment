#!/bin/bash

set -euo pipefail

# 第1引数からVIEW_URLを受け取る
VIEW_URL=$1
if [ -z "$VIEW_URL" ]; then
  echo "❌ VIEW_URLが引数として渡されていません。" >&2
  exit 1
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

  # 一時的なOpenSSL設定ファイルを作成します。
  # macOS標準のOpenSSL (LibreSSL) は -extfile オプションをサポートしていないため、-config オプションで設定ファイルを渡します。
  cat > "${CERTS_DIR}/openssl.cnf" << EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no
[req_distinguished_name]
C = JP
ST = Tokyo
L = Shinjuku
O = Local Development
OU = IT
CN = ${VIEW_URL}
[v3_ca]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${VIEW_URL}
EOF

  # opensslコマンドで自己署名証明書を生成します。
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${KEY_FILE}" \
    -out "${CERT_FILE}" \
    -config "${CERTS_DIR}/openssl.cnf"
  # 証明書をMacのキーチェーンに登録
  echo "▶ 証明書をMacのキーチェーンに登録します。管理者パスワードが必要です。"
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${CERT_FILE}"
  echo "✅ 証明書が登録されました。"
fi