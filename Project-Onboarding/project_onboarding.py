import csv
import json
import yaml
import re
import sys

# Declared the csv and json file paths
input_csv_file = '../onboarding-spreadsheet/Onboarding_Stats.csv'
output_json_file = '../output/Onboarding_Stats.json'

# Take the Input Argument Control/Workload
cluster_type = sys.argv[1]
print(cluster_type)

data = []

# Fuction Declared to find and replace the special characters 
def replace_special_characters_with_hyphen(input_string):
    pattern = r'[^a-zA-Z0-9]+'
    replaced_string = re.sub(pattern, '_', input_string)
    final_string = re.sub("_$","",replaced_string)
    return final_string

#Read the CSV file and convert it to a list of dictionaries
with open(input_csv_file, 'r') as csvf:
    csv_reader = csv.DictReader(csvf)
    for row in csv_reader:
        data.append(row)
        
##Write the data to a JSON File
with open(output_json_file, 'w') as jsof:
     json.dump(data, jsof, indent=4)

print(f'CSV file "{input_csv_file}" has been converted to JSON file Successfully "{output_json_file}"')

## Read the json input data and filter the fields
with open('../output/Onboarding_Stats.json', 'r') as file:
    # Load the JSON data
   allitem = json.load(file)
   
 ########## Parse json data and append to yaml metadata ###########
for item in allitem:
    if "dev" in item["Namespace"] or "sbx" in item["Namespace"] or "qat" in item["Namespace"]:
      namespace=item["Namespace"]
      filename="../manifests/prd/npd/" + cluster_type + "/" + namespace + "_ns.yaml"
    elif "prd" in item["Namespace"] or "pre" in item["Namespace"]:
      namespace=item["Namespace"]
      filename="../manifests/prd/prd/" + cluster_type + "/" + namespace + "_ns.yaml"
    vals=item.values()
    keys=item.keys() 
    for key in keys: 
        final_string = replace_special_characters_with_hyphen(item[key])
        item[key]=final_string  
    with open(filename, 'r') as file:
      namespace_config = yaml.safe_load(file)
      del item["Namespace"]
      namespace_config["metadata"]["labels"].update(item)
    with open(filename, 'w') as file:
       yml_outputs = yaml.dump(namespace_config, file)