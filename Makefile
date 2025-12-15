SHELL := /bin/bash
.EXPORT_ALL_VARIABLES:

# === Configuration ===
python_v := python3.11
LAMBDA_FUNCTION_NAME := LAMBDA_FUNCTION_NAME  # <<< Set your function name here
VIRTUAL_ENV := $(shell pipenv --venv)

init: 
	@echo "Python VERSION ->" $(python_v)
	@echo ___ Starting Lambda Layer creation Utility ____
	pipenv shell
	pipenv install


# @build-packages:
# 	@echo ___ Zipping the Lambda Layer ____
# 	cd "${VIRTUAL_ENV}" && \
# 	rm -rf python && \
# 	mkdir python && \
# 	cp -r Lib/site-packages/* python/ && \
# 	pip install -r "$(CURDIR)/requirements.txt" -t python/ && \
# 	zip -r9 "$(CURDIR)/packages.zip" python/ && \
# 	rm -rf python

	
@build-packages:
	@echo ___ Zipping the Lambda Layer ____
	cd "${VIRTUAL_ENV}" && \
	rm -rf python && \
	mkdir python && \
	cp -r lib python/ && \
	pip install -r "$(CURDIR)\requirements.txt" -t python/
	zip -r9 "$(CURDIR)\packages.zip" "${VIRTUAL_ENV}"/python/ && \
	rm -r "${VIRTUAL_ENV}"/python

@build:
	@echo ___ Inserting files into the Lambda Layer ____
	zip -gr ./$(notdir $(shell pwd)).zip ./* -x "*^.*|$(notdir $(shell pwd)).zip"

run:
	@echo ___ Running Locally ____
	python lambda_function.py

@deploy-packages:
	@echo ___ Deploying to Layer ____
	make @build-packages
	desc='$(shell cat requirements.txt | grep -o ".*==.....")'; \
	aws lambda publish-layer-version \
	--layer-name $(notdir $(shell pwd)) \
	--description "$$desc"  \
	--zip-file fileb://packages.zip \
	--compatible-runtimes python3.6 python3.7 python3.9 $(python_v) \
	--compatible-architectures "arm64" "x86_64" | tee > layer.tmp

@clean:
	rm -f *.zip
	rm -f *.tmp

@sync:
	arn="$(shell cat arn.tmp)"; \
	aws lambda update-function-configuration --function-name $(LAMBDA_FUNCTION_NAME) --layers $${arn} | tee

deploy:
	@echo ___ Deploying Code to AWS Lambda ____
	pipenv requirements > requirements.txt
			  
	make @build
	aws lambda update-function-code \
		--function-name $(LAMBDA_FUNCTION_NAME) \
		--zip-file fileb://$(notdir $(shell pwd)).zip | tee
	make @deploy-packages
	cat layer.tmp | grep -o "arn.*$(notdir $(shell pwd)):[0-9]*" > arn.tmp
	make @sync
	make @clean
