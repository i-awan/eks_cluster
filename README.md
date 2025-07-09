** Key Requirements
Requirement	Design Implication
250 Pods Total	Plan pod capacity per node and scale ASG accordingly
28 GB Peak Memory per Node	Choose EC2 instance types with at least 32 GB of memory
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

aws ec2 describe-instance-types --instance-types m5.2xlarge \
  --query "InstanceTypes[].NetworkInfo.MaximumNetworkInterfaces"


Use m5.2xlarge nodes (32 GB RAM)

Deploy 6 nodes across 3 AZs

Ensures HA and AZ fault tolerance

Supports ~250 pods total



To allow the administrator to monitor metrics and logs of both the EKS cluster and the applications running on it, you should ensure the following configurations are added:

🔧 Add Monitoring Permissions to the IAM Role
Update the aws_iam_role_policy_attachment block to include:

hcl
Copy
Edit
"arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
"arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
This will allow the nodes (and applications via IAM roles or service accounts) to send logs and metrics to Amazon CloudWatch.

** Revised IAM Policy Attachment Section
In your modules/worker/main.tf, revise this block:

hcl
Copy
Edit
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


📦 Optional: Enable Container Insights
You can also install CloudWatch Container Insights on the cluster with the CloudWatch agent and Fluent Bit.