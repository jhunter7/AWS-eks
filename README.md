# EKS Getting Started Guide Configuration

This project was based on the following documentation: [eks-getting-started guide](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)

Networking plan can be found [here](https://git.ipacc.com/AutomationTooling/terraform-eks-subnets)

### Related Jenkins Jobs
#### Creation/Application
* [eks_subnet_setup](http://jenkinsdev.svc.aws.kemperi.com:8080/job/svc/job/t0/job/coreinfrastructure/job/eks/job/eks_subnet_setup)
  * _Parameters_
  (Action,Account,ClusterName, Node Count)
* [eks-setup](http://jenkinsdev.svc.aws.kemperi.com:8080/job/svc/job/t0/job/coreinfrastructure/job/eks/)
  * _Parameters_
(Action,Account)
* [Sample Springboot Pipeline](https://jenkinsbuild.ipacc.com/job/devops-sample-springboot-pipeline/build)
  *  _Parameters_
(Action, Account, ClusterName, Namespace)
* [Sample Application](https://git.ipacc.com/AutomationTooling/sample-springboot-app) Source Code Example

### Testing/Validation
* [ClusterInfo](https://jenkinsbuild.ipacc.com/job/kubeutil/job/ClusterInfo/): Describes the cluster in some detail. Think logs...
* [DescribePods](https://jenkinsbuild.ipacc.com/job/kubeutil/job/DescribePods/): Describe the pods able to run containers.
* [GetDeployments](https://jenkinsbuild.ipacc.com/job/kubeutil/job/GetDeployments/): Will show the deployments on the cluster.
* [GetEvents](https://jenkinsbuild.ipacc.com/job/kubeutil/job/GetEvents/): Log data from cluster.
* [GetIngress](https://jenkinsbuild.ipacc.com/job/kubeutil/job/GetIngress/): Will display the ingress URL.
## Versions
Versioning: Major.Minor.Feature.Hotfix

1.1.2.4 update variable instance size

1.1.2.3 enhanced the existing security groups to include the svc and build jenkins servers.

1.1.2.2  Modified the subnet search in the work.sh

1.1.2.1 Expanded the subnet search in the terraform plan

1.1.2.0 Expand filter for subnet discovery

1.1.1.1 Removed internal subnet and routing to a seperate job.

1.1.1.0 Storing EKS Access Configuration in Git

1.1.0.7 Fixed rolearn: arn:aws:iam::252255005674:role/npd-us-east-1-EKSAdminRole in outputs.tf

1.1.0.6 Properly readding environment this time

1.1.0.5 Faking a tag because Lambda

1.1.0.4 Removing lab hard coding from outputs.tf

1.1.0.3 A cursed release we shall not speak of.

1.1.0.2 The last functional release.

1.1.0.1 Split TF state out into multiple buckets and cluster specific tfstate file

1.1.0.0 Generic code to spin up multiple clusters. Factored out environment.

1.0 Initial functional Terraform. Used for the P8 cluster.
