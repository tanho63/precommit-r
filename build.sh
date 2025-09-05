#!/bin/bash

# This script builds the `tanho63/precommit` etl Docker image.
#
# Docker user access is required.
#
# It can be run with the following flags:
# -w pushes the image to AWS ECR
# -p tags the image as "PRODUCTION"
ARGS=$(getopt -a --options wp --long "aws,production" -- "$@")
eval set -- "$ARGS"
aws="false"
dev_or_prod="dev"
while true; do
  case "$1" in
    -w|--aws)
      aws="true"
      shift;;
    -p|--production)
      while true; do
      echo "The -p flag will impact production systems."
      read -p "Do you want to proceed? (y/n) " yn
      case $yn in
  	      [yY] ) echo "Proceeding...";
	      	  break;;
	        [nN] ) echo "Exiting...";
		        exit;;
	      * ) echo "Invalid response (must be y/n)";;
      esac
      done
      dev_or_prod="production"
      shift;;
    --)
      break;;
     *)
      printf "Unknown option %s\n" "$1"
      exit 1;;
  esac
done
set -euxo pipefail
# Create image tags
today=$(date +'%Y_%m_%d')
tag="precommit-r"
docker_tag="tanho63/$tag"
docker_tag_date="$docker_tag:$today"
docker_tag_production="$docker_tag:$dev_or_prod"

docker build \
  -t "$docker_tag" \
  -t "$docker_tag_date" \
  -t "$docker_tag_production" \
  .

if [[ $aws == true ]]; then
  # * Tag image with proper name
  aws_docker_tag="aws_tag/$tag"
  docker tag "$docker_tag:latest" "$aws_docker_tag:latest"
  docker tag "$docker_tag_date" "$aws_docker_tag:$today"
  docker tag "$docker_tag_production" "$aws_docker_tag:$dev_or_prod"

  # * Push to AWS ECR
  docker push "$aws_docker_tag:latest"
  docker push "$aws_docker_tag:$today"
  docker push "$aws_docker_tag:$dev_or_prod"
fi
