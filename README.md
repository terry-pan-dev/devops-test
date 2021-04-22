## Instructions to build and deploy

This project utilizes AWS ECS service to deploy the docker container. Although,
the whole build and deployment workflow can be achieved in Github Actions CI/CD
pipeline. The reason that I finally decide to make this project to build and
deploy locally is because the extra effort to setup a storage to store terraform
state. Therefore, following instructions will show you how to build and deploy
this project locally.

### Build Docker Image
1. log into your docker hub account
```bash
docker login -username=docker-hub-account-name --password=docker-hub-password
```
2. build docker image
```bash
# navigate to the server folder
cd server
docker build -t docker-account-name/name-of-image:image-tag .
```
3. push the image to docker hub
```bash
docker push docker-account-name/name-of-image:image-tag
```

### Deployment
Make sure you have terraform installed locally and an AWS account that can
create following services in AWS
- VPC
- load balancer
- ECS

1. prepare environment variable
```bash
# export necessary local environment variables
export AWS_ACCESS_KEY_ID="change this to your aws account access key id"
export AWS_SECRET_ACCESS_KEY="change this to your aws account secret access key"
export TF_VAR_container_image="change this to your docker image name"
```

2. init a terraform project
```bash
cd infra
terraform init
```

3. plan (dry-run) the terraform project
```bash
terraform plan
```

4. deploy the infrastructure
```bash
terraform apply
```
Once you have deployed the infrastructure. You will get a load balancer
DNS name which you can used to access the application (wait a few miniutes for 
the container to run)

5. clear the infrastructure
```bash
terraform destroy
```