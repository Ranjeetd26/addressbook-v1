pipeline{
    agent none
    tools {
        // jdk "myjava"
        maven "mymaven"
    }
    parameters {
        string(name: 'Env', defaultValue: 'Test', description: 'Environment to deploy')
        booleanParam(name: 'executeTests', defaultValue: true, description: 'decide to run tc')
        choice(name: 'APPVERSION', choices: ['1.1', '1.2', '1.3'], description: 'Select the application version')
    }
    Environment{
        BUILD_SERVER = 'ec2-user@172.31.0.171'
        DEPLOY_SERVER = 'ec2-user@172.31.13.65'
        IMAGE_NAME = 'ranjeetd26/addbook:$BUILD_NUMBER'
    }
    stages{
        stage('Compile'){
            agent any
            steps{
                echo "compile the code in ${params.Env}"
                sh "mvn compile"
            }
        }
        stage('UnitTest'){
            agent any
            when {
                expression {
                    param.executeTests == true
                }
            }
            script {
                echo "test the code"
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('CodeReview'){
            agent any
            script {
                echo "Code review stage"
                sh "mvn pmd:pmd"
            }
        }
        stage('CodeCoverage'){
            agent any
            script {
                echo "Code coverage stage"
                sh "mvn verify"
            }
        }
        stage('Dockerize Image And Push'){
            agent any
            steps {
                sshagent(["slave2"]) {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'Username', passwordVariable: 'Password')]) {
                       echo "Dockerize the application and push to Docker Hub"
                       sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                       sh "ssh ${BUILD_SERVER} sudo docker login -u ${Username} -p ${Password}"
                       sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}"
                    }
                }
            }
        }
        stage('Test/deploy docker image'){
            agent any
            steps {
               withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'Username', passwordVariable: 'Password')]) {
                   echo "Deploy the application to ${params.Env} environment"
                   sh "scp -o StrictHostKeyChecking=no ${DEPLOY_SERVER} sudo yum install -y docker"
                   sh "ssh ${DEPLOY_SERVER} sudo docker login -u ${Username} -p ${Password}"
                   sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -p 8080:8080 --name addbook ${IMAGE_NAME}"
               }
            }
        }
    }
}