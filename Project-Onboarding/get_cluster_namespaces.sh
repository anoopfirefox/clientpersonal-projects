#!/bin/bash

#example ./get_cluster_namespaces.sh -r eun -e prd -ct cc -c control
# Argument Usage ./connect_cluster_bastion.sh -r <REGION_NAME> -e <ENVIRONMENT> -ct <CLUSTER_TYPE> -c <CLUSTER>
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
    -c|--cluster)
      CLUSTER="$2"
      shift # past argument
      shift # past value
      ;;  
    -ct|--clustertype)
      CLUSTER_TYPE="$2"
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
echo "CLUSTER_TYPE = ${CLUSTER_TYPE}"
echo "CLUSTER = ${CLUSTER}"
 

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

echo "Get the Current Context of AKS Cluster"
kubectl config get-contexts

kubectl config use-context abc-aks-${CLUSTER_TYPE}-${REGION}-${ENVIRONMENT}
export HTTPS_PROXY=localhost:8888

kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' > ../namespaces/prd/${ENVIRONMENT}/${CLUSTER}/namespaces_${ENVIRONMENT}_${CLUSTER_TYPE}.txt --context=abc-aks-${CLUSTER_TYPE}-${REGION}-${ENVIRONMENT}

while read namespace; do
kubectl get ns $namespace -o yaml > ../manifests/prd/${ENVIRONMENT}/${CLUSTER}/${namespace}_ns.yaml --context=abc-aks-${CLUSTER_TYPE}-${REGION}-${ENVIRONMENT}
yq eval -i 'del(.status,.spec,.metadata.uid,.metadata.creationTimestamp,.metadata.resourceVersion,.metadata.annotations)' ../manifests/prd/${ENVIRONMENT}/${CLUSTER}/${namespace}_ns.yaml
done < ../namespaces/prd/${ENVIRONMENT}/${CLUSTER}/namespaces_${ENVIRONMENT}_${CLUSTER_TYPE}.txt