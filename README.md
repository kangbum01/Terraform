# Terraform Study
## 02 Terraform 기초 작업
### 02) one-server - AWS EC2 구성을 코드로 구현
### 02) one-webserver - 단일 웹 서버 배포
### 02) webserver-cluster - ASG + ELB 생성 실습
### 02) data-output -  기존의 데이터들을 output을 통해 출력해보는 실습
### 02) data-source
  * VPC 레포지토리에는 애플리케이션에 대한 VPC 및 보안 그룹을 배포하기 위한 구성이 포함 되어 있다.
  * 애플리케이션 레포지토리에는 로드 밸런서와 EC2 인스턴스로 구성된 예제 애플리케이션을 배포하기 위한 구성이 포함되어 있다.
  * 이미 생성 된 VPC의 정보를 APP 제작에 사용할 것이다. - remote local 사용
  * 삭제 순서 APP -> VPC 순
### 02) lab01
  * main - VPC, IGW, PubSN, PubSN-RT
  * main2 - + EC2(WebServer(user_data)) 
  * main3 - + PriSN, PriSN-RT, NAT-GW, EC2(WebServer)
### 02) lab02
  * ec2 - Data Source 실습

## 03

## mini project1
 * provier 설정
 * VPC 설정
 * Public subnet 설정
 * Internet Gateway 설정
 * Public Routing 설정
 * Public Routing Table Association(Public subnet <-> Public Routing) 설정
 * Public Security Group 설정
 
 * AMI Data Source 설정
 * SSH Key 생성
 * EC2 Instance 생성
 
 * User Data 
 	* docker 설치
 * 테스트 (SSH Connection 연결 -> docker 실행)
