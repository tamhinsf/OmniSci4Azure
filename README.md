# Install OmniSci (MapD) on Microsoft Azure 

It's easy to deploy OmniSci (MapD) to Microsoft Azure! The Azure template on this page will install and configure OmniSci Community Edition (CE) onto a Linux virtual machine running CentOS 7.4 or Ubuntu 16.04-LTS. 
* CentOS 7.4 environments will make use of Yum packages 
* Ubuntu 16.04-LTS environments will be deployed in a Docker environment 
* GPU or CPU VM? It's up to you! Our installation process will detect the type of VM you've chosen and deploy OmniSci CE GPU or CPU based upon that. 

Let's get started! 

## Identify your working environment 
Identify an Azure Environment and User Account 

* You'll need an Azure account that has privileges to create and configure the Azure resources and services we've described 

Load the Azure Resource Manager template into the Azure Portal so you can enter the configuration parameters described below. You can click the "Deploy to Azure" link to begin this process.  Don't worry - nothing will be deployed until you agree.  The Visualize link will map out the resources associated with this deployment.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftamhinsf%2FOmniSci4Azure%2Fmaster%2Fazuredeploy.json" target="_blank"> <img alt="Deploy to Azure" src="http://azuredeploy.net/deploybutton.png"/> </a>&nbsp;&nbsp;
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Ftamhinsf%2FOmniSci4Azure%2Fmaster%2Fazuredeploy.json" target="_blank"> <img alt="Visualize" src="http://armviz.io/visualizebutton.png"/></a> 

New to Azure?  Here's a description of the fields in the template.

### Operating System, VM Series, and Data Disks
The OS Platform drop-down will let you select between CentOS 7.4 or Ubuntu 16.04-LTS
* CentOS 7.4 environments will make use of Yum packages 
* Ubuntu 16.04-LTS environments will be deployed in a Docker environment 

We've pre-selected the lowest-cost GPU-powered VM series available: Standard_NC6 
* Can't afford a GPU?  
  * No worries!  Remember, we'll automatically install the GPU or CPU version of OmniSci CE based on your VM selection.
* Deployment failures?  You may need to increase your vCPU quota as described here: 
  * https://docs.microsoft.com/en-us/azure/azure-supportability/resource-manager-core-quotas-request
* Make the VM Series you enter is available in the Azure region you target. 
  * GPU-powered VMs are not available in all Azure regions 
* Need help? The Azure VM Comparision website will show you the VMs available in a given region https://azureprice.net/ 

Azure supports data disks of up to 4TB (4095 GB). We've defaulted you to 512 GB. 
  * The number of data disks you can attach varies based on the VM series you select 
  * If you create multiple data disks, we'll consolidate them into a single RAID 0 partition 
  * We'll create a partition called /mapd-storage using your data disk configuration and configure OmniSci to make use of it

### Hostnames and Networking
Public IP DNS is the public-facing hostname of the machine. It must be unique to the Azure region you are deploying to. 

  * If you deploy to West US 2, for example, the fully-qualified hostname will be: your-hostname.westus2.cloudapp.azure.com 
    * Creatively challenged? 
      * Just leave it blank. We'll generate a unique one for you. You can change it later. 
    * Picking one yourself? 
      * Unfortunately, we're unable to determine if the value you enter is already being used at this time. 
      * We suggest you append the month, day, year to achieve uniqueness. For example: your-hostname-01012018 
      * After the machine has been created, you can go back and change it through the Azure Portal 
      
### Deployment and Connecting to the OmniSci VM

Before you deploy, you'll need to Agree to the terms and click Purchase to begin deployment. As a reminder, you're not actually paying to use this free template. However, the resources that you deploy and make use of will be billed to your subscription. 

* Once you've begun your deployment, you can remain in the Azure Portal or navigate away and come back. Either way, you'll receive a notification in the Azure Portal upon completion. Once this has occured: 
  * Navigate to the Azure Resource Group you targeted 
  * Look for a virtual machine called "mapdvm" (assuming you haven't changed the default value). Click it. 
  * On the "Overview" Pane for "mapdvm", you can: 
    * Click DNS Name if you don't like the unique value we generated for the public-facing hostname 
    * Click the Connect icon to see the username@hostname value you can supply to your SSH client. 
  * The DNS Name associated with your VM can then be used to access the OmniSci Immerse interface.
    * In your web browser, navigate to http://hostname:9092

### Loading Data Into OmniSci

Using OmniSci's installation directions, you can load sample data into your OmniSci environment.  
* You'll need to connect to your VM using the SSH credentials described above.

Navigate to the "Checkpoint" instructions underneath the Activation section.
* CentOS 
  * "su" to the user "mapd" after login to run the steps listed
  * Environment issues? $MAPD_PATH will be /opt/mapd
  * CPU - https://www.omnisci.com/docs/latest/4_centos7-yum-cpu-ce-recipe.html
  * GPU - https://www.omnisci.com/docs/latest/4_centos7-yum-gpu-ce-recipe.html
* Ubuntu + Docker
  * CPU - https://www.omnisci.com/docs/latest/4_docker_cpu_ce_recipe.html
  * GPU - https://www.omnisci.com/docs/latest/4_docker_gpu_ce_recipe.html


