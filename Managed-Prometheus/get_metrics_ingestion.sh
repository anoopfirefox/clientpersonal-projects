#!/bin/bash
ws_id=$1

dcrID=$(az monitor account show --ids $ws_id --query defaultIngestionSettings.dataCollectionRuleResourceId | jq -r)
export dcr_id=$dcrID

immutable_id=$(az monitor data-collection rule show --ids $dcr_id --query immutableId | jq -r)
dceID=$(az monitor account show --ids $ws_id --query defaultIngestionSettings.dataCollectionEndpointResourceId | jq -r)
export dce_id=$dceID

ingestion_endpoint=$(az monitor data-collection endpoint show --ids $dce_id  --query logsIngestion.endpoint | jq -r | sed -e 's/.ingest/.metrics.ingest/g')
metrics_ingestion_endpoint="${ingestion_endpoint}/dataCollectionRules/${immutable_id}/streams/Microsoft-PrometheusMetrics/api/v1/write?api-version=2023-04-24"
jq -n --arg endpoint "$endpoint" '{"metrics_ingestion_endpoint":"'$metrics_ingestion_endpoint'"}'