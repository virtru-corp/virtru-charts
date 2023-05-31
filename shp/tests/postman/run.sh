configsDir=$1
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
echo "Running postman collections from $scriptDir using data/env files in $configsDir"

for FILE in $scriptDir/*_collection.json
do
  fbname=$(basename "$FILE")
  name=$(echo $fbname |  cut -d'.' -f 1)
  evalCmd="newman run ${FILE} -e ${configsDir}/env.json -d ${configsDir}/${name}_data.json"
  echo $evalCmd
  eval $evalCmd
done
