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
        mappings_set_file_path = os.path.join(mapping_dir,f"{mapping}.sssom.yml")
        mappings_set_file_path_tsv = os.path.join(mapping_dir, f"{mapping}.sssom.tsv")
        mappings_set_file_path_tsv_embedded = os.path.join(mapping_dir, f"{mapping}_embedded.sssom.tsv")
        logging.info(f"Updateing {mapping} mapping set")
        runcmd(f"make mappings/{mapping}.sssom.tsv {make_parameters} -B")
        mapping_data = mappings[mapping]
        
        with open(mappings_set_file_path_tsv, 'r') as original: data = original.read()
        sssom_comments=""
        sssom_string_no_comments=""
        for line in data.splitlines():
            if line.startswith("#"):
                sssom_comments=sssom_comments+line[1:]+"\n"
            else:
                sssom_string_no_comments=sssom_string_no_comments+line+"\n"
        if sssom_comments:
            original_data = yaml.load(sssom_comments, Loader=yaml.SafeLoader)
            
            # Augment mapping data with original data if anything extra
            for k in original_data:
                if k in mapping_data:
                    logging.warning(f"{k} exists in the original sssom file, but overwritten by registry config.")
                else:
                    mapping_data[k] = original_data[k]
        
        mapping_data_string = yaml.dump(mapping_data)
        mapping_data_string_commented=""
        for line in mapping_data_string.splitlines():
            mapping_data_string_commented=mapping_data_string_commented+"#"+line+"\n"
        
        save_yaml(mapping_data,mappings_set_file_path)
        
        with open(mappings_set_file_path_tsv, 'w') as original: 
            original.write(sssom_string_no_comments)
        
        with open(mappings_set_file_path_tsv_embedded, 'w') as modified:
            modified.write(mapping_data_string_commented + sssom_string_no_comments)

if __name__ == '__main__':
    cli()
