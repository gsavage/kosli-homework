# Assignment, as emailed

There are many ways to serve websites on AWS. Your goal is to do research and pick two ways. You should be able to explain the reasons for your choice and why you decided against others.

* You should provision all necessary infra using Terraform.
* You should not store Terraform state locally. Pick any supported backend.
* Changes to HTML should cause redeployment.
* DNS name or IP address should stay the same after redeployment
* TLS is optional
* You should be able to deploy the same code into two different AWS accounts (think dev and prod). There should be a possibility to specify different parameters between accounts. For instance, the name of the ssh key if you are to go with EC2.
* Please store Terraform code on GitHub and share a link to the repo with us.
* CI setup is optional.

# Items to address
- [x] Decide on the two mechanisms to be used for hosting a site on AWS
- [x] Determine what components are needed
- [x] Decide whether to use two repos (one per mechanism)
- [x] Setup DNS (Do I have a suitable domain I could repurpose for this?)
- [x] Multiple AWS _accounts_ for example dev and prod
- [x] Instructions mention ssh key - is this necessary?

# ToDo List
- [x] Manually create the bootstrapping infra - IAM role/policy, and an S3 bucket
- [x] Decide the names of a couple of workspaces
- [x] Simulate having multiple AWS Account IDs - same account id, but make it a parameter...
- [x] Create the bucket for holding the static content
- [x] Create some static content
- [x] Build the ECS stack - cluster, service, task-definition, alb


# Thoughts
* Assuming the site is static, use S3 with Cloudfront as one option
* Github pages is another - demonstrates using a SaaS TF provider
  - No, assignment says to host on AWS
* Second approach could be to build a docker container (nginx) and put the static files in there - deploy on ECS?
  - Feels rather heavy-weight, but could scale out to dynamic content easily (e.g. a Rails site)
* TLS optional, but with Cloudfront and ACM, it's worth considering - leave to later?
* "Changes to the HTML should cause redeployment" - but CI setup is optional. 
  - Does this indicate that CI is optional but CD isn't??


