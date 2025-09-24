pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'       // or your preferred region
        TF_VERSION        = '1.9.5'            // Terraform version installed on agent
    }

    stages {
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
                script {
                    // Manual input before applying changes
                    input message: "Apply Terraform plan to create/update ECR?"
                }
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
        success {
            echo "ECR Repository deployed successfully."
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}

