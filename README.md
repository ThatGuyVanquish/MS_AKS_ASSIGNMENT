## Execution Instructions: 
NOTE: Please call ```az login``` before executing either way.
#### 1) CLI: 
Edit the cli-setup.sh file, and enter your subcription-id to [line 4](https://github.com/ThatGuyVanquish/MS_AKS_ASSIGNMENT/blob/d267b7fd4303a3b9c01039b54c9f16a672879304/cli-setup.sh#L4C4-L4C4). Then execute the script and wait for it to finish.

Once it completes the cluster should have been created, and the k8s context should be set to it.

#### 2) TERRAFORM:
CD Into the [terraform](https://github.com/ThatGuyVanquish/MS_AKS_ASSIGNMENT/tree/master/terraform) folder, and edit [terraform.tfvars](terraform/terraform.tfvars) with your Subscription ID and Tenant ID.

Run the commands ```terraform init```, then ```terraform plan```, and finally ```terraform apply -auto-approve``` to start the cluster build process.

If any issues arise regarding the deployment of the kubectl manifests, check if the new cluster is the current context with ```kubectl get all```. 

If that fails with a connection issue, call ``` az aks get-credentials --resource-group nh-aks-rg --name nh-aks ```

then ```kubectl config use-context nh-aks```

Finally, call ```kubectl get all``` again to make sure that the new cluster is the current context and re-run ```terraform plan``` and ```terraform apply -auto-approve```.
## Explanation and rationale:
I decided to include two ways to run the project because I wanted to explore Azure CLI commands and learn how they could help me play around with a cluster configuration in a pinch.
I believe that working with them before I started working on the Terraform configuration helped me understand what the result should be and also helped me troubleshoot issues I had along the way.

I also believe that they're relevant for experimenting, as they're quicker to deploy than building and applying a Terraform module, making them a useful tool in my arsenal. On the other hand, Terraform modules are in my opinion much better for repeatability and maintainability of a project.

1) Using an Express app instead of just any script: I wanted to see the results of the liveness\readiness probes ‘poking’ the pod, therefore as I have recently done a lot of work with ExpressJS I decided to make the service-a app with that. 
2) CoinGecko API – There is a gateway that allows pinging (10 times a minute by my testing) the gateway without a need for an API key. If I had to use a different service that utilizes a key, I would have used a Kubernetes secret to store it which would’ve been created using a terraform module based on “kubernetes_secret” resource. 
This helps test the readiness probe of the BTC-Express deployment pod: if one would change the readiness probe to execute every 5 seconds, it will cause the pod to send more than 10 requests to the API in 1 minute, generating an error, which causes the readiness endpoint to return an error status and the probe will restart the pod.
3) Using modules: I believe having the ability to control and target specific modules to reconfigure or take down in case of updates and such makes this terraform implementation much more reliant for a deployment environment. I decided to separate my implementation to 3 modules: 
* The AKS Module – who’s responsible for deploying the cluster, give permissions for itself and the nodepool to access the ACR, and lastly apply the k8s config files.
* The ACR Module – which is responsible for creating the ACR, building the image of service-a’s deployment and uploading it to the ACR. I believe that in a real development environment a team might want to utilize GitHub actions to rebuild and upload the image to the ACR (for example, set up through the Azure FILL THIS) so that it could be automatically re-deployed on changes on the repository of the deployed service, but I couldn’t figure out how to export such configuration. 
* The Helm Module – who’s responsible for deploying the nginx ingress. 
4) Local backend: In this application I didn’t need to utilize remote backend for the tfstate file, but I believe that it could be beneficial to some degree to create an Azure Storage account and utilize it for a remote backend for the terraform build. I have included a file called backend.tf with commented out content on how I would (after creating it and then realizing I don’t need it for this application) configure the remote backend. I would provide a replacement via variables to the generic strings I’ve placed there through environment variables or the tfvars file.

