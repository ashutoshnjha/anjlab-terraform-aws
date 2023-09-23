### This repo is for AWS Infra-stack creation ###
#### Adding contents in gradual way for easy understanding.####
* Directories
  * v1_starter := It is for terraform starter to know working of terraform using single template.
  * v2_intermidiate := It is for whom, who have basic understanding of terraform template & variables.
  * v3_advanced := To be added soon. It is for experienced to apply suitable features of terrafrom on top of intermediate templates. 

* Helpfull commands
  * terraform -help
  * terraform -v or terraform version
  * terraform fmt  - it does style formation.
  * terraform init - It prepares working directory for other commands execution
  * terraform validate - It checks for configuration validation.
  * terraform plan
  * terraform apply -auto-approve

* Ways to supply variables' values
  * TF_VAR environment variable
  * Defaut value while declaring, variable "var_name" {..}" in terraform template.
  * -var flag
  * -var-file flag
  * terraform.tfvars or terraform.tfvars.json
  * .auto.tfvars (I prefer this one) or .auto.tfvars.json

* Variable value evalution precedence.
  * TF_VAR env var < .tfvars < .auto.tfvars < -var-file < -var < command line prompt (highest)

