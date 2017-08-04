#!/bin/bash
#set -x
WRONG_AUTH_EMAIL=$1
NEW_AUTH_EMAIL=$2
NEW_AUTH_NAME=$3

function git_rewrite_1()
{
  echo "> Wrong author email: ${WRONG_AUTH_EMAIL}"
  echo "> New author email: ${NEW_AUTH_EMAIL}"
  echo "> New author name: ${NEW_AUTH_NAME}"

  ENV_FILTER='
    if [ "$GIT_COMMITTER_EMAIL" = "${WRONG_AUTH_EMAIL}" ] ; then
      export GIT_COMMITTER_NAME="${NEW_AUTH_NAME}"
      export GIT_COMMITTER_EMAIL="${NEW_AUTH_EMAIL}"
    fi
    if [ "$GIT_AUTHOR_EMAIL" = "${WRONG_AUTH_EMAIL}" ] ; then
      export GIT_AUTHOR_NAME="${NEW_AUTH_NAME}"
      export GIT_AUTHOR_EMAIL="${NEW_AUTH_EMAIL}"
    fi'

  echo ${ENV_FILTER}

  git filter-branch --env-filter ${ENV_FILTER} --tag-name-filter cat -- --all
}

function git_rewrite_2()
{
  echo "> Wrong author email: ${WRONG_AUTH_EMAIL}"
  echo "> New author email: ${NEW_AUTH_EMAIL}"
  echo "> New author name: ${NEW_AUTH_NAME}"

  git filter-branch --env-filter '
    if [ "$GIT_COMMITTER_EMAIL" = "$WRONG_AUTH_EMAIL" ] ; then
      export GIT_COMMITTER_NAME="$NEW_AUTH_NAME"
      export GIT_COMMITTER_EMAIL="$NEW_AUTH_EMAIL"
    fi
    if [ "$GIT_AUTHOR_EMAIL" = "$WRONG_AUTH_EMAIL" ] ; then
      export GIT_AUTHOR_NAME="$NEW_AUTH_NAME"
      export GIT_AUTHOR_EMAIL="$NEW_AUTH_EMAIL"
    fi
  ' --tag-name-filter cat -- --all
}

if [ -n "${WRONG_AUTH_EMAIL}" ] && [ -n "${NEW_AUTH_EMAIL}" ] && [ -n "${NEW_AUTH_NAME}" ] ; then
  git_rewrite_2
else
  echo "Usage:"
  echo " $0 <incorrect author email> <new author email> <new author name>"
  echo
  echo "To see commit history: git log"
fi;

