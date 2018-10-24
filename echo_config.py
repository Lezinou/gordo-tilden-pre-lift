import io
import yaml
import os


if __name__ == "__main__":
    config = os.environ['CONFIG']

    string = io.StringIO(config)
    print(yaml.load(string))
