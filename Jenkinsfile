pipeline {
    agent any
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }
    parameters{
        string(name:'DOCKER_TAG',defaultValue:'latest',description:'Docker tag')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/amitambig/FullSTack-Blogging-App.git'
            }
        }
        stage('Compile & Test') {
            steps {
                sh 'mvn compile'
                sh 'mvn test'
            }
        }
        stage('File Scan') {
            steps {
                sh 'trivy fs --format table -o fs.html .'
            }
        }
        stage('Code Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''mvn clean verify sonar:sonar -DskipTests=true \
                    -Dsonar.projectName=Blog-App \
                    -Dsonar.projectKey=Blog-App'''
                }
            }
        }
        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Artifact Deployment') {
            steps {
                withMaven(globalMavenSettingsConfig: '549e0c8e-89bb-4cbd-a802-e776d1dfa507', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                    sh 'mvn deploy'
                }
            }
        }
        stage('Docker Build') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker build -t amitambig/blogappimg:${params.DOCKER_TAG} ."
                    }
                }
            }
        }
        stage('Image Scan') {
            steps {
                sh "trivy image --format table -o img.html amitambig/blogappimg:${params.DOCKER_TAG}"
            }
        }
        stage('Docker Push') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker push amitambig/blogappimg:${params.DOCKER_TAG}"
                    }
                }
            }
        }
        
        stage('Update Repo file') {
            environment {
            GIT_REPO_NAME = "FullSTack-Blogging-App"
            GIT_USER_NAME = "amitambig"
        }
            steps {
                script
                {
                    withCredentials([string(credentialsId: 'git-cred', variable: 'GITHUB_TOKEN')]){
                        sh '''
                        git config user.email "amitambig@gmail.com"
                        git config user.name "amitambig"
                        sed -i "s/blogappimg:.*/blogappimg:${DOCKER_TAG}/g" Configuration_files/deployment.yml
                        git add Configuration_files/deployment.yml
                        git commit -m "Update deployment image to version ${DOCKER_TAG}"
                        git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                        
                        '''
                    }
                }
            }
        }
    }
}
