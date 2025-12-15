## github-action-cicd

**There are two ways to write yaml file to create github actions pipeline**
- **With using only pip**

    Pip is used to install dependencies, do not create any virtual environment, - since github workflows runs on a new linux machine 
    every time , so there is no conflict of dependencies even if we do not create any virtual environment.
- **With using pipenv**

    Since pipenv automatically creates virtual environment, we need to use it everywhere while using any path/folder structure.

### Deploying AWS Lambda function from local to AWS environment
- There are three methods to deploy lambda function to AWS environment.
1. Using AWS cli and running each and every commands in local command prompt
2. Using Make software and Makefile - All the required commands are written inside Makefile and then `make init`, `make build`, and `make deploy` etc are run in local command prompt
3. Using Github actions pipeline 

#### Steps involved in Lambda function deployment:
Following are the main three steps involved to deploy a lambda function to AWS environment. All these steps can be performed with any of three methods explained just above.
1. Create ZIP file to package lambda function main code like main/lambda_handler.py, logging folder, util.py or util folder etc
2. Build lambda layer - steps involved in it
    1. install dependencies (either inside virtual environment if created or in main root directory)
    2. create ZIP file to package these dependencies 
    3. publish lambda layer
3. Create/Update lambda function - (only update if lambda function already exists in AWS environment otherwise create a new lambda function)
4. Update function configuration to use new layer
