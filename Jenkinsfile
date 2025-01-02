pipeline {
   environment {
        DROPLET_PUBLIC_IP = ""
        IMAGE_NAME = "java-application"
        DIGITALOCEAN_TOKEN = credentials('DIGITALOCEAN_TOKEN')
        DOCKER_REGISTRY = "docker.io"
    }
    agent any
    stages {
         stage('Provision Droplet') {
            steps {
                script {
                    echo "Running Terraform to provision droplet..."
                    sh 'terraform destroy -var="digitalocean_token=$DIGITALOCEAN_TOKEN" -auto-approve'
                    sh 'terraform init'
                    sh 'terraform apply -var="digitalocean_token=$DIGITALOCEAN_TOKEN" -auto-approve'
                    DROPLET_PUBLIC_IP = sh(
                        script: "terraform output droplet_ip",
                        returnStdout: true
                    ).trim()
                    echo "Droplet IP: ${DROPLET_PUBLIC_IP}"
                }
            }
        }
        stage('Configure Environment') {
            steps {
                script {
                    echo "Configuring server with Ansible..."
                    sshagent(['jenkins-server-ssh']) {
                        sh """
                           sleep 30
                           ssh -o StrictHostKeyChecking=no root@${DROPLET_PUBLIC_IP} pwd
                           ansible-playbook ./java-react-example/deploy-java.yaml -i '${DROPLET_PUBLIC_IP},' -e "ansible_host=${DROPLET_PUBLIC_IP} ansible_user=root"
                        """
                    }
                }
            }
        }
       stage('Build Application with Gradle') {
            steps {
                script {
                    dir("java-react-example") {
                     echo "Build app with Gradle"
                        sh """
                            gradle clean build
                        """
                    }
                }
            }
        }
        stage('Login to Docker and build Docker image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        dir("java-react-example") {
                             echo "Building the Docker image..."
                                sh """
                                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                                    docker build -t $DOCKER_USERNAME/java-app-country:${BUILD_NUMBER} .
                                    docker push $DOCKER_USERNAME/java-app-country:${BUILD_NUMBER}
                                """
                        }
                    }
                }
            }
        }
    stage('Run Application in Docker') {
        steps {
            withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            script {
                echo "Starting the Docker container on the remote server..."
                sshagent(['jenkins-server-ssh']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no root@${DROPLET_PUBLIC_IP} "
                        echo 'Logging in to Docker registry...'
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin &&
                        echo 'Pulling Docker image...' &&
                        docker pull $DOCKER_USERNAME/java-app-country:${BUILD_NUMBER} &&
                        echo 'Running Docker container...' &&
                        docker run -d -p 7071:7071 --name java-app $DOCKER_USERNAME/java-app-country:${BUILD_NUMBER}
                    "
                    """
                    }
                }
            }
        }
    }
//         stage('Run Tests') {
//             steps {
//                 script {
//                     echo "Running Playwright tests..."
//                     sh "npm install"
//                     sh "npx playwright test"
//                 }
//             }
//         }
//         stage('Push Docker Image to Nexus') {
//             steps {
//                 script {
//                     echo "Pushing the Docker image to Nexus..."
//                     sh """
//                         docker login -u ${NEXUS_CREDENTIALS_USR} -p ${NEXUS_CREDENTIALS_PSW} ${NEXUS_URL}
//                         docker tag ${IMAGE_NAME} ${NEXUS_URL}/repository/${NEXUS_REPO}/${IMAGE_NAME}
//                         docker push ${NEXUS_URL}/repository/${NEXUS_REPO}/${IMAGE_NAME}
//                     """
//                 }
//             }
//         }
//         stage('Cleanup') {
//             steps {
//                 script {
//                     echo "Destroying droplet with Terraform..."
//                     sh 'terraform destroy -var="digitalocean_token=$DIGITALOCEAN_TOKEN" -auto-approve'
//                 }
//             }
//         }
    }
//     post {
//         always {
//             script {
//                 echo "Pipeline finished. Cleaning up any residual resources."
//                 sh 'terraform destroy -var="digitalocean_token=$DIGITALOCEAN_TOKEN" -auto-approve'
//             }
//         }
//     }
}
