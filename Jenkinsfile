pipeline {
   environment {
        DROPLET_PUBLIC_IP = ""
        DIGITALOCEAN_TOKEN = credentials('DIGITALOCEAN_TOKEN')
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
                    sshagent(['ansible-server-key']) {
                        sh """
                           ansible-playbook ./java-react-example/deploy-java.yaml -i '${DROPLET_PUBLIC_IP},' -e "ansible_host=${DROPLET_PUBLIC_IP}"
                        """
                    }
                }
            }
        }
//        stage('Build Application with Gradle') {
//             steps {
//                 script {
//                     echo "Build app with Gradle"
//                     sh """
//                         gradle clean build
//                     """
//                 }
//             }
//         }
//         stage('Build Docker Image') {
//             steps {
//                 script {
//                     echo "Building the Docker image..."
//                     sh """
//                         docker build -t ${IMAGE_NAME} .
//                     """
//                 }
//             }
//         }
//         stage('Run Application in Docker') {
//             steps {
//                 script {
//                     echo "Starting the Docker container on the remote server..."
//                     sshagent(['ansible-server-key']) {
//                         sh """
//                         ssh -o StrictHostKeyChecking=no root@${DROPLET_PUBLIC_IP} "
//                             docker run -d -p 7071:7071 --name java-app ${IMAGE_NAME}
//                         "
//                         """
//                     }
//                 }
//             }
//         }
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
        stage('Cleanup') {
            steps {
                script {
                    echo "Destroying droplet with Terraform..."
                    sh 'terraform destroy -var="digitalocean_token=$DIGITALOCEAN_TOKEN" -auto-approve'
                }
            }
        }
    }
    post {
        always {
            script {
                echo "Pipeline finished. Cleaning up any residual resources."
                sh 'terraform destroy -var="digitalocean_token=$DIGITALOCEAN_TOKEN" -auto-approve'
            }
        }
    }
}
