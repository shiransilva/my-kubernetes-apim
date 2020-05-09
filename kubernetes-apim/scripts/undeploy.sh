

ECHO=`which echo`
KUBECTL=`which kubectl`

# methods
function echoBold () {
    ${ECHO} $'\e[1m'"${1}"$'\e[0m'
}

# WSO2 APIM
echoBold 'Deleting WSO2 API Manager with Analytics deployment...'
${KUBECTL} delete -f ../apim/wso2apim-service.yaml
${KUBECTL} delete -f ../apim/wso2apim-deployment.yaml
sleep 1m

# delete the created Kubernetes Namespace
${KUBECTL} delete namespace wso2

# switch the context to default namespace
${KUBECTL} config set-context $(kubectl config current-context) --namespace=default

echoBold 'Finished'
