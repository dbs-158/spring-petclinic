pipeline {
    agent {
        label 'AWSCF'
    }
    environment {
        STACK_NAME = 'eks-infra-stack'
        TEMPLATE_FILE = 'CloudFormation-EKS.yaml'
        REGION = 'ap-south-1'
        ECR_REPOSITORY = 'my-app-repository'
        DOCKER_IMAGE = "${ECR_REPOSITORY}:latest"
        CLUSTER_NAME = 'my-eks-cluster'
        ACCOUNT_ID = '442426891871'
        ECR_URL = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY}"
    }
    stages {
        stage('git checkout'){
            steps {
                script {
                    echo "Checking out code from Git repository"
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[url: 'https://github.com/dbs-158/spring-petclinic.git']]
                    ])
                }
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                script {
                    echo "Deploying CloudFormation stack: ${STACK_NAME}"
                    sh """
                    aws cloudformation deploy \
                        --template-file ${TEMPLATE_FILE} \
                        --stack-name ${STACK_NAME} \
                        --capabilities CAPABILITY_NAMED_IAM \
                        --parameter-overrides EnvironmentName=dev ClusterName=my-eks-cluster \
                        --region ${REGION}
                    """
                }
            }
        }
        stage('Push Image to ECR') {
            steps {
                script {
                    echo "Logging into Amazon ECR and pushing Docker image"
                    sh """
                   aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 442426891871.dkr.ecr.ap-south-1.amazonaws.com
                    docker build -t my-ecr-repository .
                    docker tag my-ecr-repository:latest 442426891871.dkr.ecr.ap-south-1.amazonaws.com/my-ecr-repository:latest
                    docker push 442426891871.dkr.ecr.ap-south-1.amazonaws.com/my-ecr-repository:latest
                    """
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    echo "Deploying application to EKS cluster: ${CLUSTER_NAME}"
                    sh """
                    aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster
                    kubectl apply -f Demployment.yaml
                    kubectl get all
                    """
                }
            }
        }
    }
}
