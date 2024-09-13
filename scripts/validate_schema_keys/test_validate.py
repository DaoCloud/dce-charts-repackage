import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

loader = unittest.TestLoader()
suite = loader.discover('.', pattern='test_*.py')
runner = unittest.TextTestRunner()
runner.run(suite)

from validate import validate_required_keys

class TestValidateYAML(unittest.TestCase):

    def test_valid_yaml(self):
        yaml_data = {
            "Agent": {
                "Builder": {
                    "ContainerRuntime": "podman"
                }
            }
        }
        schema = {
            "type": "object",
            "properties": {
                "Agent": {
                    "type": "object",
                    "properties": {
                        "Builder": {
                            "type": "object",
                            "properties": {
                                "ContainerRuntime": {
                                    "type": "string",
                                    "enum": ["podman", "docker"]
                                }
                            }
                        }
                    }
                }
            }
        }
        is_valid, error_message = validate_required_keys(yaml_data, schema)
        self.assertTrue(is_valid)
        self.assertEqual(error_message, "")

    def test_missing_key_yaml(self):
        yaml_data = {
            "Agent": {
                "Builder": {
                    "OtherKey": "value"
                }
            }
        }
        schema = {
            "type": "object",
            "properties": {
                "Agent": {
                    "type": "object",
                    "properties": {
                        "Builder": {
                            "type": "object",
                            "properties": {
                                "ContainerRuntime": {
                                    "type": "string",
                                    "enum": ["podman", "docker"]
                                }
                            }
                        }
                    }
                }
            }
        }
        is_valid, error_message = validate_required_keys(yaml_data, schema)
        self.assertFalse(is_valid)
        self.assertIn("missing required field 'ContainerRuntime'", error_message)

    def test_wildcard_yaml(self):
        yaml_data = {
            "Agent": {
                "Resources": {}
            }
        }
        schema = {
            "type": "object",
            "properties": {
                "Agent": {
                    "type": "object",
                    "properties": {
                        "Resources": {
                            "type": "object",
                            "properties": {
                                "limit": {
                                    "type": "string"
                                }
                            }
                        }
                    }
                }
            }
        }
        is_valid, error_message = validate_required_keys(yaml_data, schema)
        self.assertTrue(is_valid)
        self.assertEqual(error_message, "")

if __name__ == '__main__':
    unittest.main()