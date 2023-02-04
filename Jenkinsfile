pipeline {
    agent any
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
                    }
                }
            }
        }
    }
}