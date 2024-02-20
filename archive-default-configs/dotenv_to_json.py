import argparse
import dotenv
import json
import os

ROOT_PATH = os.path.dirname(os.path.expanduser(os.path.expanduser(os.path.abspath(__file__))))
SAMPLE_CONFIGS = os.path.join(ROOT_PATH, 'anylog_generic_configs.env')
BASE_CONFIGS = os.path.join(ROOT_PATH, 'deployments', 'base.json')


def __read_dotenv(config_file:str)->dict:
    """
    Read .env configuration file
    :args:
        config_file:str - configuration file to be read
    :return:
        content in configuration file
    """
    configs = {}
    try:
        return dict(dotenv.dotenv_values(config_file))
    except Exception as error:
        print(f"Failed to read configs from {config_file} (Error: {error})")

    return configs


def __read_base()->dict:
    """
    Read content in BASE_CONFIGS
    :return:
       (JSON) content in BASE_CONFIGS as dictionary
    """
    if os.path.isfile(BASE_CONFIGS):
        try:
            with open(BASE_CONFIGS, 'r') as f:
                try:
                    return json.load(f)
                except Exception  as error:
                    print(f"Failed to read / load content in file (Error: {error})")
        except Exception as error:
            print(f"Failed to open file {error}")
    else:
        print(f"Failed to open {BASE_CONFIGS}")


def __write_json_file(config_file:str, payload:dict):
    """
    Write content to file
    :args:
        config_file:str - JSON configuration file (name)
        payload:dict - content to be stored in file
    """
    try:
        with open(config_file, 'w') as f:
            try:
                f.write(json.dumps(payload, indent=4))
            except Exception as error:
                print(f"Failed to write content to {config_file} (Error: {error})")
    except Exception as error:
        print(f"Failed open file {config_file} for writing (Error: {error})")


def main():
    """
    Convert .env file to JSON format intended to be used with OpenHorizon patterns
    :args:
    :optional arguments:
        -h, --help                      show this help message and exit
        --config-file CONFIG_FILE       .env configuration file to update
    :params:
        base_content:dict - content form BASE_CONFIGS
        dotenv_file_path:str - full path for (dotenv) config_file
        json_file_path:str - convert dotenv file to json file (name only)
        dot_env_configs:dict - content in dotenv file
    """
    parse = argparse.ArgumentParser()
    parse.add_argument('--config-file', type=str, default=SAMPLE_CONFIGS, help='.env configuration file to update')
    args = parse.parse_args()
    base_content = __read_base()
    if base_content is None:
        exit(1)

    dotenv_file_path = os.path.expanduser(os.path.expandvars(args.config_file))
    json_file_path = dotenv_file_path.replace(".env", ".json")
    if not os.path.isfile(dotenv_file_path):
        print(f'Failed to locate {dotenv_file_path}. Cannot continue...')
        exit(1)
    dot_env_configs = __read_dotenv(config_file=dotenv_file_path)
    if dot_env_configs != {}:
        # update base content with dotenv file content under variables
        base_content["services"][0]["serviceVersions"][0]["variables"] = dot_env_configs
        __write_json_file(config_file=json_file_path, payload=base_content)


if __name__ == '__main__':
    main()

