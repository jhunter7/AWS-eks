TERRAFORM_PATH=/var/lib/jenkins/tools/org.jenkinsci.plugins.terraform.TerraformInstallation/Terraform/
export PATH=$PATH:~

cd /var/lib/jenkins
if [ ! -x "terraform" ]; then
  echo "Install terraform"
  if [ ! -f terraform_0.12.16_linux_amd64.zip ]; then
    curl -o ~/terraform_0.12.16_linux_amd64.zip http://artifactory.kemperi.com:8081/artifactory/kemper-artifacts-vendor/com/terraform_0.12.16_linux_amd64.zip
  fi
  unzip -d . terraform_0.12.16_linux_amd64.zip
  chmod +x terraform
fi
# Lets make sure the directory exists
#

mkdir -p ~/.terraform.d/plugin

# Check if the terraform aws provider is downloaded or not and take appropriate action
#
if [ -e ~/terraform-provider-aws_2.33.0_linux_amd64.zip ]; then
    echo 'terraform-provider-aws_2.33.0_linux_amd64.zip already downloaded' >&2
else
    curl http://artifactory.kemperi.com:8081/artifactory/terraform-plugins/terraform-provider-aws/2.33.0/terraform-provider-aws_2.33.0_linux_amd64.zip > ~/terraform-provider-aws_2.33.0_linux_amd64.zip
fi

# Check if it was extracted
if [ -e ~/.terraform.d/plugins/terraform-provider-aws_v2.33.0_x4 ]; then
    echo 'The terraform aws provider is already installed' >&2
else
    echo 'Install the terraform aws provider is already installed' >&2
    unzip -o ~/terraform-provider-aws_2.33.0_linux_amd64.zip -d  ~/.terraform.d/plugins
fi

# Check if the terraform aws provider is downloaded or not and take appropriate action
#
if [ -e ~/terraform-provider-http_1.1.1_linux_amd64.zip ]; then
    echo 'terraform-provider-http_1.1.1_linux_amd64.zip already downloaded' >&2
else
    curl http://artifactory.kemperi.com:8081/artifactory/terraform-plugins/terraform-provider-http/1.1.1/terraform-provider-http_1.1.1_linux_amd64.zip > ~/terraform-provider-http_1.1.1_linux_amd64.zip
fi

# Check if it was extracted
if [ -e ~/.terraform.d/plugins/terraform-provider-http_v1.1.1_x4 ]; then
    echo 'The terraform http provider is already installed' >&2
else
    echo 'Install the terraform http provider is already installed' >&2
    unzip -o ~/terraform-provider-http_1.1.1_linux_amd64.zip -d  ~/.terraform.d/plugins
fi

# Check if the terraform null provider is downloaded or not and take appropriate action
#
if [ -e ~/terraform-provider-null_2.1.2_linux_amd64.zip ]; then
    echo 'terraform-provider-null_2.1.2_linux_amd64.zip already downloaded' >&2
else
    curl http://artifactory.kemperi.com:8081/artifactory/terraform-plugins/terraform-provider-null/2.1.2/terraform-provider-null_2.1.2_linux_amd64.zip > ~/terraform-provider-null_2.1.2_linux_amd64.zip
fi
# Check if it was extracted
if [ -e ~/.terraform.d/plugins/terraform-provider-null_2.1.2_x4 ]; then
    echo 'The terraform null provider is already installed' >&2
else
    echo 'Install the terraform null provider is already installed' >&2
    unzip -o ~/terraform-provider-null_2.1.2_linux_amd64.zip -d  ~/.terraform.d/plugins
fi

# Check if the terraform null provider is downloaded or not and take appropriate action
#
if [ -e ~/terraform-provider-external_1.2.0_linux_amd64.zip ]; then
    echo 'terraform-provider-external_1.2.0_linux_amd64.zip already downloaded' >&2
else
    curl http://artifactory.kemperi.com:8081/artifactory/terraform-plugins/terraform-provider-external/1.2.0/terraform-provider-external_1.2.0_linux_amd64.zip > ~/terraform-provider-external_1.2.0_linux_amd64.zip
fi
# Check if it was extracted
if [ -e ~/.terraform.d/plugins/terraform-provider-external_v1.2.0_x4 ]; then
    echo 'The terraform null provider is already installed' >&2
else
    echo 'Install the terraform null provider is already installed' >&2
    unzip -o ~/terraform-provider-external_1.2.0_linux_amd64.zip -d  ~/.terraform.d/plugins
fi
