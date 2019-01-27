#!/bin/bash

banner() {
  echo ""
  echo "********************************************************************************"
  echo "*"
  echo "* $@ "
  echo "*"
  echo "********************************************************************************"
  echo ""
}

msg() {
  echo "$@"
}

error() {
  msg "ERROR: $@"
}

info() {
  echo -n "$@"
}

usage(){
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --help,    -h                      Display help information."
  echo "  --verbose, -v                      Be verbose."
  echo "  --region,  -r <Region name>        AWS region name to use, default is us-west-2 (Oregon, US)."
  echo "  --key,     -k <Access key>         AWS Access key. This is the mandatory option!"
  echo "  --secret,  -s <Secret access key>  AWS Secret access key. This is the mandatory option!"
  echo "  --quiet,   -q                      Be quiet, i.e. send standard output to /dev/null. Not recommended."
  echo
  echo "Note:"
  echo "  you may set AWS Access key, Secret access key, and Region by exporting appropriate environment variables."
}

parse_arguments() {
  if [ $# -ne 0 ]; then
    while [ $# -gt 0 ]; do
      case $1 in
        '--help'    | '-h' ) usage; exit 0 ;;
        '--verbose' | '-v' ) verbose=true ;;
        '--region'  | '-r' ) export TF_VAR_aws_region=$2; shift ;;
        '--key'     | '-k' ) export AWS_ACCESS_KEY=$2; shift ;;
        '--secret'  | '-s' ) export AWS_SECRET_ACCESS_KEY=$2; shift ;;
        '--quiet'   | '-q' ) quiet=true ;;
        *) error "Unknown opiton: $1!"; usage; exit -1 ;;
      esac
      shift
    done
  elif [ -z "$AWS_ACCESS_KEY" -o -z "$AWS_SECRET_ACCESS_KEY" ]; then
    error "Please provide command arguments!"
    usage; exit -1
  fi
}

show() {
  # Run the command only if the 'quiet' mode is not set.
  if [ ! "$quiet" == "true" ]; then
    if [ ! -z "$1" ]; then
      $@
    fi
  fi
}

execute() {
  # Execute the command; hide the command output if the 'quiet' mode is set.
  # As the first argument is takes an info message, all the rest are command and its options
  if [ ! -z "$1" ]; then
    if [ "$quiet" == "true" ]; then
      shift; $@ >/dev/null
    else
      info "$1: "; shift; $@ && msg "done."
    fi
  fi
}

preflight_checks() {
  # Any subsequent commands which fail will cause the shell script to exit immediately
  set -e

  # Check if AWS environment variables are defined
  if [ -z "$TF_VAR_aws_region" ]; then
    if [ -z "$AWS_REGION" ]; then
      export TF_VAR_aws_region="us-west-2"
    else
      export TF_VAR_aws_region="$AWS_REGION"
    fi
  fi
  if [ -z "$AWS_ACCESS_KEY" -o -z "$AWS_SECRET_ACCESS_KEY" ]; then
    error "The '--key' and '--secret' options are mandatory!"
    exit -1
  fi

  # Check Terraform configuration
  # Check Ansible configuration with ansible-lint
  TF_PLAN=terraform.plan
  /bin/rm -f $TF_PLAN
  execute "Validating Terraform config" terraform validate terraform && \
  execute "Validating Ansible config (takes up to a minute)" \
          ./scripts/check.sh -q -g -la -a -p provision.yml -i inventory -d roles/internal && \
  show terraform plan -out $TF_PLAN terraform && \
  show terraform show $TF_PLAN && \
  msg "Hit the Enter key to continue." && read
}

provisioning() {
  banner "Provisioning infrastructure components" && \
  execute "Applying the terraform configuration" terraform apply -auto-approve $TF_PLAN
}


parse_arguments $@
preflight_checks && provisioning
