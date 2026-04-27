## 📌 Project Overview
This project showcases an **end-to-end DevOps implementation** by deploying a containerized Flask application on AWS using Infrastructure as Code.

The application is hosted on an EC2 instance, connected to a managed MySQL database on RDS, and the entire infrastructure is provisioned and managed using Terraform with a remote backend.

---

## 🏗️ Architecture

Client → Web Browser → EC2 Instance (Dockerized Flask App) → AWS RDS (MySQL Database)

---

## 🛠️ Tech Stack

- **AWS Services:** EC2, RDS, VPC, S3, DynamoDB  
- **Infrastructure as Code:** Terraform (with S3 remote backend + DynamoDB state locking)  
- **Containerization:** Docker  
- **Backend Framework:** Flask (Python)  
- **Database:** MySQL (AWS RDS)  

## ⚙️ Steps to Run

### 1. Clone Repo

git clone https://github.com/Sourick1/flask-mysql-devops-project.git
cd flask-mysql-devops-project

2. Setup Infrastructure (Terraform)
   
cd terraform
terraform init
terraform apply

3. Build Docker Image
docker build -t flask-app .
4. Run Container
docker run -d -p 5000:5000 \
-e DB_HOST=<RDS_ENDPOINT> \
-e MYSQL_USER=admin \
-e MYSQL_PASSWORD=password123 \
-e MYSQL_DATABASE=mydb \
flask-app

🌐 Access Application
http://<EC2_PUBLIC_IP>:5000

✅ Features
Full cloud infrastructure using Terraform
Dockerized application deployment
Remote MySQL database (RDS)
Real-time message storage
