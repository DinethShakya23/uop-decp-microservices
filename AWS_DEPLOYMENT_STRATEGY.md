# Budget-Friendly AWS Deployment Strategy for DECP

## Executive Summary

Deploy your 11 Java microservices + frontend + databases to AWS with estimated **$150-300/month** for a development/production environment using cost-optimized services.

---

## Architecture Overview

### Recommended Approach: **ECS on EC2 Spot Instances**

Best balance of cost, scalability, and management overhead for microservices.

```
Internet Traffic
       │
       ▼
┌─────────────────────────┐
│  CloudFront (CDN)       │  ← Caches static assets
└────────────┬────────────┘
             │
       ┌─────▼──────┐
       │  ALB (NLB)  │  ← Load balancing across AZs
       └─────┬──────┘
             │
     ┌───────┴───────┐
     ▼               ▼
┌──────────────┐ ┌──────────────┐
│ ECS Cluster  │ │ ECS Cluster  │  ← Microservices & RabbitMQ
│ (Spot EC2)   │ │ (Spot EC2)   │
└──────────────┘ └──────────────┘
     │               │
     └───────┬───────┘
             │
    ┌────────▼────────┐
    │  Shared RDS/   │  ← PostgreSQL + MongoDB
    │  DocumentDB    │
    └─────────────────┘
```

---

## Cost Breakdown (Monthly Estimates)

| Component                   | Service                          | Instance/Config            | Monthly Cost       |
| --------------------------- | -------------------------------- | -------------------------- | ------------------ |
| **Compute**                 | EC2 Spot (t3.large, 2 instances) | 2 x t3.large               | $50-70             |
| **Container Orchestration** | ECS (managed)                    | Fargate overlay            | ~$10               |
| **Database - SQL**          | RDS PostgreSQL                   | db.t3.micro (1 year RI)    | $35-45             |
| **Database - NoSQL**        | DocumentDB                       | db.t3.small (1 year RI)    | $40-50             |
| **Cache**                   | ElastiCache Redis                | cache.t3.micro (1 year RI) | $20-25             |
| **Message Queue**           | MQ (RabbitMQ)                    | Single broker (t3.micro)   | $30-40             |
| **Load Balancer**           | Application LB                   | Standard tier              | $20-25             |
| **Storage**                 | EBS + S3                         | 20GB GP3 + 5GB S3          | $5-10              |
| **Data Transfer**           | CloudFront + NAT                 | 100GB egress               | $15-20             |
| **Monitoring**              | CloudWatch                       | Basic monitoring           | $5-10              |
| **DNS**                     | Route 53                         | Hosted zone + queries      | $5-10              |
| **WAF**                     | AWS WAF (optional)               | Basic protection           | $5-10              |
| **TOTAL**                   |                                  |                            | **$220-305/month** |

**Savings opportunities:**

- Use **1-year or 3-year Reserved Instances**: Save 40-60% on compute/database
- Use **Spot Instances**: Save 70% on EC2 (but accept interruption risk—use 2+ instances)
- Use **RDS Free Tier** for first 12 months (dev accounts)
- Consolidate RabbitMQ into ECS instead of separate AWS MQ

---

## Deployment Options Comparison

### Option 1: **ECS + Spot EC2** ⭐ RECOMMENDED

**Cost:** $150-250/month | **Complexity:** Medium | **Scalability:** ⭐⭐⭐⭐

✅ **Pros:**

- Native Docker support via ECS
- Spot instances = 70% savings
- Auto-scaling by CPU/memory
- No Kubernetes overhead

❌ **Cons:**

- Spot instances can be interrupted
- More manual operational overhead than EKS

**Best for:** Startups, MVPs, cost-conscious teams

---

### Option 2: **AWS AppRunner** (Simpler)

**Cost:** $250-400/month | **Complexity:** Low | **Scalability:** ⭐⭐⭐

✅ **Pros:**

- Simplest to deploy (GitHub auto-deploy)
- No infrastructure management
- Auto-scaling included
- Pay per container

❌ **Cons:**

- More expensive than ECS
- Less control over compute

**Best for:** Teams prioritizing simplicity over cost

---

### Option 3: **EKS (Kubernetes)**

**Cost:** $300-500+/month | **Complexity:** High | **Scalability:** ⭐⭐⭐⭐⭐

✅ **Pros:**

- Industry standard orchestration
- Multi-cloud portability
- Best long-term scalability

❌ **Cons:**

- Expensive ($0.10/hour cluster fee)
- Steep learning curve
- Overkill for current size

