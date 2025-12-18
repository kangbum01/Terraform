# Terraform Study

Terraform 실습을 단계별로 정리한 레포지토리입니다.  
**기초 → Data Source/Output → VPC/Subnet/NAT 랩 → ALB·ASG·DB 아키텍처 → 미니 프로젝트** 흐름으로 구성되어 있습니다.

---

## Table of Contents
- [02. Terraform 기초 작업](#02-terraform-기초-작업)
  - [one-server](#one-server)
  - [one-webserver](#one-webserver)
  - [webserver-cluster](#webserver-cluster)
  - [data-output](#data-output)
  - [data-source](#data-source)
  - [lab01](#lab01)
  - [lab02](#lab02)
- [03. ALB-ASG-MySQL + DynamoDB/S3 백엔드](#03-alb-asg-mysql--dynamodb-s3-백엔드)
  - [작업 시나리오](#작업-시나리오)
  - [폴더 구조](#폴더-구조)
  - [작업 절차](#작업-절차)
- [mini project1](#mini-project1)

---

## 02. Terraform 기초 작업

### one-server
- AWS **EC2** 구성을 **Terraform 코드**로 구현

### one-webserver
- 단일 웹 서버 배포 (User Data 기반)

### webserver-cluster
- **ASG + ELB** 생성 실습

### data-output
- 기존 리소스/값들을 **`output`** 으로 출력하는 실습

### data-source
- **VPC 레포지토리**
  - 애플리케이션 배포를 위한 **VPC 및 보안 그룹** 구성 포함
- **애플리케이션 레포지토리**
  - **로드 밸런서 + EC2 인스턴스**로 구성된 예제 애플리케이션 배포 구성 포함
- 이미 생성된 VPC 정보를 APP 제작에 사용  
  - **remote/local state 참조**
- 삭제 순서
  - **APP → VPC**

### lab01
- `main`
  - VPC, IGW, PubSN, PubSN-RT
- `main2`
  - + EC2(WebServer, `user_data`)
- `main3`
  - + PriSN, PriSN-RT, NAT-GW, EC2(WebServer)

### lab02
- `ec2`
  - Data Source 실습

---

## 03. ALB-ASG-MySQL + DynamoDB/S3 백엔드

### 작업 시나리오
- **ALB → TG → ASG(EC2 인스턴스 x 2) → MySQL**
- Terraform Backend/Lock
  - **DynamoDB + S3**

### 폴더 구조
```text
elb-web-db/
|-- global/              # DynamoDB, S3 Bucket 공유할 수 있는 정보 설정
|   `-- s3/
|       |-- main.tf
|       `-- outputs.tf
`-- stage/
    |-- data-stores/
    |   `-- mysql/       # MySQL DB 서비스 -> DynamoDB, S3 Bucket 참조
    |       |-- db_credentials.sh
    |       |-- main.tf
    |       |-- outputs.tf
    |       `-- variables.tf
    `-- services/        # Web 서비스(ALB - ASG(EC2 x 2)) -> terraform_remote_state
        `-- webserver-cluster/
            |-- main.tf
            |-- outputs.tf
            `-- user-data.sh
