request_data="chat_config.json"
scphostname="scp.virtrudemos.com"
artifact="chat.us"

while getopts "h:d:a:" arg; do
  case $arg in
    d)
      request_data=${OPTARG}
      ;;
    h)
      scphostname=${OPTARG}
      ;;
    a)
      artifact=${OPTARG}
      ;;
  esac
done
echo "Saving configuration at https://${scphostname}/configuration/$artifact using payload ${request_data}"
source ./gettoken.sh
echo "Using access_token"
echo "$access_token"
curl -X POST https://$scphostname/configuration/$artifact \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json" \
  -d @$request_data -v