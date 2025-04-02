# Assignment, as emailed
* You should provision all necessary infra using Terraform.
* You should not store Terraform state locally. Pick any supported backend.
* Changes to HTML should cause redeployment.
* DNS name or IP address should stay the same after redeployment
* TLS is optional
* You should be able to deploy the same code into two different AWS accounts (think dev and prod). There should be a possibility to specify different parameters between accounts. For instance, the name of the ssh key if you are to go with EC2.
* Please store Terraform code on GitHub and share a link to the repo with us.
* CI setup is optional.
