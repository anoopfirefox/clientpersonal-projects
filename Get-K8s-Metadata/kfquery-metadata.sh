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
        -A       |  --all                all Kubeform resources for all namespaces
        -n  <ns> |  --namepspace         all Kubeform resources for a specific namespace
        -C  <ctx>|  --context            cluster to query. requires tunnel over port 8888 to be enabled
        -h       |  --help               show this help

    Examples:

        $PROGNAME -n exam-app-sbx-pub
        
        $PROGNAME -A > somefile.csv

        HTTPS_PROXY=localhost:8888 $PROGNAME -C <cluster_name> -A

        HTTPS_PROXY=localhost:8888 $PROGNAME -C <cluster_name> -n <namepspace>
        
EOF
}

function setcontext() {
  printf "========== Running on Cluster Context [ $1 ] ========== \n\n"
  KUBECMD="$KUBECMD --context=$1"
}

# TODO Fix column width spacing
function getresourcebynamespace {
  printf "\t\t\t\t\t\t\t Running \t Failed \t Initialising \t Deleting\n\n"

  #print header
  printf %s "Namespace: ${1}"
  printf "\n"

  printf %s "BusinessApplicationName: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/BusinessApplicationName"')"
  printf "\n"

  printf %s "BusinessApplicationID: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/BusinessApplicationID"')"
  printf "\n"

  printf %s "PortfolioLevel1: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel1"')"
  printf "\n"

  printf %s "PortfolioLevel2: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel2"')"
  printf "\n"

  printf %s "PortfolioLevel3: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel3"')"
  printf "\n"

  printf %s "PortfolioLevel4: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel4"')"
  printf "\n"

  printf %s "PortfolioLevel5: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel5"')"
  printf "\n"
 
  printf %s "PortfolioManager: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/PortfolioManager"')"
  printf "\n"

  printf %s "ProjectCode: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/ProjectCode"')"
  printf "\n"

  printf %s "ProjectOwner: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/ProjectOwner"')"
  printf "\n"

  printf %s "UD: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/UD"')"
  printf "\n"

  printf %s "SnowStatus: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/SnowStatus"')"
  printf "\n"

  printf %s "WorkStream: $($KUBECMD get ns ${1} -o json | jq -r '.metadata.labels."xyz/WorkStream"')"
  printf "\n"

  printf %s "CRD's"
  printf "\n"
  
  for i in $($KUBECMD api-resources --verbs=list --namespaced -o name | grep "modules.kubeform" | grep -v "events" | sort | uniq); do
    printf %-55.55s "$i" 
    if [ -z "$1" ]
    then
        $KUBECMD get --ignore-not-found ${i}
    else
        printf %5s $($KUBECMD -n ${1} get --ignore-not-found ${i} | grep Running | wc -l)
        printf "\t\t"
        printf %5s $($KUBECMD -n ${1} get --ignore-not-found ${i} | grep Failed | wc -l)
        printf "\t\t"
        printf %5s $($KUBECMD -n ${1} get --ignore-not-found ${i} | grep Initializing | wc -l)
        printf "\t\t"
        printf %5s $($KUBECMD -n ${1} get --ignore-not-found ${i} | grep Deleting | wc -l)
        printf "\n"
    fi
  done 
}

function getallresources {

  # print header
  printf %s "Namespace,"
  for n in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "${n},"
  done
  printf "\n"
  
  # print header
  printf %s "BusinessApplicationName,"
  for appName in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${appName} -o json | jq -r '.metadata.labels."xyz/BusinessApplicationName"'),"
  done
  printf "\n"
  #print header
   printf %s "BusinessApplicationID,"
  for appID in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${appID} -o json | jq -r '.metadata.labels."xyz/BusinessApplicationID"'),"
  done
  printf "\n"
 
  #print header
   printf %s "PortfolioLevel1,"
  for pl1 in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${pl1} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel1"'),"
  done
  printf "\n"

  #print header
  printf %s "PortfolioLevel2,"
  for pl2 in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${pl2} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel2"'),"
  done
  printf "\n"

  #print header
  printf %s "PortfolioLevel3,"
  for pl3 in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${pl3} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel3"'),"
  done

  printf "\n"
  #print header
  printf %s "PortfolioLevel4,"
  for pl4 in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${pl4} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel4"'),"
  done

  printf "\n"
  #print header
  printf %s "PortfolioLevel5,"
  for pl5 in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${pl5} -o json | jq -r '.metadata.labels."xyz/PortfolioLevel5"'),"
  done

  printf "\n"
  #print header
  printf %s "PortfolioManager,"
  for pm in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${pm} -o json | jq -r '.metadata.labels."xyz/PortfolioManager"'),"
  done
  
  printf "\n"
  #print header
  printf %s "ProjectCode,"
  for pc in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${pc} -o json | jq -r '.metadata.labels."xyz/ProjectCode"'),"
  done
  
  printf "\n"
  #print header
  printf %s "ProjectOwner,"
  for po in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${po} -o json | jq -r '.metadata.labels."xyz/ProjectOwner"'),"
  done

  printf "\n"
  #print header
  printf %s "UD,"
  for sd in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${sd} -o json | jq -r '.metadata.labels."xyz/UD"'),"
  done

  printf "\n"
  #print header
  printf %s "SnowStatus,"
  for snowstatus in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${snowstatus} -o json | jq -r '.metadata.labels."xyz/SnowStatus"'),"
  done

  printf "\n"
  #print header
  printf %s "WorkStream,"
  for WorkStream in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
    printf %s "$($KUBECMD get ns ${WorkStream} -o json | jq -r '.metadata.labels."xyz/WorkStream"'),"
  done  
  
  printf "\n"
  printf %s "CRD's,"
  
  printf "\n"
  # print data
  for i in $($KUBECMD api-resources --verbs=list --namespaced -o name | grep "modules.kubeform" | grep -v "events" | sort | uniq); do
  printf %s "${i},"
      for j in $($KUBECMD get ns | awk '{print $1}' | grep pub$); do
         printf %s $($KUBECMD get ${i} -n ${j} --ignore-not-found | grep Running | wc -l) ","
      done
  printf "\n"  
  done
}
# Check for args otherwise continue
if [[ $# -eq 0 ]] ; then
  usage
  exit 0
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -C|--context) setcontext $2; shift;;
        -n|--namespace) getresourcebynamespace $2; shift ;;
        -A|--all) getallresources; exit 0;;
        -h|--help) usage; exit 0;;
        *) usage; exit 1 ;;
    esac
    shift
done