pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VERSION        = '1.9.5'
        TF_DIR            = "${WORKSPACE}\\tools\\terraform"
        PATH              = "${WORKSPACE}\\tools\\terraform;${env.PATH}"
        IMAGE_NAME        = 'my-app'          // Docker image name
        IMAGE_TAG         = 'latest'          // Image tag
    }

    stages {
        stage('Install Terraform') {
            steps {
                powershell '''
                  $tfVer = "${env:TF_VERSION}"
                  $dest  = "${env:TF_DIR}"

                  if (!(Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }

                  Write-Host "Downloading Terraform $tfVer for Windows..."
                  $zipPath = "$env:WORKSPACE\\terraform.zip"
                  Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/$tfVer/terraform_${tfVer}_windows_amd64.zip" -OutFile $zipPath

                  Write-Host "Extracting..."
                  Expand-Archive -Path $zipPath -DestinationPath $dest -Force
                  Remove-Item $zipPath

                  Write-Host "Terraform installed at $dest"
                  & "$dest\\terraform.exe" -version
                '''
            }
        }

        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Terraform Init') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    powershell '''
                      cd ecr
                      terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    powershell '''
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
                    powershell '''
                      cd ecr
                      terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    powershell '''
                      # Get the ECR repository URI from Terraform output
                      cd ecr
                      $repoUri = terraform output -raw ecr_repository_url

                      Write-Host "Logging in to ECR..."
                      aws ecr get-login-password --region ${env:AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin $repoUri

                      Write-Host "Building Docker image..."
                      docker build -t ${env:IMAGE_NAME}:${env:IMAGE_TAG} .

                      Write-Host "Tagging Docker image for ECR..."
                      docker tag "${env:IMAGE_NAME}:${env:IMAGE_TAG}" "${repoUri}:${env:IMAGE_TAG}"
docker push "${repoUri}:${env:IMAGE_TAG}"
Write-Host "Docker image pushed successfully: ${repoUri}:${env:IMAGE_TAG}"

                    '''
                }
            }
        }
    }

    post {
        success { echo "ECR Repository deployed and Docker image published successfully." }
        failure { echo "Pipeline failed. Check logs." }
    }
}
