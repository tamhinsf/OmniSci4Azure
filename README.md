# Install OmniSci (MapD) on Microsoft Azure 

It's easy to deploy OmniSci (MapD) to Microsoft Azure! The Azure template on this page will install and configure OmniSci Community Edition (CE) onto a Linux virtual machine running CentOS 7.4 or Ubuntu 16.04-LTS. 
* CentOS 7.4 environments will make use of Yum packages 
* Ubuntu 16.04-LTS environments will be deployed in a Docker environment 
* GPU or CPU VM? It's up to you! 
  * Our installation process will detect the type of VM you've chosen and deploy OmniSci CE GPU or CPU based upon that.
  * We'll also install the NVIDIA GPU drivers as necessary 
  * After the installation process completes, you cannot switch your VM-series from a GPU to CPU and vice-versa.  However, you can scale up or down to a different GPU or CPU instance size.

Let's get started! 

## Identify your working environment 
Identify an Azure Environment and User Account 

* You'll need an Azure account that has privileges to create and configure the Azure resources and services we've described 

Click "Deploy to Azure" to load our Azure Resource Manager deployment template into the Azure Portal.  Don't worry - nothing will be deployed until you complete the required fields and confirm the deployment.  Wonder which components we'll use?  The Visualize link will map out the resources.  

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
* Make sure the VM Series you enter is available in the Azure region you target. 
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
    * In your web browser, navigate to http://your-hostname:9092

### Loading Data Into OmniSci

Using OmniSci's installation directions, you can load sample data into your OmniSci environment.  
* You'll need to connect to your VM using the SSH credentials described above.
* A local user named "mapd" was created to run the OmniSci (MapD) services

Navigate to the "Checkpoint" instructions underneath the Activation section.
* CentOS 
  * The "mapd" user's environment variables have all the needed OmniSci settings populated.  We suggest you:
    * SSH into your VM as the "mapdadmin" user
    * Change to the root user - the script to populate sample data requires root access: sudo su - root
    * Get the environment variables from the "mapduser": source ~mapd/.bashrc
    * Follow the instructions to run "insert_sample_data" as described in the links below
  * CPU - https://www.omnisci.com/docs/latest/4_centos7-yum-cpu-ce-recipe.html
  * GPU - https://www.omnisci.com/docs/latest/4_centos7-yum-gpu-ce-recipe.html
* Ubuntu + Docker
   * The "mapd" user is setup to use the Docker tooling
       * SSH into your VM as the "mapdadmin" user
       * Then change to the mapd user: sudo su - mapd
  * CPU - https://www.omnisci.com/docs/latest/4_docker_cpu_ce_recipe.html
  * GPU - https://www.omnisci.com/docs/latest/4_docker_gpu_ce_recipe.html


## Questions and comments

We'd love to get your feedback about this sample. You can send your questions and suggestions to us in the Issues section of this repository.

## Acknowledgements

Portions of this solution based on [Installing MapD Community Edition on Microsoft Azure](https://github.com/omnisci/mapd_on_azure) authored by [OmniSci](https://github.com/omnisci)

## Additional resources
OmniSci
* [OmniSci Community Forum](https://community.omnisci.com/)
* [Installing OmniSci on Local Hardware](https://www.omnisci.com/docs/latest/4_installation_recipes.html)
* [Docker CE CPU Installation Recipe](https://www.omnisci.com/docs/latest/4_docker_cpu_ce_recipe.html)
* [Docker CE GPU Installation Recipe](https://www.omnisci.com/docs/latest/4_docker_gpu_ce_recipe.html)


## Copyright

Copyright (c) 2018 Tam Huynh. All rights reserved. 


### Disclaimer ###
**THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.**
