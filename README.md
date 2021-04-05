# VM and AKS on Azure

Repository that meets the following objectives:

- Create a `virtual machine` that must return the public ip to install jenkins
- Create a `kubernetes cluster` with certain conditions

### Setup

##### Init Terraform

```bash
terraform init
```

##### Create new env file with env template

```bash
cp .env.example .env
```

##### Change to your credentials in the new env file

Use your favorite IDE and configure your access `azure`

##### Export credential

```bash
export $(cat .env | xargs)
```

### Run Terraform

##### Verify Plan

```bash
terraform plan
```

### Apply Plan

```bash
terraform apply
```
