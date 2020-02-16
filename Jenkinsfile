pipeline {
  agent any
  stages {
    stage('Execute') {
      steps {
      withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awskey-${Account}"]])
        {
          sh "cd $WORKSPACE"
          sh "chmod +x *sh"
          sh "$WORKSPACE/plugins.sh"
          sh "$WORKSPACE/work.sh $TFAction $Account $ClusterName $Node_Count"
        }
      }
    }
  stage('Clone EKS Jenkins Access Config Repo') {
    when {
      // Only run if "Dynamic" is requested
      expression { params.TFAction == 'apply' }
    }
    steps {
        dir('config') {
            git url: "git@git.ipacc.com:AutomationTooling/eks-jenkins-access-config.git", branch: 'master', credentialsId: 'jenkins_gitlab'
        }
    }
  }
  stage('Download EKS Config') {
    when {
      // Only run if "Dynamic" is requested
      expression { params.TFAction == 'apply' }
    }
    steps {
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awskey-${Account}"]])
      {
        sh "aws eks update-kubeconfig --name eks-${Account}-${ClusterName} --region us-east-1 --kubeconfig ./config/config-eks-${Account}-${ClusterName}"
      }
    }
  }
        stage('git add/commit') {
          when {
            // Only run if "Dynamic" is requested
            expression { params.TFAction == 'apply' }
          }
            steps {
                dir('config'){
                    withCredentials([sshUserPrivateKey(credentialsId: 'jenkins_gitlab', keyFileVariable: 'SSH_KEY')]) {
                        sh 'git config --global user.email "jenkinsdev@aws.kemperi.com"'
                        sh "git add config-eks-${Account}-${ClusterName}"
                        sh 'git commit -m "Added/updated configuration for eks-${Account}-${ClusterName}" --allow-empty'
                        sh('GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push origin master')
                    }
                }
            }
        }
    }
}
