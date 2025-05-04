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
    stages {
        stage('Compile') {
            steps {
                script{
                    echo "Compiling the code"
                   echo "Compiling in ${params.Env}"
                   sh "mvn compile"
                }
                
            }
            
        }
        stage('CodeReview') {
            steps {
                script{
                    echo "Code Review Using pmd plugin"
                    sh "mvn pmd:pmd"
                }
                
            }
            
        }
         stage('UnitTest') {
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
            steps {
                script{
                    echo "Code Coverage by jacoco"
                    sh "mvn verify"
                }
                
            }
            
        }
        stage('Package') {
            steps {
                script{
                    echo "packaging the code"
                    echo 'platform is ${Platform}'
                    echo "packing the version ${params.APPVERSION}"
                    sh "mvn package"
                }
                
            }
            
        }
     stage('Publishtojfrog') {
            steps {
                script{
                    echo "publishing to by jfrog"
                    sh "-U deploy -s settings.xml"
                }
                
            }
            
        }
    }
}
}
