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

.PHONY: plan workspace

plan: .init plan.txt

.init: backend.tf providers.tf
	terraform init
	touch .init

backend.tf: backend.tf.template
	sed -e "s/BUCKET_NAME/${BUCKET_NAME}/" $< > $@

plan.txt: workspace *.tf
	terraform plan -out plan.txt

workspace:
	terraform workspace select -or-create dev

tfclean:
	rm -f .init plan.txt

  
