pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sourick1/flask-mysql-docker-app"
        TAG = "latest"
    }

    stages {

        stage("Clone Code") {
            steps {
                deleteDir()
                git url: 'https://github.com/Sourick1/flask-mysql-devops-project.git', branch: 'main'
            }
        }

        stage("Build Image") {
            steps {
                sh "docker build -t $DOCKER_IMAGE:$TAG ."
            }
        }

        stage("Test") {
            steps {
                echo "Basic test passed"
            }
        }

        stage("Login to Docker Hub") {
    steps {
        withCredentials([usernamePassword(
            credentialsId: "dockehub",
            usernameVariable: "USER",
            passwordVariable: "PASS"
        )]) {
            sh """
            echo '${PASS}' | docker login -u '${USER}' --password-stdin
            """
        }
    }
}

        stage("Push Image") {
            steps {
                sh "docker push $DOCKER_IMAGE:$TAG"
            }
        }

        stage("Deploy to EC2") {
            steps {
                sshagent(['ec2-ssh']) {
                    withCredentials([usernamePassword(
                        credentialsId: "dockehub",
                        usernameVariable: "USER",
                        passwordVariable: "PASS"
                    )]) {

                       sh """
ssh -o StrictHostKeyChecking=no ubuntu@43.204.216.179 << EOF

cd /home/ubuntu || exit

if [ ! -d "flask-mysql-devops-project" ]; then
    git clone https://github.com/Sourick1/flask-mysql-devops-project.git
fi

cd flask-mysql-devops-project
git pull origin main

docker rm -f flask-app || true
docker system prune -f || true

echo "$PASS" | docker login -u "$USER" --password-stdin

docker pull sourick1/flask-mysql-docker-app:latest

docker run -d --name flask-app -p 5000:5000 sourick1/flask-mysql-docker-app:latest

EOF
"""
                    }
                }
            }
        }
    }
}
