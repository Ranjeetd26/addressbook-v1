pipeline {
    agent any

    tools{
        maven "Mymaven"
    }
    
    parameters{
        string(name:'Env',defaultValue:'Test',description:'environment to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])

    }
    environment{
        BUILD_SERVER = 'ec2-user@172.31.15.106'
    
    stages {
        stage('Compile') {
            agent any
            steps {
                script{
                    echo "Compiling the code"
                   echo "Compiling in ${params.Env}"
                   sh "mvn compile"
                }
                
            }
            
        }
        stage('CodeReview') {
            agent any
            steps {
                script{
                    echo "Code Review Using pmd plugin"
                    sh "mvn pmd:pmd"
                }
                
            }
            
        }
         stage('UnitTest') {
            agent any
            when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                script{
                    echo "UnitTest in junit"
                    sh "mvn test"
                }
                
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
            
        }
        stage('CodeCoverage') {
            agent any
            steps {
                script{
                    echo "Code Coverage by jacoco"
                    sh "mvn verify"
                }
                
            }
            
        }
        stage('Package') {
            agent any
            steps {
                script{
                    sshagent(['slave2_ssh']) {
                    echo "packaging the code"
                    echo "packing the version ${params.APPVERSION}"
                    sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user"
                    sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'bash ~/server-script.sh'"
                }
                
            }
            
        }
        }
     stage('Publishtojfrog') {
            agent any
            steps {
                script{
                    echo "publishing to by jfrog"
                    sh "mvn -U deploy -s settings.xml"
                }
                
            }
            
        }
    }
}
}
