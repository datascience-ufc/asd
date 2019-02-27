IMAGE = asd
PACKAGE = asd
SSH = ufc@ufc.lerax.me
CLOUD_PATH = www/models
CLOUD_ROOT = $(SSH):$(CLOUD_PATH)
PWD := $(shell pwd)
UID := $(shell id -u)
GID := $(shell id -g)
USER := $(UID):$(GID)
DOCKER_VOLUME := $(PWD)/workspace
DOCKER_APP := /app
DOCKER_FOLDER := $(DOCKER_APP)/workspace
DOCKER_REGISTRY = hub.docker.com/datascience-ufc
DOCKER_IMG = $(DOCKER_REGISTRY)/$(IMAGE):$(VERSION)
DOCKER_IMG_LATEST = $(DOCKER_REGISTRY)/$(IMAGE):latest
DOCKER_RUN = docker run -t --rm \
						--user $(USER) \
						-v $(DOCKER_VOLUME):$(DOCKER_FOLDER) \
						-e APP_VERSION=$(VERSION)
STATUS_PREFIX = "\033[1;32m[+]\033[0m "
ATTENTION_PREFIX =  "\033[1;36m[!]\033[0m "

help:
	@echo "usage: make <command> [VERSION=X.Y.Z]"
	@echo
	@echo "COMMANDS"
	@echo "    check    Run unit-tests and linters"
	@echo "    shell    Enter into a shell (sh) of the docker container."
	@echo "    jupyter  Launch jupyterlab with the software installed as library."
	@echo "    build    Build docker image from Dockerfile."
	@echo "    release  [Need VERSION] Release a new version of software as tag."
	@echo "    dist     [Need VERSION] Generate Python packages to workspace/dist."
	@echo "    load     [Need VERSION] Load workspace/ from cloud service."
	@echo "    save     [Need VERSION] Save workspace/ to cloud service."
	@echo "    clean    Clean workspace/dist software distribution"
	@echo "    features Generates train data for the model and store it to workspace/data/ ."
	@echo "    train    Train models with the generated data and store the binaries at workspace/model/."
	@echo "    metadata Create metadata for the trained model at workspace/."
	@echo "    run      Create train data, train model and store trained workspace and metadata."
	@echo "    predict  [Need INPUT] Use trained model to predict data specified on the INPUT variable."
	@echo
	@echo "VARS"
	@echo "    VERSION  Software Version variable."
	@echo "    INPUT    Path for data to be predicted."
	@echo "    PARAMS   Parameters to pass as: $ asd <command> $(PARAMS)."

# Variable set checking
guard-%:
	@ if [ "${${*}}" = "" ]; then echo "Variable '$*' not set"; exit 1; fi

#################
# User Commands #
#################

features: build
	$(DOCKER_RUN) $(IMAGE) features $(PARAMS)

train: build
	$(DOCKER_RUN) $(IMAGE) train $(PARAMS)

metadata: build
	$(DOCKER_RUN) $(IMAGE) metadata $(PARAMS)

run: build
	$(DOCKER_RUN) $(IMAGE) run $(PARAMS)

predict: guard-INPUT mkdir-predict
	$(DOCKER_RUN) -v $(PWD)/predict:$(DOCKER_APP)/predict \
	$(IMAGE) predict --input-data $(INPUT) $(PARAMS)

jupyter:
	@printf $(STATUS_PREFIX); echo "PREPARING JUPYTERLAB ENVIRONMENT"
	@docker kill jupyter 2> /dev/null || echo No jupyter running now
	docker run -d --rm -p 8888:8888 \
			   -e JUPYTER_ENABLE_LAB=yes \
			   --name="jupyter" \
			   --user root \
		       -e NB_UID=$(UID) -e NB_GID=$(GID) \
			   -v $(PWD):/home/jovyan/work \
			   jupyter/datascience-notebook \
			   start.sh jupyter lab --LabApp.token=''
	docker exec -t jupyter \
		   pip --disable-pip-version-check  \
			   --no-cache-dir \
			   install -e /home/jovyan/work/.
	docker exec -t -d jupyter chown -R $(USER) /home/jovyan/work/.
	@printf $(ATTENTION_PREFIX); echo "JupyterLab: http://127.0.0.1:8888"

jupyter-notebook:
	@printf $(STATUS_PREFIX); echo "PREPARING JUPYTER NOTEBOOK ENVIRONMENT"
	@docker kill jupyter 2> /dev/null || echo No jupyter running now
	docker run -d --rm -p 8888:8888 \
			   --name="jupyter" \
			   --user root \
		       -e NB_UID=$(UID) -e NB_GID=$(GID) \
			   -v $(PWD):/home/jovyan/work \
			   jupyter/datascience-notebook \
			   start.sh jupyter notebook --NotebookApp.token=''
	docker exec -t jupyter \
		   pip --disable-pip-version-check  \
			   --no-cache-dir \
			   install -e /home/jovyan/work/.
	docker exec -t -d jupyter chown -R $(USER) /home/jovyan/work/.
	@printf $(ATTENTION_PREFIX); echo "JupyterNotebook: http://127.0.0.1:8888"


