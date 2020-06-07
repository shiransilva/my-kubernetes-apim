set -e

ECHO=`which echo`
KUBECTL=`which kubectl`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script automates the installation of WSO2 EI Integrator Analytics Kubernetes resources\n"
    echoBold "Allowed arguments:\n"
    echoBold "-h | --help"
    echoBold "--wu | --wso2-username\t\tYour WSO2 username"
    echoBold "--wp | --wso2-password\t\tYour WSO2 password"
    echoBold "--cap | --cluster-admin-password\tKubernetes cluster admin password\n\n"
}

WSO2_SUBSCRIPTION_USERNAME=''
WSO2_SUBSCRIPTION_PASSWORD=''
ADMIN_PASSWORD=''

# capture named arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`

    case ${PARAM} in
        -h | --help)
            usage
            exit 1
            ;;
        --wu | --wso2-username)
           WSO2_SUBSCRIPTION_USERNAME=${VALUE}
            ;;
        --wp | --wso2-password)
           WSO2_SUBSCRIPTION_PASSWORD=${VALUE}
            ;;
        --cap | --cluster-admin-password)
            ADMIN_PASSWORD=${VALUE}
            ;;
        *)
            echoBold "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done

# create a new Kubernetes Namespace
${KUBECTL} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBECTL} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBECTL} config set-context $(${KUBECTL} config current-context) --namespace=wso2

# create a Kubernetes Secret for passing WSO2 Private Docker Registry credentials
${KUBECTL} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}
${KUBECTL} create secret generic cipher-pass --from-literal='password-tmp=wso2carbon'
# create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
${KUBECTL} create --username=admin --password=${ADMIN_PASSWORD} -f ../rbac/rbac.yaml

echoBold 'Creating ConfigMaps...'
${KUBECTL} create configmap apim-conf --from-file=../confs/apim/
${KUBECTL} create configmap apim-conf-bin --from-file=../confs/apim/bin/

#${KUBECTL} create configmap apim-drivers --from-file=../confs/drivers/
echoBold 'Executing Provisioner helm chart...'
helm install nfsp ../apim/nfs-server-provisioner-1.0.0.tgz

echoBold 'Deploying MYSQL...'
${KUBECTL} apply -f ../mysql/wso2apim-mysql-conf.yaml
${KUBECTL} apply -f ../mysql/wso2apim-mysql-deployment.yaml
${KUBECTL} create -f ../mysql/wso2apim-mysql-service.yaml

sleep 90s

echoBold 'Deploying WSO2 API Manager...'
${KUBECTL} apply -f ../apim/wso2apim-entrypoint.yaml
${KUBECTL} apply -f ../apim/wso2apim-pvc.yaml
${KUBECTL} apply -f ../apim/wso2apim-synapse-pvc.yaml
${KUBECTL} create -f ../apim/wso2apim-deployment.yaml --validate=false
${KUBECTL} create -f ../apim/wso2apim-service.yaml

sleep 10s

echoBold 'Deploying Ingresses...'
${KUBECTL} create -f ../ingresses/wso2apim-ingress.yaml
${KUBECTL} create -f ../ingresses/wso2apim-gateway-ingress.yaml

echoBold 'Finished'
