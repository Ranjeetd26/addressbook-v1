pipeline {
    agent none

    tools {
        maven 'Mymaven'
    }

    parameters {
        string(name: 'Env', defaultValue: 'Test', description: 'Environment to deploy')
        booleanParam(name: 'executeTests', defaultValue: true, description: 'Decide to run test cases')
        choice(name: 'APPVERSION', choices: ['1.1', '1.2', '1.3'], description: 'Select the application version')
    }

    environment {
        BUILD_SERVER = 'ec2-user@172.31.0.171'
        DEPLOY_SERVER = 'ec2-user@172.31.13.65'
        IMAGE_NAME = "ranjeetd26/addbook:${BUILD_NUMBER}"
    }

    stages {
        stage('Compile') {
            agent any
            steps {
                echo "Compile the code in ${params.Env}"
                sh "mvn compile"
            }
        }

        stage('UnitTest') {
            agent any
            when {
                expression { params.executeTests == true }
            }
            steps {
                echo "Running unit tests"
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('CodeReview') {
            agent any
            steps {
                echo "Running code review"
                sh "mvn pmd:pmd"
            }
        }

        stage('CodeCoverage') {
            agent any
            steps {
                echo "Running code coverage"
                sh "mvn verify"
            }
        }

        stage('Dockerize Image And Push') {
            agent any
            steps {
                sshagent(credentials: ['slave2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'Username', passwordVariable: 'Password')]) {
                        echo "Dockerizing and pushing to Docker Hub"

                        sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user/"
                        sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'bash /home/ec2-user/server-script.sh ${IMAGE_NAME}'"
                        sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'echo \"${PASSWORD}\" | sudo docker login -u \"${USERNAME}\" --password-stdin'"
                        sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}"
                    }
                }
            }
        }

        stage('Test/Deploy Docker Image') {
            agent any
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'Username', passwordVariable: 'Password')]) {
                    echo "Deploying the Docker image to ${params.Env} environment"

                    sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} 'sudo yum install -y docker || true'"
                    sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} 'sudo systemctl start docker || true'"
                    sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} 'echo \"${PASSWORD}\" | sudo docker login -u \"${USERNAME}\" --password-stdin'"
                    sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}"
                }
            }
        }
    }
}
