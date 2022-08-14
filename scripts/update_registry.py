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
    make_parameters=" -B"
    mapping_dir = config.get_mapping_dir()
    
    if not os.path.isdir(mapping_dir):
        os.mkdir(mapping_dir)

    mappings = config.get_mappings()
    
    for mapping in mappings:
        mappings_set_file_path_tsv = os.path.join(mapping_dir, f"{mapping}.sssom.tsv")
        logging.info(f"Updateing {mapping} mapping set")
        runcmd(f"make mappings/{mapping}.sssom.tsv {make_parameters}")

if __name__ == '__main__':
    cli()
