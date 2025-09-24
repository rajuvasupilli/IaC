pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VERSION        = '1.9.5'          // pick any Terraform version you need
    }

    stages {
        stage('Install Terraform') {
            steps {
                sh '''
                  set -e
                  echo "Installing Terraform ${TF_VERSION} ..."
                  curl -sSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o terraform.zip
                  unzip -o terraform.zip
                  sudo mv terraform /usr/local/bin/terraform
                  rm -f terraform.zip
                  terraform -version
                '''
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                      cd ecr
                      terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                      cd ecr
                      terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Apply Terraform plan to create/update ECR?"
            }
        }

        stage('Terraform Apply') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                      cd ecr
                      terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
    }

    post {
        success  { echo "ECR Repository deployed successfully." }
        failure  { echo "Pipeline failed. Check logs." }
    }
}