**Best for:** Large teams, complex requirements, multi-region

---

## Recommended Stack: ECS + Spot EC2

### Phase 1: Initial Setup (Week 1-2)

#### 1. **Database Setup**

```bash
# RDS PostgreSQL
- db.t3.micro with 1-year RI
- Automated backups: 7 days
- Multi-AZ: No (for cost)

# DocumentDB or MongoDB Atlas
- db.t3.small
- Replica set (2 nodes minimum for HA)

# ElastiCache Redis
- cache.t3.micro
- Single node or with automatic failover
```

#### 2. **AWS MQ Setup (Option A: Managed RabbitMQ)**

```
- Single broker: mq.t3.micro
- Cost: $30-40/month
- Alternative: Run RabbitMQ in ECS container (saves $30-40)
```

#### 3. **Container Registry**

```bash
# ECR (Elastic Container Registry)
- Push your 11 microservice images
- Lifecycle policy: Keep 10 images, delete old ones
- Cost: ~$0.50 per month (storage-based)
```

### Phase 2: ECS Cluster Configuration

#### **Cluster Setup**

```yaml
Cluster: decp-production
Launch Type: EC2 + Spot
Auto Scaling: Enabled

Instances:
  - 2x t3.large (Spot) = $50-70/month
  - IAM Role: ECS auto-scaling + parameter store access

Auto Scaling Group:
  - Min: 2 instances
  - Target: 4 instances
  - Max: 6 instances
  - Scale up on: 70% CPU
  - Scale down on: 30% CPU
```

#### **Task Definitions** (11 services)

```dockerfile
# Example: auth-service
Memory: 512 MB
CPU: 256 (0.25 vCPU)
Container port: 8081

# Logging
CloudWatch Logs: /ecs/decp/auth-service
Retention: 7 days (cost optimization)
```

**Sizing by service:**

```
Light services (Auth, Gateway):    512 MB / 256 CPU
Medium services (User, Job, Event): 768 MB / 512 CPU
Heavy services (Analytics):        1024 MB / 512 CPU
Databases/Cache/Queue:            Run in ECS (container)
```

### Phase 3: Load Balancing & Routing

```
ALB (Application Load Balancer)
├── Target Group 1: API Gateway (port 8080)
├── Target Group 2: Frontend (CloudFront)
└── Health checks: Every 30 sec

Cost: $20-25/month
```

---

## Implementation Roadmap

### **Week 1: Infrastructure**

- [ ] Create RDS PostgreSQL
- [ ] Create DocumentDB cluster
- [ ] Create ElastiCache Redis
- [ ] Create AWS MQ RabbitMQ broker
- [ ] Create ECR repositories

### **Week 2: Containerization & Push**

- [ ] Build all 11 microservice Docker images
- [ ] Push to ECR
- [ ] Create ECS task definitions
- [ ] Set up CloudWatch logs

### **Week 3: ECS Cluster & Deployment**

- [ ] Create EC2 launch template (AMI: ECS-optimized)
- [ ] Create Auto Scaling Group
- [ ] Create ECS services (11 + RabbitMQ in ECS)
- [ ] Configure task placement strategies
- [ ] Test service discovery (AWS CloudMap)

### **Week 4: Networking & Frontend**

- [ ] Create ALB + target groups
- [ ] Set up Route 53 DNS
- [ ] Deploy React frontend to S3 + CloudFront
- [ ] Configure CORS, security groups
- [ ] Set up HTTPS (ACM certificates)

### **Week 5: Testing & Optimization**

- [ ] Load testing (Apache JMeter)
- [ ] Cost optimization review
- [ ] Set up CloudWatch dashboards & alarms
- [ ] Document runbooks for ops team

---

## Cost Optimization Checklist

- [ ] **Use Spot Instances** (save 70% on EC2) — accept 2-5 min interruption time
- [ ] **Apply Reserved Instances** (1-year) on RDS/ElastiCache — save 40-50%
- [ ] **Consolidate queue/cache** in ECS instead of managed services for initial phase
- [ ] **Auto-scale based on metrics** — scale down at night if app is internal
- [ ] **Use S3 Intelligent-Tiering** for logs/backups
- [ ] **Enable AWS Cost Explorer** — set budgets & alerts at $300/month
- [ ] **Use Spot Fleet** for secondary app tier (if multi-tier)
- [ ] **Cleanup old snapshots/volumes** — lifecycle policies
- [ ] **Use CloudFront** for static assets — reduces data transfer costs by 80%
- [ ] **Enable VPC Flow Logs sparingly** — can add $50-100/month

