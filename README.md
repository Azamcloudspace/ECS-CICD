#  ECS-CICD

##  Project Summary

Designed and implemented a production-grade CI/CD system for deploying a containerized microservices application on AWS. This solution demonstrates end-to-end DevOps capabilities including automated infrastructure provisioning, multi-environment deployment, and zero-downtime application delivery.

---

##  Key Outcomes

- Built fully automated CI/CD pipelines for infrastructure and application delivery  
- Implemented Infrastructure as Code using CloudFormation  
- Deployed containerized microservices using ECS Fargate  
- Designed a multi-environment deployment strategy (dev, staging, prod)  
- Achieved zero-downtime deployments using rolling update strategy  
- Established a decoupled, scalable microservices architecture  

---

##  Architecture Overview

### Application Design

The system is composed of three loosely coupled services:

- **Frontend Service**  
  Nginx-based UI serving static content and interacting with backend services  

- **API Service**  
  Python Flask application exposing:
  - `/api/health` for service validation  
  - `/api/job` for publishing jobs to a queue  

- **Worker Service**  
  Background processor consuming messages from a queue and executing tasks  

**Design Decision:**  
Adopted asynchronous communication using SQS to decouple services, improving fault tolerance and system resilience.

---

### Infrastructure Design

Provisioned using modular CloudFormation templates:

- Custom VPC with public and private subnets across multiple Availability Zones  
- ECS Fargate for serverless container orchestration  
- Application Load Balancer for intelligent traffic routing  
- Amazon ECR for container image storage  
- Amazon SQS for asynchronous messaging  

![Architecture](/screenshots/Architecture.jpeg)

---

##  CI/CD Pipeline Architecture

### Infrastructure Pipeline

Responsible for provisioning environments and CI/CD resources.

**Workflow:**

```
CodePipeline → GitHub(Source) → CodeBuild(Build) → CloudFormation 
 ```

**Capabilities:** 

**Codepipeline**

- Integrates with services such as GitHub and CodeBuild
- Automatically triggers and executes workflows
- Uses manual approval gates to control promotion between stages
- Implements properly structured IAM permissions across services

**GitHub**

- Repository (Source)

**CodeBuild**

Mutiple Codebuild services are used for the different environments with their individual builspec.yml i.e `dev-buidspec.yml`, `staging-buildspec.yml`, and
`prod-buildspec.yml` respectively , their capabilities are : 

- Authenticates Docker to Amazon ECR to allow image pushes
- Defines REpository URIs
- Generates image tags which will later on be used as parameters for cloudformation templates
- Creates Cloudformation parameter files
- Uploads all nested CloudFormation templates to an S3 bucket for stack referencing
- Deploys the ECR CloudFormation stack template
- Builds and pushes all built images to their respective ECR repositories
- Deploys the main master CloudFormation stack template
- Implements properly structured IAM permissions across services

**Cloudformation**
- Provisions ECR stack template resources 
- Provisions main master stack's child stacks template resources 
- Outputs are exported from ECR stack and Imported by main master stack   


![Pipeline](/screenshots/Screenshot1.png)
Infrastructure Pipeline

---

### Application Pipelines

Dedicated pipelines per environment handling application delivery.

**Workflow:**

```
Pipeline → GitHub(Source) → CodeBuild(Build) → CodeBuild(Test) ECS Service Update(Deploy)
```

**Responsibilities:**

**Codepipeline**

- Integrates with services such as GitHub and CodeBuild
- Automatically triggers and executes workflows
- Uses manual approval gates to control promotion between stages
- Implements properly structured IAM permissions across services

**GitHub**

- Repository (Source)

**CodeBuild(Build)**

Mutiple Codebuild services are used for the different environments with their individual builspec.yml i.e `dev-update-buidspec.yml`, `staging-update-buildspec.yml`, and
`prod-update-buildspec.yml` respectively , their capabilities are :

- Authenticates Docker to Amazon ECR to allow image pushes
- Defines Repository URI i.e frontend repository specifically
- Generates image tag
- Builds and pushes built image to ECR repository
- Creates an imagedefinitions file that will be used for ECS Update 

**CodeBuild(Test)**

