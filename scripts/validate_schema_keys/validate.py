import yaml
import json
import argparse
import os

def load_json_schema(file_path):
    if not os.path.exists(file_path):
        print(f"JSON schema file '{file_path}' not found, skipping schema loading.")
        return None
    else:
        with open(file_path, 'r') as file:
            return json.load(file)

def load_yaml(file_path):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"YAML file '{file_path}' not found.")
    else:
        with open(file_path, 'r') as file:
            return yaml.safe_load(file)

def validate_required_keys(yaml_data, schema, path=""):
    if not isinstance(schema, dict):
        return False, f"At path '{path}', the schema definition is invalid."

    if isinstance(yaml_data, dict):
        # If YAML data is an empty dictionary, it's considered a wildcard (any key-value pairs are valid)
        if yaml_data == {}:
            return True, ""

        schema_properties = schema.get("properties", {})

        for key in schema_properties:
            if key not in yaml_data:
                return False, f"At path '{path}', missing required field '{key}'."

            sub_schema = schema_properties[key]
            sub_yaml_data = yaml_data[key]
            if sub_schema.get("type") == "object":
                valid, error_message = validate_required_keys(sub_yaml_data, sub_schema, path=f"{path}.{key}")
                if not valid:
                    return False, error_message

    # If YAML data is not a dictionary, but the schema expects an object, it's invalid
    elif schema.get("type") == "object":
        return False, f"At path '{path}', expected an object but found a different type."

    return True, ""

def main(schema_file, yaml_files):
    schema = load_json_schema(schema_file)
    if schema is None:
        print("Skipping validation since schema file is missing.")
        return

    for yaml_file in yaml_files:
        yaml_data = load_yaml(yaml_file)
        is_valid, error_message = validate_required_keys(yaml_data, schema)
        if not is_valid:
            print(f"The YAML {yaml_file} file structure is invalid. Error: {error_message}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Validate YAML files against a JSON schema.')
    parser.add_argument('schema_file', type=str, help='Path to the JSON schema file')
    parser.add_argument('yaml_files', type=str, nargs='+', help='Paths to the YAML files to validate')
    args = parser.parse_args()
    main(args.schema_file, args.yaml_files)