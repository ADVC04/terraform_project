pipeline {
    agent any
    tools {
        maven 'maven3'
    }
    stages {
        stage('provioson server'){
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key_id')
            }
            steps {
                script {
                    dir('terraform') {
                    sh "terraform init"
                    sh "terraform apply --auto-approve"
                    EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
        stage('Build'){
            steps {
                script {
                    sh "mvn clean package"
                }
            }
        }
        stage('Deploy'){
             steps {
                 sshagent(['ecr-server']) {
        sh 'scp -o StrictHostKeyChecking=no /var/lib/jenkins/workspace/ci-cd/target/java-app.jar ubuntu@35.154.68.160:/tmp/'
        }
                 }
             }
         }
    }