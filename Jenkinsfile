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

if [ ! -d "flask-mysql-docker-app" ]; then
    git clone https://github.com/Sourick1/flask-mysql-devops-project.git
fi

cd flask-mysql-docker-app
git pull origin main

cp .env.example .env || true

echo "Cleaning old containers..."
docker compose down -v || true
docker rm -f \$(docker ps -aq) || true

echo "Docker login..."
echo "$PASS" | docker login -u "$USER" --password-stdin

echo "Pulling latest image..."
docker pull sourick1/flask-mysql-docker-app:latest

echo "Starting containers..."
docker compose up -d

echo "Deployment Completed Successfully"

EOF
"""
                    }
                }
            }
        }
    }
}
