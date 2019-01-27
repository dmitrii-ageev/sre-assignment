#!/bin/bash

banner() {
  if [ ! $quiet ]; then
    echo ""
    echo "********************************************************************************"
    echo "*"
    echo "* $@ "
    echo "*"
    echo "********************************************************************************"
    echo ""
  fi
}

usage(){
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --help, -h			 Display help information"
  echo "  --verbose, -v 		 Be verbose"
  echo "  --playbook, -p <playbook>	 Check a playbook file for Ansible syntax validity using 'ansible-playbook'"
  echo "  --inventory, -i <inventory>	 Inventory file to use. Mandatory to use together with --playbook option."
  echo "  --directory, -d <directory>	 Directory to start from"
  echo "  --lint, -l			 Check all YAML files for Ansible syntax validity using 'ansible-lint'"
  echo "  --lint-yaml, -ly		 Do lint *.yml files"
  echo "  --lint-all, -la		 Do every possible lint checks"
  echo "  --give-up, -g			 Exit on the first error"
  echo "  --auto-fix, -a		 Automatically fix incorrect formatting (so far, trailing whitespace)."
  echo "  --quiet, -q			 Be quiet"
}

parse_arguments() {
  if [ $# -ne 0 ]; then
    while [ $# -gt 0 ]; do
      case $1 in
	'--help'         | '-h'           ) usage; exit 0   ;;
	'--verbose'      | '-v'  | '-vvv' ) verbose=true    ;;
	'--playbook'     | '-p'           ) playbook=true; PLAYBOOK=$2; shift;
	  if [ ! -f "$PLAYBOOK" ]; then critical_error "The file doesn't exist \"$PLAYBOOK\"."; fi ;;
	'--inventory'     | '-i'           ) inventory=true; INVENTORY=$2; shift;
	  if [ ! -e "$INVENTORY" ]; then critical_error "The file doesn't exist \"$INVENTORY\"."; fi ;;
	'--directory'    | '-d'           ) directory=true; DIRECTORY=$2; shift;
	  if [ ! -d "$DIRECTORY" ]; then critical_error "The directory doesn't exist \"$DIRECTORY\"."; fi ;;
	'--lint'         | '-l'           ) lint=true       ;;
	'--lint-yaml'    | '-ly'          ) lint_yaml=true  ;;
	'--lint-all'     | '-la'          ) lint_all=true   ;;
	'--give-up'      | '-g'           ) give_up=true; set -e ;;
	'--auto-fix'     | '-a'           ) auto_fix=true        ;;
	'--quiet'        | '-q'           ) quiet=true      ;;
	* ) error "Unknown opiton: $1!"; usage; exit 255; ;;
      esac
      shift
    done
  else
    usage; set -e; exit 0
  fi
}

msg() {
  if [ ! $quiet ]; then
    echo " * $@"
  fi
}

error() {
  echo "ERROR: $@"
}

critical_error() {
  error "$@"; set -e; exit 255
}

init() {
  DIRECTORY="./"
  PLAYBOOK=""
  OS=$(uname -s)
}

install() {
  # I assume we run this script on Ubuntu
  # I'll add OS-dependant install later
  echo "For Linux OS run next commands:"
  echo " sudo apt-get install -y python-pip"
  echo " sudo pip install ansible-lint yamllint"
  echo ""
  echo "For OS X run these commands:"
  echo ""
  echo " Using ports:"
  echo " port install py-pip"
  echo " port select --set pip pip27"
  echo " pip install ansible-lint yamllint"
  echo ""
  echo " Using homebrew:"
  echo " brew install python"
  echo " brew install brew-pip"
  echo " brew pip install ansible-lint yamllint"
  echo ' export PATH=$PATH:$(brew --prefix)/share/python'
  echo "Please Note: it might be a good idea to the line above to your shell profile."
}

check_if_package_installed() {
  which "$1" 2>&1 > /dev/null
  if [ $? -ne 0 ]; then
    error "$1 isn't installed!"
    echo
    echo "Here are some suggestions how you can fix it:"
    echo
    install
    echo
    critical_error "Can't find the required software!"
  fi
}

check_requirements() {
  set +e
  for package in ansible ansible-playbook yamllint ansible-lint; do
    check_if_package_installed "$package"
  done
  if [ $give_up ]; then set -e; fi
}

fix_the_trailing_space_mistake() {
  if [ $verbose ]; then msg "Removing trailing whitespaces from all YAML files."; fi
  if [ $OS == "Linux" ]; then
    find $DIRECTORY -name "*.yml" -exec sed -i 's/\s\+$//' {} \;
  elif [ $OS == "Darwin" ]; then
    find $DIRECTORY -name "*.yml" -exec sed -i '' 's/\s\+$//' {} \;
  else
    critical_error "Unsupported OS version!"
  fi
}

do_playbook_syntax_check() {
  banner "PERFORMING A PLAYBOOK CHECK"
  ansible-playbook --syntax-check --inventory "$2" "$1" && \
  ansible-lint "$1" && \
  yamllint "$1"
}

do_ansible_syntax_check() {
  if [ $verbose ]; then
    ansible-lint -v "$1"
  elif [ $quiet ]; then
    ansible-lint "$1" >/dev/null
  else
    ansible-lint "$1"
  fi
}

do_yaml_syntax_check() {
  yamllint "$1"
}

main() {
  parse_arguments $@
  check_requirements
  if [ $auto_fix ]; then fix_the_trailing_space_mistake; fi
  if [ $playbook ] && [ $inventory ]; then do_playbook_syntax_check "$PLAYBOOK" "$INVENTORY"; fi
  if [ $lint ] || [ $lint_yaml ] || [ $lint_all ]; then
    if [ $lint ]; then MESSAGE="ANSIBLE"; fi
    if [ $lint_yaml ]; then MESSAGE="YAML"; fi
    if [ $lint ] && [ $lint_yaml ] || [ $lint_all ]; then MESSAGE="ANSIBLE AND YAML"; fi
    banner "PERFORMING $MESSAGE SYNTAX CHECK"
    find $DIRECTORY -name "*.yml" | while read filename; do
      if [ $verbose ]; then msg "Processing file: \"$filename\""; fi
      if [ $lint ] || [ $lint_all ]; then do_ansible_syntax_check "$filename"; fi
      if [ $lint_yaml ] || [ $lint_all ]; then do_yaml_syntax_check "$filename"; fi
    done
  fi
}

init
main $@
