MAKEFLAGS += --no-print-directory

UNAME := $(shell uname -s)
AWS_PROFILE := $(shell echo $${AWS_PROFILE:-$$AWS_DEFAULT_PROFILE})
AWS_DEFAULT_PROFILE := $(AWS_PROFILE) # For legacy compatibility
AWS_REGION := $(shell echo $${AWS_REGION:-"us-east-2"})
AWS_DEFAULT_REGION := $(AWS_REGION) # For boto3 and legacy compatibility
TDOC := terraform-docs

ENVIRONMENT := dev
APP_NAME := app-demo-001
AUTO_BACKEND_EXT := $(APP_NAME).auto.backend

.PHONY: all
all: init ## Entrypoint

.PHONY: help
help: ## Show this help.
	@echo "Please use \`make <target>' where <target> is one of"
	@grep '^[a-zA-Z]' $(MAKEFILE_LIST) | \
    sort | \
    awk -F ':.*?## ' 'NF==2 {printf "\033[36m  %-26s\033[0m %s\n", $$1, $$2}'

.list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort

.PHONY: list
list: ## List public targets
	@LC_ALL=C $(MAKE) .list-targets | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs -n3 printf "%-26s%-26s%-26s%s\n"

.PHONY: init
init: .init .venv-reminder ## Ensure pip and Initialize venv

.PHONY: install
install: .venv-reminder ## Install dependencies

.PHONY: uninstall
uninstall: .uninstall .venv-reminder ## Uninstall dependencies

.PHONY: clean
clean: .uninstall .clean-venv ## Clean up

.PHONY: docs
docs: ## Generate documentation
	@printf "\nGenerating documentation...\n"
	@( set -x; \
  for subf in aws modules ; do $(TDOC) markdown table --config=.terraform-docs.yml --recursive --recursive-path=$$subf infra ; done \
)

.PHONY: bootstrap
bootstrap: .bootstrap-infra ## Setup bootstrap infrastructure

.PHONY: backend
backend: .backend-infra ## Setup backend infrastructure

.PHONY: platform
platform: .platform-infra ## Setup platform infrastructure

.PHONY: app
app: .app-infra ## Setup AWS infrastructure

.PHONY: deploy
deploy: backend bootstrap platform app ## Setup all AWS infrastructure

.PHONY: deploy-auto
deploy-auto: .backend-infra-auto .bootstrap-infra-auto .platform-infra-auto .app-infra-auto ## Setup all AWS infrastructure with auto-approve

.PHONY: aws
aws: deploy ## Setup all AWS infrastructure - alias for deploy

.PHONY: aws-auto
aws-auto: deploy-auto ## Setup all AWS infrastructure with auto-approve - alias for deploy-auto

.PHONY: app-destroy
app-destroy: .app-infra-destroy ## Destroy application infrastructure

.PHONY: platform-destroy
platform-destroy: .platform-infra-destroy ## Destroy platform infrastructure

.PHONY: backend-destroy
backend-destroy: .backend-infra-destroy ## Destroy backend infrastructure

.PHONY: bootstrap-destroy
bootstrap-destroy: .bootstrap-infra-destroy ## Destroy bootstrap infrastructure

.PHONY: destroy
destroy: app-destroy ## Destroy application infrastructure - alias for destroy-app

.PHONY: aws-destroy
aws-destroy: app-destroy platform-destroy bootstrap-destroy backend-destroy ## Destroy all AWS infrastructure

.PHONY: aws-destroy-auto
aws-destroy-auto: .app-infra-destroy-auto .platform-infra-destroy-auto .bootstrap-infra-destroy-auto .backend-infra-destroy-auto ## Destroy all AWS infrastructure with auto-approve

.clean-venv:
	( \
  . .venv/bin/activate; \
  deactivate; \
  rm -rf .venv; \
)

.venv-reminder:
	@printf "\n\t📝 \033[1m%s\033[0m: %s\n\t   %s\n\t   %s\n\t   %s.\n\n\t🏄 %s \033[1;92m\`%s\`\033[0m\n\t   %s.\n" "NOTE" "The dependencies are installed" "in a virtual environment which needs" "to be manually activated to run the" "Python command" "Please run" ". .venv/bin/activate" "to activate the virtual environment"

.init:
	@deactivate 2>/dev/null || true
	@test -d .venv || python3 -m venv .venv
	( \
  . .venv/bin/activate; \
  command -v pip3 || python3 -m ensurepip --default-pip; \
)
	@printf "\nIf this is your \033[1m%s\033[0m running this (in this directory),\nplease \033[4m%s\033[0m\033[1m\033[0m run \033[1;92m\`%s\`\033[0m to install dependencies 🚀\n" "first time" "next" "make install"

.uninstall:
	( \
  . .venv/bin/activate; \
  pip uninstall -y -r src/requirements.txt; \
)

.install:
	( \
  . .venv/bin/activate; \
  pip install --no-cache-dir -r src/requirements.txt; \
)

.backend-infra:
	( \
  cd infra/aws/backend; \
  terraform init -reconfigure; \
  TF_VAR_backend_vars_suffix=$(AUTO_BACKEND_EXT) terraform apply -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.bootstrap-infra:
	( \
  cd infra/aws/bootstrap; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform apply -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.platform-infra:
	( \
  cd infra/aws/platform; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform apply -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.app-infra:
	( \
  cd infra/aws/app; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform apply -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.backend-infra-auto:
	( \
  cd infra/aws/backend; \
  terraform init -reconfigure; \
  terraform apply -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.bootstrap-infra-auto:
	( \
  cd infra/aws/bootstrap; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform apply -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.platform-infra-auto:
	( \
  cd infra/aws/platform; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform apply -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.app-infra-auto:
	( \
  cd infra/aws/app; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform apply -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.backend-infra-destroy:
	( \
  cd infra/aws/backend; \
  terraform init -reconfigure; \
  terraform destroy -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.bootstrap-infra-destroy:
	( \
  cd infra/aws/bootstrap; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform destroy -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.platform-infra-destroy:
	( \
  cd infra/aws/platform; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform destroy -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.app-infra-destroy:
	( \
  cd infra/aws/app; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform destroy -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.backend-infra-destroy-auto:
	( \
  cd infra/aws/backend; \
  terraform init -reconfigure; \
  terraform destroy -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.bootstrap-infra-destroy-auto:
	( \
  cd infra/aws/bootstrap; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform destroy -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.platform-infra-destroy-auto:
	( \
  cd infra/aws/platform; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform destroy -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)

.app-infra-destroy-auto:
	( \
  cd infra/aws/app; \
  terraform init -reconfigure -backend-config=env/$(ENVIRONMENT)-$(AWS_REGION).$(AUTO_BACKEND_EXT); \
  terraform destroy -auto-approve -var-file env/$(ENVIRONMENT)-$(AWS_REGION).tfvars; \
)
