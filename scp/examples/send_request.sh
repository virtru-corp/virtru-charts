request_data="access-pep-alice1234-C.json"
scphostname="scp.virtrudemos.com"
while getopts "h:d:" arg; do
  case $arg in
    h)
      request_data=${OPTARG}
      ;;
    h)
      scphostname=${OPTARG}
      ;;
  esac
done
echo "Requesting access-pep at ${scphostname} using payload ${request_data}"
source ./gettoken.sh
echo "Using access_token"
echo "$access_token"
curl -X POST -d @$request_data -H "Authorization: Bearer $access_token" https://$scphostname/access-pep/access -v