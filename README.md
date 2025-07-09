
# PROVISIONING EKS CLUSTER

## SECTION ONE - A

250 Pods Total.
Pod capacity per node and scale ASG accordingly
28 GB Peak Memory per Node - Choose EC2 instance types with at least 32 GB of memory
Resilient to One AZ Failure	Deploy nodes across at least 3 Availability Zones

🔧 Proposed EKS Configuration
1. Instance Type
Use instances like m5.2xlarge:

vCPU: 8

RAM: 32 GB

Pod Limit: ~58 pods per node (based on EKS ENI limits)

2. Node Count
To support 250 pods, assuming ~58 pods/node:

Minimum needed: 5 nodes

To maintain resilience, spread across 3 AZs and allow for 1 AZ to fail:

Use 6 nodes total: 2 per AZ

This allows operation with 2 AZs (4 nodes) = ~232 pods available (tight fit, but acceptable)

3. Node Group Setup
Use managed node groups

Enable auto-scaling

Set desired capacity = 6, min = 4, max = 8

Deploy across 3 subnets (each in a separate AZ)

4. Pod Networking Consideration
Set max_pods via launch template or use custom networking if needed

Confirm pod density with:

```shell
aws ec2 describe-instance-types --instance-types m5.2xlarge \
  --query "InstanceTypes[].NetworkInfo.MaximumNetworkInterfaces"
```

Use m5.2xlarge nodes (32 GB RAM)

Deploy 6 nodes across 3 AZs

Ensures HA and AZ fault tolerance

Supports ~250 pods total


To allow the administrator to monitor metrics and logs of both the EKS cluster and the applications running on it, you should ensure the following configurations are added:

🔧 Add Monitoring Permissions to the IAM Role
Update the aws_iam_role_policy_attachment block to include:

```hcl
"arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
"arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
This will allow the nodes (and applications via IAM roles or service accounts) to send logs and metrics to Amazon CloudWatch.
```

** Revised IAM Policy Attachment Section


```hcl
resource "aws_iam_role_policy_attachment" "worker_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ])
  role       = aws_iam_role.worker_role.name
  policy_arn = each.value
}
```

📦 Optional: Enable Container Insights
You can also install CloudWatch Container Insights on the cluster with the CloudWatch agent and Fluent Bit.


## SECTION ONE - B

To grant ops-alice view-only permissions within the ops namespace via a role assumable only from a specific IP address, you'll need to do two things:

** 1. Create the IAM Role OpsUser with Trust Policy
This IAM role allows the specified user to assume it, but only from IP 52.94.236.248.

```hcl
resource "aws_iam_role" "ops_user_role" {
  name = "OpsUser"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::1234566789001:user/ops-alice"
      },
      Action = "sts:AssumeRole",
      Condition = {
        IpAddress = {
          "aws:SourceIp" = "52.94.236.248"
        }
      }
    }]
  })
}
```

** 2. Add RBAC Permissions to EKS for Namespace-Scoped View
You'll need to create a Kubernetes Role and RoleBinding to allow view-only access to ops namespace. Example YAML:

```yaml
# ops-viewer-role.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ops
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ops-viewer
  namespace: ops
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "configmaps", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ops-viewer-binding
  namespace: ops
roleRef:
  kind: Role
  name: ops-viewer
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: User
  name: arn:aws:iam::1234566789001:role/OpsUser
  apiGroup: rbac.authorization.k8s.io
```

```sh
kubectl apply -f ops-viewer-role.yaml
```


This setup assumes your IAM role OpsUser is already federated with the EKS cluster via aws-auth ConfigMap.


The connection is made via the annotation of the service account being used as follows:

```yaml
annotations:
  eks.amazonaws.com/role-arn: arn:aws:iam::<account_id>:role/<role_name>
```

This tells EKS to mount temporary AWS credentials for that IAM role into pods using the service account.


## SECTION ONE - C

To allow pods using the order-processor Kubernetes service account to get AWS credentials for accessing the incomingorders S3 bucket, the IAM Roles for Service Accounts (IRSA) will need to be used.

Here's how this capability can be added:

** 1. Add IAM policy for access to the incoming-orders bucket
modules/irsa_policy/main.tf
```hcl
resource "aws_iam_policy" "s3_read_orders" {
  name        = "${var.name}-s3-read-orders"
  description = "Policy to allow access to S3 incoming-orders bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::incomingorders",
          "arn:aws:s3:::incomingorders/*"
        ]
      }
    ]
  })
}
```

** 2. Create IAM role for the Kubernetes service account with trust to EKS OIDC

``hcl
data "aws_iam_openid_connect_provider" "eks" {
  url = var.oidc_url
}

resource "aws_iam_role" "order_processor_role" {
  name = "${var.name}-order-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_url, "https://", "")}:sub" = "system:serviceaccount:default:order-processor"
          }
        }
      }
    ]
  })
}
```
```hcl
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.order_processor_role.name
  policy_arn = aws_iam_policy.s3_read_orders.arn
}
```
** 3. Kubernetes Service Account Manifest
Create this manifest and apply it via kubectl.

order-processor-serviceaccount.yaml
yaml
Copy
Edit
apiVersion: v1
kind: ServiceAccount
metadata:
  name: order-processor
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<order_processor_role>
Replace the ARN with the actual role ARN output from the module.


**********************************************

