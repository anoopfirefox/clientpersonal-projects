#!/bin/bash

# Argument Usage ./connect_cluster_bastion.sh -r <REGION_NAME> -e <ENVIRONMENT>
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--region)
      REGION="$2"
      shift # past argument
      shift # past value
      ;;
    -e|--environment)
      ENVIRONMENT="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

echo "REGION_NAME  = ${REGION}"
echo "ENVIRONMENT  = ${ENVIRONMENT}"



if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

echo "Get the Current Context of AKS Cluster"
kubectl config get-contexts

kubectl config use-context xyz-aks-bastion-${REGION}-${ENVIRONMENT}

echo "Get the Current Context of AKS Cluster after switching them"
kubectl config get-contexts

nohup kubectl port-forward -n tinyproxy deployment/xy-bastion-proxy 8888 >/dev/null 2>&1 &