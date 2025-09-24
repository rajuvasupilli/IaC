pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VERSION        = '1.9.5'      // desired Terraform version
        TF_DIR            = "${WORKSPACE}\\tools\\terraform"  // local install dir
        PATH              = "${WORKSPACE}\\tools\\terraform;${env.PATH}"
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
    }

    post {
        success { echo "ECR Repository deployed successfully." }
        failure { echo "Pipeline failed. Check logs." }
    }
}
