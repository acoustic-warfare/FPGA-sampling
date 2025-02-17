import json
from os.path import relpath, dirname
import os
from pathlib import Path
import subprocess

ROOT = os.getcwd()

lib_json_path = Path("./lib.json")
vhld_ls_toml_path = Path(ROOT + "/vhdl_ls.toml")


def gen_vunit_json_file():
    command = ["python3", "pl/run.py", "--export-json", "lib.json"]
    try:
        result = subprocess.run(command, check=True,
                                capture_output=True, text=True)
        print("Generated lib.json")
    except subprocess.CalledProcessError as e:
        print("Error:\n", e.stderr)


def gen_toml_file(lib_json_path, vhld_ls_toml_path):
    with open(lib_json_path, "r") as f:
        data = json.load(f)

    libraries = {}
    for source in data["files"]:
        lib = source["library_name"]
        file = source["file_name"]
        libraries.setdefault(lib, []).append(
            relpath(file, dirname(vhld_ls_toml_path)))

    # Start the TOML string
    toml_string = "[libraries]\n"

    # Manually format each library entry
    for lib, files in libraries.items():
        # Format the library entry without quotes around the key name
        toml_string += f"{lib}.files = [\n"
        toml_string += ",\n".join([f'    "{file}"' for file in files]) + ",\n"
        toml_string += "]\n\n"

    toml_string += "vunit_lib.is_third_party = true\n"

    # Write the formatted TOML string to the file
    with open(vhld_ls_toml_path, "w") as f:
        f.write(toml_string)


def remove_lib_json(lib_json_path):
    if lib_json_path.exists():
        os.remove(lib_json_path)
        print(f"{lib_json_path} has been removed.")
    else:
        print(f"{lib_json_path} does not exist.")


gen_vunit_json_file()
gen_toml_file(lib_json_path, vhld_ls_toml_path)
remove_lib_json(lib_json_path)
