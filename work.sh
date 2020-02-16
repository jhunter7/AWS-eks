TERRAFORM_PATH=/var/lib/jenkins/tools/org.jenkinsci.plugins.terraform.TerraformInstallation/Terraform/
export PATH=$PATH:~
# if [ ! -f "~/terraform" ]; then
#     echo "Install terraform"
#     curl -o ~/terraform_0.12.12_linux_amd64.zip http://artifactory.kemperi.com:8081/artifactory/kemper-artifacts-vendor/com/terraform_0.12.12_linux_amd64.zip
#     unzip -d ~/ ~/terraform_0.12.12_linux_amd64.zip
#     rm ~/terraform_0.12.12_linux_amd64.zip
# fi

cd $WORKSPACE
ACTION=$1
ACCOUNT=$2
CLUSTER_NAME=$3
NODE_COUNT=$4

# If the account does not exist the first comand will create the workspace and switch to it.
# Otherwise the second command will execute and switch to the named workspace
WORKSPACE="${ACCOUNT}-${CLUSTER_NAME}"

echo "Switch to ${WORKSPACE}"
terraform init \
  -backend-config="key=terraform/eks.tfstate" \
  -backend-config="bucket=kemper-s3-$ACCOUNT-terraform-state-t0" \
  -backend-config="dynamodb_table=terraform-state-lock-dynamo" \
  -no-color
terraform workspace new $WORKSPACE -no-color  2>/dev/null || terraform workspace select $WORKSPACE -no-color
REGION="us-east-1"
# Search for EKS subnets
SUBNETS=$(for subnetid in $(aws ec2 describe-subnets --region ${REGION} --filters Name=tag:Name,Values=${ACCOUNT}-${REGION}-pri-eksaz* --query 'Subnets[*].[SubnetId]' --output text); do printf $subnetid && printf " "; done)

case $ACTION in
  'plan')
    terraform workspace list -no-color
    terraform plan -out=tfplan -input=false -no-color -var="application=$CLUSTER_NAME" -var="node_count=$NODE_COUNT"
    # terraform graph -type=plan >graph-$ACCOUNT-$CLUSTER_NAME-$ENV.dot
    ;;

  'apply')
    terraform workspace list -no-color

    # We manage the tags externally to terraform
    # echo "SUBNETS: ${SUBNETS}"
    # echo "aws ec2 create-tags --resources $SUBNETS --tags "Key=\"kubernetes.io/role/internal\",Value="1"  "Key=\"kubernetes.io/cluster/eks-${ACCOUNT}-${CLUSTER_NAME}\",Value=\"shared\"" --region ${REGION}"
    aws ec2 create-tags --resources $SUBNETS --tags Key="kubernetes.io/role/internal-elb",Value="1" --region ${REGION}
    aws ec2 create-tags --resources $SUBNETS --tags Key="kubernetes.io/cluster/eks-${ACCOUNT}-${CLUSTER_NAME}",Value="shared" --region ${REGION}
    # aws ec2 create-tags --resources $SUBNETS --tags Key="kubernetes.io/role/internal",Value="1" Key="kubernetes.io/cluster/eks-${ACCOUNT}-${CLUSTER_NAME}",Value="shared" --region ${REGION}

    terraform plan -out=tfplan -input=false -no-color -var="application=$CLUSTER_NAME" -var="node_count=$NODE_COUNT"
    terraform apply -input=false -no-color tfplan

    terraform output config_map_aws_auth -no-color | tee config_map_aws_auth.yaml

    echo "aws eks update-kubeconfig --name eks-${ACCOUNT}-${CLUSTER_NAME} --region ${REGION}"
    aws eks update-kubeconfig --name eks-${ACCOUNT}-${CLUSTER_NAME} --region ${REGION}

    echo 'kubectl apply -f config_map_aws_auth.yaml'
    kubectl apply -f config_map_aws_auth.yaml

    echo 'kubectl apply -f rbac-role.yaml'
    kubectl apply -f rbac-role.yaml

    echo 'terraform output alb-ingress-controller -no-color > alb-ingress-controller.yaml'
    terraform output alb-ingress-controller -no-color > alb-ingress-controller.yaml
    mkdir -p ~/.kube
    ls ~/.kube
    cat ~/.kube/config
    echo 'terraform output kubeconfig -no-color > kubeconfig'
    terraform output kubeconfig -no-color > kubeconfig
    echo 'kubectl apply -f alb-ingress-controller.yaml'
    kubectl apply -f alb-ingress-controller.yaml

    #Tiller install. This can be removed after we roll out Helm 3.
    echo 'kubectl apply -f tiller-install.yaml'
    kubectl --validate=false apply -f tiller-install.yaml

      ;;

  'refresh')
    echo 'terraform refresh -input=false -no-color -var="application=$CLUSTER_NAME" -var="node_count=$NODE_COUNT"'
    terraform refresh -input=false -no-color -var="application=$CLUSTER_NAME" -var="node_count=$NODE_COUNT"
    ;;

  'destroy')
    echo 'terraform destroy -input=false -no-color --auto-approve'
    terraform destroy -input=false -no-color --auto-approve -var="application=$CLUSTER_NAME" -var="node_count=$NODE_COUNT"
    ;;

  'output')
    echo 'get config_map_aws_auth'
    terraform output config_map_aws_auth -no-color | tee config_map_aws_auth.yaml
    echo 'terraform output kubeconfig -no-color > kubeconfig'
    terraform output kubeconfig -no-color > kubeconfig
    echo "aws eks update-kubeconfig --name eks-${ACCOUNT}-${CLUSTER_NAME} --region ${REGION}"
    aws eks update-kubeconfig --name eks-${ACCOUNT}-${CLUSTER_NAME} --region ${REGION}
    echo 'kubectl apply -f config_map_aws_auth.yaml'
    kubectl apply -f config_map_aws_auth.yaml
    ;;
  'status')
    echo "Get contexts"
    kubectl config get-contexts
    kubectl config current-context
    echo "Get services"
    kubectl get svc
    echo "Get Nodes"
    kubectl get nodes
    echo "List Pods"
    kubectl get pods --all-namespaces
    echo "Describe auth"
    kubectl describe cm aws-auth -n kube-system
    ;;
  *)
    echo "Pick a valid action."
    exit 1
    ;;
esac
