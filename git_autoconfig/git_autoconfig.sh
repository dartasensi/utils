#!/bin/bash
#set -x

PROPERTIES_FILE="git_autoconfig.properties"
GITUSER_NAME=""
GITUSER_EMAIL=""

GITSTATUS_OK=0
GITSTATUS_NOT_A_REPO=128

ARG_GIT_REPO_PATH=$1
#ARG_GIT_USER_NAME=$2
#ARG_GIT_USER_EMAIL=$3

checkGitStatus() {
  local res=1

  git status &> /dev/null
  res=$?

  return ${res}
}

initializeGit() {
  local res=1

  checkGitStatus
  if [ $? -eq ${GITSTATUS_NOT_A_REPO} ] ; then
    echo "> Initializing Git repository"
    git init
    res=$?
  else
    res=1
  fi

  return ${res}
}

configureGit() {
  local res=1

  checkGitStatus
  if [ $? -eq ${GITSTATUS_OK} ] ; then
    echo "> Apply custom configuration"
    git config --local user.name "${GITUSER_NAME}"
    git config --local user.email "${GITUSER_EMAIL}"
    git config --local push.default "simple"

    echo "> Showing updated Git configuration"
    git config --local --list
    res=0
  else
    echo "ERROR! Cannot check the status of the git repository! Aborting..."
    res=1
  fi

  return ${res}
}

execute() {
  local res=1
  local requireConfig=y

  local CURRPWD=$(pwd)
  cd ${ARG_GIT_REPO_PATH}

  initializeGit
  if [ $? -eq 1 ] ; then
    echo "WARNING! Your current Git configuration:"
    git config --local --list
    echo
    read -p "Do you want to continue and overwrite it with your custom configuration? (y/n) " requireConfig
  fi

  case ${requireConfig:0:1} in
    y|Y )
      configureGit
      res=0
    ;;
    * )
      echo "Aborting..."
      res=1
    ;;
  esac

  cd ${CURRPWD}

  return ${res}
}

# Main

if [ -f "${PROPERTIES_FILE}" ] ; then
  source "${PROPERTIES_FILE}"
  if [ -d "${ARG_GIT_REPO_PATH}" ] ; then
    echo "= Git repository initialiser ="
    echo
    execute
  else
    echo "Usage:"
    echo " $0 <path/to/the/folder/to/initialize>"
    echo
  fi
else
  echo "Missing properties file! Cannot continue."
  echo "Please, create a proper properties file before executing this script"
fi

exit $?