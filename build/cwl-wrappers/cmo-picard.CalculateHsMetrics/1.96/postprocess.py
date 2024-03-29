#!/usr/bin/python
"""postprocess"""

import argparse
import ruamel.yaml


def read(filename):
    """return file contents"""

    with open(filename, 'r') as file_in:
        return file_in.read()


def write(filename, cwl):
    """write to file"""

    with open(filename, 'w') as file_out:
        file_out.write(cwl)


def main():
    """main function"""

    parser = argparse.ArgumentParser(description='postprocess')

    parser.add_argument(
        '-f',
        action="store",
        dest="filename_cwl",
        help='Name of the cwl file',
        required=True
    )

    params = parser.parse_args()

    cwl = ruamel.yaml.load(read(params.filename_cwl),
                           ruamel.yaml.RoundTripLoader)

    cwl['inputs']['I']['type'] = ruamel.yaml.load("""
- File
- type: array
  items: string
""", ruamel.yaml.RoundTripLoader)

    # indentation matters here
    cwl['inputs']['LEVEL'] = ruamel.yaml.load("""
type:
- 'null'
- type: array
  items: string
  inputBinding:
    prefix: --LEVEL
""", ruamel.yaml.RoundTripLoader)

    cwl['inputs']['R']['inputBinding']['prefix'] = '--R'

    cwl['inputs']['BI']['type'] = 'File'
    cwl['inputs']['TI']['type'] = 'File'

    cwl['inputs']['VALIDATION_STRINGENCY']['default'] = 'SILENT'

    del cwl['inputs']['version']
    del cwl['inputs']['java_version']

    #-->
    # fixme: until we can auto generate cwl for picard
    # set outputs using outputs.yaml
    import os
    cwl['outputs'] = ruamel.yaml.load(
        read(os.path.dirname(params.filename_cwl) + "/outputs.yaml"),
        ruamel.yaml.RoundTripLoader)['outputs']

    # from : [cmo_picard, --cmd CalculateHsMetrics]
    # to   : [cmo_picard, --cmd, CalculateHsMetrics]
    cwl['baseCommand'] = ['cmo_picard', '--cmd', 'CalculateHsMetrics']
    #<--

    write(params.filename_cwl, ruamel.yaml.dump(
        cwl, Dumper=ruamel.yaml.RoundTripDumper))


if __name__ == "__main__":

    main()
