#!/usr/bin/env python3

import os
import yaml
import click
import logging

from lib import RegistryFile, runcmd, save_yaml

logging.basicConfig(level=logging.INFO)

@click.group()
def cli():
    pass


@cli.command()
@click.option('-r', '--registryfile', type=click.Path(exists=True),
              help="""
                path to a YAML registry file.
                """)
def update_registry(registryfile):
    config = RegistryFile(registryfile)
    make_parameters=""
    mapping_dir = config.get_mapping_dir()
    
    if not os.path.isdir(mapping_dir):
        os.mkdir(mapping_dir)

    mappings = config.get_mappings()
    
    for mapping in mappings:
        mappings_set_file_path = os.path.join(mapping_dir,f"{mapping}_sssom.yml")
        mappings_set_file_path_tsv = os.path.join(mapping_dir, f"{mapping}_sssom.tsv")
        mappings_set_file_path_tsv_embedded = os.path.join(mapping_dir, f"{mapping}_embedded_sssom.yml")
        logging.info(f"Updateing {mapping} mapping set")
        runcmd(f"make mappings/{mapping}_sssom.tsv {make_parameters} -B")
        mapping_data = mappings[mapping]
        mapping_data_string = yaml.dump(mapping_data)
        mapping_data_string_commented=""
        for line in mapping_data_string.splitlines():
            mapping_data_string_commented=mapping_data_string_commented+"#"+line+"\n"
        print(mapping_data_string_commented)
        save_yaml(mapping_data,mappings_set_file_path)
        with open(mappings_set_file_path_tsv, 'r') as original: data = original.read()
        
        sssom_string_no_comments=""
        for line in data.splitlines():
            if not line.startswith("#"):
                sssom_string_no_comments=sssom_string_no_comments+line+"\n"
        with open(mappings_set_file_path_tsv, 'w') as original: 
            original.write(sssom_string_no_comments)
        with open(mappings_set_file_path_tsv_embedded, 'w') as modified: modified.write(mapping_data_string_commented + data)

if __name__ == '__main__':
    cli()
