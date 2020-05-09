# my-kubernetes-apim
*This documentation is to deploy* 

  ## 1. Deploying API Manager In Kubernetes 
**Overview**

This development would require main steps ,
please follow the each step in details.

1.1 Install Prerequisites

1.2 Deploying WSO2 API Manager in Kubernetes

           
		      A. Creating a kubernetes Cluster in gcloud
	              B. Deploying WSO2 API Manager
	              C. Deploying NGINX Ingress 
	              D. Access Management Consoles

### Getting Started

### ***1.1 Install Prerequisites***

*In order to use WSO2 Kubernetes resources, you need an active WSO2 subscription. If you do not possess an active WSO2 subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription).*

    

-   Install gcloud-sdk
    

	-   [https://cloud.google.com/sdk/install](https://cloud.google.com/sdk/install)
    
    

-   gcloud components install kubectl (compatible with v1.10.0)
    
    
	-   [https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

		 ```
		curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl
		 ```
    

-   Install [](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) Git
    

	-   [https://git-scm.com/book/en/v2/Getting-Started-Installing-Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
    
-   Create a Google Cloud Platform [](https://console.cloud.google.com/projectselector/compute/instances) Project
    

	-   [https://cloud.google.com/resource-manager/docs/creating-managing-projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
  
**B.  Creating a kubernetes Cluster in gcloud**
    

Steps to create a kubernetes Cluster

1.  Visit the Google Kubernetes Engine menu in GCP Console.
    
2.  Click Create cluster.
    
3.  Choose the Standard cluster template and Customize the template with the necessary following fields

	-   Name: It must be unique within the project and the zone.
    
	-   [Zone and Region](https://cloud.google.com/compute/docs/regions-zones/#available) : choosing according to region
	-   node pool:choose the default nood pool and customized with necessary fields
	-   Cluster size: The number of nodes to create in the cluster. For this use case **number of nodes are 3.**
	-   Machine type: Compute Engine [machine type](https://cloud.google.com/compute/docs/machine-types) to use for the instances. Each machine type is billed differently. The default machine type is n1-standard-1. This should change to **n1-standard-4 15GB memory**.
	
**C.  Deploying WSO2 API Manager and Analytics**
 
 Clone [my-kubernetes-apim](https://github.com/shiransilva/my-kubernetes-apim.git) master Branch for the Kubernetes Resources.
 

Next connect to the Kubernetes cluster by Command-line access,follow the steps below to connect to the Kubernetes Cluster.
   
-  Navigate to Clusters under the Kubernetes Engine in gcloud UI
    
-   Select the specific cluster and Click on Connect and copy the Command-line access command and paste it in your local machine (Configure [kubectl](http://kubernetes.io/docs/user-guide/kubectl-overview/) command line access by running the following command: gcloud container clusters get-credentials <CLUSTER_NAME> --zone <ZONE> --project <PROJECT_NAME>)
    

-   Export your WSO2 Username and password as an environmental variable.
    
	```
	export username="< username >"
	export password="< password >"
	```
-   Execute deploy. sh  script in kubernetes-apim-2.6.x/pattern-1/scripts with Kubernetes cluster admin password(visit to your cluster in kubernetes Engine and click Show credentials ).

	 ```
	./deploy.sh --wu=$username--wp=$password--cap=<Kubernetes cluster admin password>
	```
	**Note:** this deploy .sh script will ,
	*create a namespace named  `wso2`  and a service account named  `wso2svc-account`, within the namespace  `wso2`.Then, switch the context to new `wso2` namespace.
Create a Kubernetes Secret to pull the required Docker images from  [`WSO2 Docker Registry`](https://docker.wso2.com/),
Create a Kubernetes service only within the Kubernetes cluster deployment.
Create Kubernetes ConfigMaps for passing WSO2 product configurations into the Kubernetes cluster.
Create Kubernetes Services and Deployments for WSO2 API Manager.
-   Check the status of the pod.
	```
	kubectl get pods -n wso2
	```
**D.  Deploying NGINX Ingress**
   ##### Deploy Kubernetes Ingress resource.
-   Execute nginx-deploy. sh in niginx with Kubernetes cluster admin password.
This will create NGINX Ingress Controller.
    
	```
	./nginx-deploy.sh --cap=<Kubernetes cluster admin password>
	```
**E.  Access Management Consoles.**
    
deployment will expose `wso2apim` and `wso2apim-gateway` hosts.

-   Obtain the external IP (EXTERNAL-IP) of the Ingress resources by listing down the Kubernetes Ingresses.
	```
	 kubectl get ing -n wso2
	```
-   Add the above host as an entry in /etc/hosts file as follows:
	```
	< EXTERNAL-IP > wso2apim
	< EXTERNAL-IP > wso2apim-gateway
	```
-   navigate to [https://wso2apim/carbon](https://wso2apim/carbon) , [https://wso2apim/publisher](https://wso2apim/publisher) and [https://wso2apim/store](https://wso2apim/store) from your browser.

	 **Note:**  sign in with **`admin/admin`** credentials.