---

## Network Diagram

```
                    Route 53
                      │
              ACM Certificate
              (HTTPS)  │
                       ▼
               ┌──────────────┐
               │ CloudFront   │
               │ (CDN)        │
               └────────┬─────┘
                        │
                  ┌─────▼─────┐
                  │    ALB    │
                  │ (port 80) │
                  └─────┬─────┘
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐
    │ API GW   │ │ Services │ │ RabbitMQ │
    │ (ECS)    │ │ (ECS)    │ │ (ECS)    │
    └──────────┘ └──────────┘ └──────────┘
          │           │           │
          └───────────┼───────────┘
                      │
          VPC Subnet (Private)
                      │
    ┌─────────────────┼──────────────────┐
    ▼                 ▼                   ▼
 ┌────────┐      ┌──────────┐      ┌──────────┐
 │  RDS   │      │DocumentDB│      │ Redis    │
 │(Multi- │      │(Replica) │      │(Single)  │
 │AZ)     │      └──────────┘      └──────────┘
 └────────┘
```

---

## Terraform/CDK Quick Start

### **Example: Production Deployment with Terraform**

```hcl
# variables.tf
variable "environment" { default = "production" }
variable "instance_type" { default = "t3.large" }
variable "spot_price" { default = "0.05" }  # $0.05/hr

# main.tf
# VPC + Subnets
resource "aws_vpc" "decp" {
  cidr_block = "10.0.0.0/16"
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier     = "decp-postgres"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.micro"
  allocated_storage = 50
  storage_type   = "gp3"
  skip_final_snapshot = false

  tags = { Name = "decp-postgres" }
}

# ECS Cluster
resource "aws_ecs_cluster" "decp" {
  name = "decp-production"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# EC2 Auto Scaling Group (Spot Instances)
resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity = 2
  max_size         = 6
  min_size         = 2

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools = 2
    }
  }
}
```

---

## Monitoring & Alerts (Setup CloudWatch)

```
Create Dashboards:
├── Cluster Health (CPU, Memory, Task count)
├── Service Performance (Response time, Error rate)
├── Database Metrics (Connections, Query time)
├── Cost Analysis (Daily spend, forecasts)

Alarms:
├── High CPU (> 80% for 5 min)
├── High Memory (> 85% for 5 min)
├── RDS Connection exhaustion
├── Error rate spike (> 5%)
└── Monthly cost > $300
```

---

## Migration Path: On-Premise → AWS

### Current State

```
docker-compose.yml (local or VM)
├── 11 Java microservices
├── PostgreSQL
├── MongoDB
├── Redis
├── RabbitMQ
└── React frontend (port 3000)
```

### Step 1: Containerize (Already done ✓)

- Dockerfiles exist for all services
- Use existing docker-compose.yml as reference

### Step 2: Push to AWS ECR

```bash
aws ecr create-repository --repository-name decp-auth
docker tag decp-auth:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/decp-auth:latest
docker push ...
```

### Step 3: RDS Migration

```bash
# Export from local PostgreSQL
pg_dump decp_db > dump.sql

# Import to RDS
mysql -h decp-postgres.us-east-1.rds.amazonaws.com -u admin < dump.sql
```

---

## Security Best Practices

- [ ] **VPC:** Private subnets for databases + RabbitMQ
- [ ] **Security Groups:** Restrict traffic between services
- [ ] **RDS Encryption:** Enable at-rest encryption (add $2-5/month)
- [ ] **Secrets Manager:** Store DB passwords (pay per secret: $0.40/month)
- [ ] **WAF:** Protect ALB from common attacks (~$5/month)
- [ ] **VPC Endpoints:** For S3 access (avoid NAT gateway costs)
- [ ] **SSL/TLS:** ACM certificates (free)

---

## Next Steps

1. **Review** this strategy with team
2. **Set up AWS Account** with billing alerts at $250-300/month threshold
3. **Create pilot RDS** to test data migration
4. **Push Docker images** to ECR
5. **Deploy ECS services** to staging first
6. **Run load tests** to validate sizing
7. **Cut over** to production

---

## Additional Resources

- **AWS Pricing Calculator:** https://calculator.aws
- **ECS Best Practices:** https://docs.aws.amazon.com/AmazonECS
- **Cost Optimization Guide:** https://aws.amazon.com/solutions/ec2-spot
- **RDS Instance Sizing:** https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass

---

## Questions?

For detailed setup of any component, let me know and I'll provide step-by-step instructions.
