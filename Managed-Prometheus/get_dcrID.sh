#!/bin/bash
ws_id=$1
dcrID=$(az monitor account show --ids $ws_id --query defaultIngestionSettings.dataCollectionRuleResourceId | jq -r)
export dcr_id=$dcrID
jq -n --arg dcrid "$dcrid" '{"dcrID":"'$dcrID'"}'