pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'eu-west-2'  // Change to your preferred region
        TERRAFORM_DIR = 'tf/'      // Directory containing Terraform files
        DOCKER_IMAGE_NAME = 'e-commerce-app'  // Name of your Docker image
        ECR_REPOSITORY = 'my-ecr-repo'  // Name of your ECR repository
        EKS_CLUSTER_NAME = 'my-eks-cluster'  // Name of your EKS cluster
        AWS_ACCOUNT_ID = '841162688382'  // Your AWS account ID change to yours
        MANIFEST_DIR = 'manifests'  // Directory containing Kubernetes YAML files
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'fix/new-tf', url: 'https://github.com/cashall-0/E-CommerceWebsite.git' // Replace with your repo
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    dir(env.TERRAFORM_DIR) {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    dir(env.TERRAFORM_DIR) {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    dir(env.TERRAFORM_DIR) {
                        // First step: Apply the Terraform plan
                        sh 'terraform apply -auto-approve tfplan'
                        
                        // Second step: Retrieve the EKS cluster name from Terraform output
                        script {
                            def clusterName = sh(script: "terraform output -raw eks_cluster_name", returnStdout: true).trim()
                            sh "echo ${clusterName}"
                            env.EKS_CLUSTER_NAME = clusterName
                            echo "EKS Cluster Name: ${env.EKS_CLUSTER_NAME}"
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                    script {
                        // def dockerImage = docker.build(env.DOCKER_IMAGE_NAME, '.')
                        sh "docker build -t ${env.DOCKER_IMAGE_NAME} ."
                    }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        sh "aws ecr get-login-password --region ${env.AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com"
                    }
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        // Tag and push the Docker image to ECR
                        def ecrRepoUri = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com/${env.ECR_REPOSITORY}"
                        sh "docker tag ${env.DOCKER_IMAGE_NAME}:latest ${ecrRepoUri}:latest"
                        sh "docker push ${ecrRepoUri}:latest"
                    }
                }
            }
        }

        stage('Update Kubernetes Deployment with New Image') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        // Modify the deployment.yaml file to use the new ECR image URI
                        sh """
                        sed -i 's|image: .*|image: ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com/${env.ECR_REPOSITORY}:latest|' ${env.MANIFEST_DIR}/deployment.yaml
                        """
                        sh """
                        aws eks --region ${env.AWS_DEFAULT_REGION} update-kubeconfig --name ${env.EKS_CLUSTER_NAME}
                        """
                        // Apply the Kubernetes manifests (deployment and service)
                        sh """
                        kubectl apply -f ${env.MANIFEST_DIR}/deployment.yaml
                        kubectl apply -f ${env.MANIFEST_DIR}/service.yaml
                        """
                        sh "kubectl get svc -n default"
                    }
                }
            }
        }

        stage('Destroy Resources') {
            when {
                expression { return params.DESTROY_RESOURCES }  // Only execute if "DESTROY_RESOURCES" is true
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    dir(env.TERRAFORM_DIR) {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }

    parameters {
        booleanParam(
            name: 'DESTROY_RESOURCES',
            defaultValue: false,
            description: 'Set this to true if you want to destroy all EKS resources'
        )
    }
}