Mutiple Codebuild services are used for the different environments with their individual builspec.yml i.e `dev-buidspec-test.yml`, `staging-buildspec-test.yml`, and
`prod-buildspec-test.yml` respectively , their capabilities are :

- Verifies that the file front-update.html exists in the specified directory
- Checks that the file is not empty (has content)
- Outputs a confirmation message if both checks pass


**ECS(Deploy)**

- Deployment to ECS via imagedefinition file 

![Pipeline](/screenshots/Screenshot5.png)
Application Pipeline (prod environment)

---

##  Deployment Lifecycle

### Initial Provisioning 

Infrastructure Pipeline  
→ CloudFormation Deployment  
→ Resources Created (VPC, Alb, ECS, IAM, ECR, SQS, Application Pipeline)
→ A working Web Application routed via ALB

![Deployment](/screenshots/Screenshot3.png)
Cloudformation Deployment (Prod Environment)

![Deployment](/screenshots/Screenshot2.png)
ECR showing repositories 

![Deployment](/screenshots/Screenshot4.png)
Frontend Repository Showing Images (Prod Environment)

![Deployment](/screenshots/Screenshot6.png)
Ecs Cluster Showing Ecs Services (Prod Environment)

![Deployment](/screenshots/Screenshot7.png)
ALB showing properties including DNS name (prod environment)

![Deployment](/screenshots/Screenshot8.png)
Working web application (prod environment)

### Continous Delivery 

1. Code changes pushed to source repository  
2. Pipeline execution is automatically triggered  
3. Docker images are built and pushed to ECR  
4. ECS services are updated with new image versions  
5. ALB health checks validate new tasks  
6. Traffic is routed only to healthy containers  

![CICD](/screenshots/Screenshot9.png)
Pipeline Release (prod environment)

![CICD](/screenshots/Screenshot10.png)
New Image Pushed to Frontend Repository (prod environment)

![CICD](/screenshots/Screenshot11.png)
Ecs Service event showing Ecs Service update (prod environment)

![CICD](/screenshots/Screenshot12.png)
Updated Web Application (prod environment)

---

##  Deployment Strategy

- **Type:** Rolling Deployment  
- **Platform:** ECS Fargate  
- **Outcome:** Zero-downtime deployments ensured through health checks and controlled task replacement  

---

##  Repository Structure

├── app/
│ ├── api/
│ ├── frontend/
│ └── worker/
├── ci/
├── cloudformation/
│ ├── child-templates/
│ ├── infrastructure-pipeline/
│ └── master/

---

##  Automation

- Build processes defined via `buildspec.yml`  
- Environment-specific build configurations for isolated deployments  
- Automated Docker build and registry push workflows  

---

##  Monitoring & Observability

- CloudWatch Logs for application and container visibility  
- ALB health checks for runtime validation  
- Pipeline execution monitoring via CodePipeline  

![Monitoring](/screenshots/Screenshot13.png)
ALB Health checks (prod environment)

![Monitoring](/screenshots/Screenshot13.png)
Frontend service Log events (prod envrionment)

---

##  Security Implementation

- IAM roles scoped with least privilege  
- Private subnet isolation for ECS services  
- ALB configured as the only public access point  
- No hardcoded credentials; access managed via IAM roles  

---

##  DevOps Capabilities Demonstrated

- CI/CD pipeline design and automation  
- Infrastructure as Code (CloudFormation)  
- Container orchestration and lifecycle management  
- Multi-environment deployment strategy  
- High availability and fault-tolerant system design  

---

##  Challenges & Resolutions  

- **Cross-environment image conflicts**  
  Resolved by isolating container repositories per environment  

---

##  Future Enhancements

- Implement Blue/Green deployments using CodeDeploy  
- Introduce auto-scaling policies for ECS services  
- Add alerting and monitoring (CloudWatch Alarms)  
- Integrate distributed tracing (AWS X-Ray)  
- Implement centralized observability stack  

---

##  Conclusion

This project reflects practical DevOps engineering capabilities, focusing on automation, scalability, and reliability. It demonstrates the ability to design and implement production-ready systems aligned with modern cloud and DevOps best practices.
