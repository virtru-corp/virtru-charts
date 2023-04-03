TOKEN_URL="https://scp.virtrudemos.com/auth/realms/tdf/protocol/openid-connect/token"
CLIENT_ID="access-pep-test";
CLIENT_SECRET="replace_me"

access_token=$(curl -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=$CLIENT_ID" -d "client_secret=$CLIENT_SECRET" -d "grant_type=client_credentials" $TOKEN_URL | jq -r .access_token)
echo "access_token = $access_token"
