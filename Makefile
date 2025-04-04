# These targets are to be run on the host computer, and build the dev
# container.
# 
# running `make bash` will run a Docker build as necessary, and jump
# into a bash shell as the "dev" user.
#

.PHONY: bash build clean
bash: build
	docker run --mount type=bind,src=$(HOME)/.aws,dst=/home/dev/.aws --mount type=bind,src=.,dst=/code --env-file=.env -it dev

build: .docker-built

.docker-built: Dockerfile
	docker build -f Dockerfile -t dev .
	touch .docker-built

clean:
	rm -f .docker-built

# These targets are to be used within the dev container - they are wrappers around Terraform
# commands.  Note that several of these will run `terraform init` for me, if needed.

.PHONY: plan apply workspace fmt validate

plan: .init workspace plan.txt

.init: backend.tf providers.tf
	terraform init
	touch .init

backend.tf: backend.tf.template
	sed -e "s/BUCKET_NAME/${BUCKET_NAME}/" $< > $@

apply: workspace plan.txt
	terraform apply -var-file=vars/$(KOSLI_ENV).tfvars plan.txt

plan.txt: *.tf website/*
	terraform plan -var-file=vars/$(KOSLI_ENV).tfvars -out plan.txt

workspace:
	terraform workspace select -or-create $(KOSLI_ENV)

fmt:
	terraform fmt

validate:
	terraform validate

tfclean:
	rm -f plan.txt

