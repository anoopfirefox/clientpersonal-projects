#!/bin/bash
set -e
readonly PROGNAME=$(basename $0)

CONTEXT=$(kubectl config current-context)
KUBECMD="kubectl"

function usage() {
    cat <<- EOF
    usage: $PROGNAME options
    
    Get all Kubeform resources per namespace (table)
    Get all Kubeform resources for all namespaces (csv)

    OPTIONS:
        -B  <bas>|  --bastionCluster     connect to bastion cluster and to actual aks cluster
        -C  <ctx>|  --context            cluster to query. requires tunnel over port 8888 to be enabled
        -h       |  --help               show this help

    Examples:
        HTTPS_PROXY=localhost:8888 $PROGNAME -B <bastion cluster name> -C <cluster name>
EOF
}

function setcontext() {
  printf "========== Running on Cluster Context [ $1 ] ========== \n\n"
  KUBECMD="$KUBECMD --context=$1"
}

function connectbastion() {
  usecontext="$KUBECMD config use-context $1"
  nohup kubectl port-forward -n tinyproxy deployment/de-bastion-proxy 8888 >/dev/null 2>&1 & 
  cluster_context="$KUBECMD config use-context $2"
  export HTTPS_PROXY=localhost:8888
}


# Check for args otherwise continue
if [[ $# -eq 0 ]] ; then
  usage
  exit 0
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -B|--bastionCluster) connectbastion $2; shift;;
        -C|--context) setcontext $2; shift;;
        -h|--help) usage; exit 0;;
        *) usage; exit 1 ;;
    esac
    shift
done