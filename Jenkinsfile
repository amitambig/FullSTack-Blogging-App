pipeline {
    agent any
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/amitambig/FullSTack-Blogging-App.git'
            }
        }
        stage('Compile') {
            steps {
               sh 'mvn compile'
            }
        }
        stage('Test') {
            steps {
               sh 'mvn test'
            }
        }
        stage('Trivy FS Scan') {
            steps {
               sh 'trivy fs --format table -o fs.html .'
            }
        }
        stage('Code Analysis') {
            steps {
               withSonarQubeEnv('sonar-server') {
                   sh ''' mvn clean verify sonar:sonar -DskipTests=true\
                    -Dsonar.projectKey=Project-CICD  '''
               }
            }
        }
        stage('Build') {
            steps {
               sh 'mvn package'
            }
        }
        stage('Publish artifact') {
            steps {
               withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
               sh 'mvn deploy'
            }
        }
        }
        stage('Build IMG') {
            steps {
               script{
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                   sh 'docker build -t amitambig/blogappimg:latest .'
                   
               }
               }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                 sh 'trivy image --format table -o image.html amitambig/blogappimg:latest '
                
            }
        }
        
        stage('Push IMG') {
            steps {
               script{
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                   sh 'docker push amitambig/blogappimg:latest'
                   
                    }
               }
            }
        }
        
    }
}
 