scphostname="scp.virtrudemos.com"
artifact="chat.us"
while getopts "h:a:" arg; do
  case $arg in
    h)
      scphostname=${OPTARG}
      ;;
    a)
      artifact=${OPTARG}
      ;;
  esac
done

curl -v https://$scphostname/configuration/$a \
  -H "Content-Type: application/json"