# Enter in shell of the Docker container for debugging purposes
shell: build
	@printf $(STATUS_PREFIX); echo "OPEN SHELL"
	$(DOCKER_RUN) -it --entrypoint="sh" $(IMAGE)

# Tag software and push to repository
release: guard-VERSION check save
	@printf $(STATUS_PREFIX); echo "CREATE NEW GIT TAG" $(VERSION)
	git tag -a $(VERSION) -m "Auto-generated release $(VERSION)"
	git push origin $(VERSION)

# Distribute software in multiple formats
dist: guard-VERSION build clean
	@printf $(STATUS_PREFIX); echo "DISTRIBUTE SOFTWARE PACKAGES IN" $(DOCKER_VOLUME)/dist/
	$(DOCKER_RUN) --entrypoint="python3" $(IMAGE) \
				  setup.py bdist_egg \
				  --dist-dir $(DOCKER_FOLDER)/dist/
	$(DOCKER_RUN) --entrypoint="python3" $(IMAGE) \
				  setup.py bdist_wheel \
				  --dist-dir $(DOCKER_FOLDER)/dist/
	$(DOCKER_RUN) --entrypoint="python3" $(IMAGE) \
				  setup.py bdist --formats=gztar \
				  --dist-dir $(DOCKER_FOLDER)/dist/

# Build docker image, run lint & unit-tests
check: build lint tests


tests:
	@printf $(STATUS_PREFIX); echo "RUN UNIT-TESTS"
	$(DOCKER_RUN) --entrypoint="pytest" $(IMAGE) \
				  --cov=$(PACKAGE)/

lint: flake8 mypy bandit

mypy:
	@printf $(STATUS_PREFIX); echo "LINT MYPY: TYPE CHECKING"
	$(DOCKER_RUN) --entrypoint="mypy" $(IMAGE) \
				  --ignore-missing-imports \
				  --strict-optional \
				  $(PACKAGE)/

flake8:
	@printf $(STATUS_PREFIX); echo "LINT FLAKE8: STYLE CHECKING"
	$(DOCKER_RUN) --entrypoint="flake8" $(IMAGE) \
				  $(PACKAGE)/

bandit:
	@printf $(STATUS_PREFIX); echo "LINT BANDIT: SECURITY CHECKING"
	$(DOCKER_RUN) --entrypoint="bandit" $(IMAGE) \
				 $(PACKAGE)/ -r

clean-dist:
	@printf $(STATUS_PREFIX); echo "CLEAN DIST FOLDER"
	$(DOCKER_RUN) --entrypoint="sh" $(IMAGE) \
				  -c 'rm -f $(DOCKER_FOLDER)/dist/*'
	rm -rf $(DOCKER_VOLUME)/dist/

clean: clean-dist
	rm -rf asd.egg_info
	find . -iname __pycache__ | xargs rm -rf


# Save model workspace to cloud with version
save: guard-VERSION
	@printf $(STATUS_PREFIX); echo "RELEASE /workspace TO CLOUD" $(VERSION)
	ssh $(SSH) mkdir -p $(CLOUD_PATH)/$(IMAGE)/$(VERSION)
	rsync -rav -e ssh workspace/* $(CLOUD_ROOT)/$(IMAGE)/$(VERSION)/



###################################
# CI, Docker and Release commands #
###################################

# Build docker image
build: mkdir-workspace
	@printf $(STATUS_PREFIX); echo "BUILD DOCKER IMAGE"
	docker build -t $(IMAGE) .

# Publish docker images on Neoway registry
publish: guard-VERSION publish-latest publish-version

publish-version: guard-VERSION
	@printf $(STATUS_PREFIX); echo "PUBLISH DOCKER:" $(IMAGE)
	docker tag $(IMAGE) $(DOCKER_IMG)
	docker push $(DOCKER_IMG)

publish-latest:
	@printf $(STATUS_PREFIX); echo "PUBLISH DOCKER:" $(IMAGE_LATEST)
	docker tag $(IMAGE) $(DOCKER_IMG_LATEST)
	docker push $(DOCKER_IMG_LATEST)

# Load model workspace from AWS S3 (or another cloud)
load: guard-VERSION mkdir-workspace
	@printf $(STATUS_PREFIX); echo "LOAD /RESULTS FROM CLOUD OF" $(VERSION)
	rsync -rav -e ssh $(CLOUD_ROOT)/$(IMAGE)/$(VERSION)/ \
					   workspace/ \


mkdir-%:
	mkdir -p $(PWD)/$*
	chmod a+w $(PWD)/$*

clean-workspace:
	@printf $(STATUS_PREFIX); echo "CLEAN FILESYSTEM"
	$(DOCKER_RUN) --entrypoint="sh" $(IMAGE) \
				  -c 'rm -rf $(DOCKER_FOLDER)/*'

clean-ci: clean-workspace
	rm -rf $(DOCKER_VOLUME)

.PHONY: clean flake8 mypy flake8 tests lint help
