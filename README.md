# 테라폼을 통한 EKS 구성 (README.md 작성 진행중.)
EKS 구성을 위한 테라폼 예제입니다.
- 아래 테라폼 EKS 강의를 듣고 개인적으로 정리한 내용입니다.
  - https://www.udemy.com/course/terraform-on-aws-eks-kubernetes-iac-sre-50-real-world-demos

- 폴더 명 역할
  - 01-eks-private : 노드그룹이 private 인 eks 를 생성함
  - 01-eks-private-lbc-install : 01-eks-private 에서 생성한 eks 를 기반으로 aws loadbalancer controller 를 생성하고 ingress 적용
  - 02-eks-public : 노드그룹이 public 인 eks 를 생성함
  - 02-eks-public-irsa-demo : -


## 프로젝트 목적
- 테라폼을 통한 EKS 구성을 쉽게 이해할 수 있도록 돕기 위함

## 작업 순서
1. aws 콘솔 사이트에 로그인
2. 키페어 생성
  - 서비스 -> EC2 -> 네트워크 및 보안 -> 키 페어 -> 키 페어 생성
  - 이름: keypair-for-terraform
  - 키 페어 유형: RSA (기본값 유지)
  - 프라이빗 키 파일 형식: .pem
  - '키 페어 생성' 버튼 클릭
3. 다운로드된 키 페어를 01-eks/private-key 폴더에 복사
4. 키 페어 파일에 대해 chmod 400 권한 설정
```bash
chmod 400 ./01-eks-private/keypair-for-terraform.pem
```

5. terraform remote backend 용 버킷 생성
```bash
# 버킷 생성 (버킷명은 유니크한 이름으로 설정)
# aws s3api create-bucket --bucket <버킷명> --region <지역명> \
#   --create-bucket-configuration LocationConstraint=<지역명>
aws s3api create-bucket --bucket terraform-eks-private --region ap-northeast-2 \
  --create-bucket-configuration LocationConstraint=ap-northeast-2
# 버킷에 폴더 생성
# 01-eks-private 용
aws s3api put-object --bucket terraform-eks-private --key dev/eks-cluster/
# 01-eks-private-lbc 용
aws s3api put-object --bucket terraform-eks-private --key dev/aws-lbc/
```
6. terraform remote backend Lock 테이블 생성
```bash
# 테이블 생성
# 01-eks-private 용
aws dynamodb create-table --table-name terraform-lock-dev-eks-private \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-2
# 01-eks-private-lbc 용
aws dynamodb create-table --table-name terraform-lock-dev-aws-lbc \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-2
```
7. 파일 수정
- 01-eks-private/c1-versions.tf
- 01-eks-private-lbc-install/c1-versions.tf
```bash
# 버킷명 수정
  backend "s3" {
    ...
    # 버킷명 수정 (기존 => 생성한 버킷명)
    bucket = "기존" => "terraform-eks-private"
    ...
  }
```
8. 테라폼 초기화
```bash
cd 01-eks-private
terraform init
```
9. 테라폼 계획 실행
```bash
cd 01-eks-private
terraform plan
```
10. 테라폼 적용
```bash
cd 01-eks-private
terraform apply -auto-approve
```
11. EKS 테스트
```bash
# 1. 프로필 업데이트 (~/.kube/config)
# aws eks update-kubeconfig --region ap-northeast-2 --name <Cluster 명>
aws eks update-kubeconfig --region ap-northeast-2 --name hr-dev-eksdemo1
kubectl get po
```
12. 테라폼 삭제
```bash
terraform destroy -auto-approve
```
