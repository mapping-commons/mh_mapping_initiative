#!/usr/bin/env python3

import yaml
import logging
import subprocess
import threading
import urllib.request
import hashlib
from subprocess import check_call
import requests
from datetime import datetime

obo_purl = "http://purl.obolibrary.org/obo/"

class Command(object):
    def __init__(self, cmd):
        self.cmd = cmd
        self.process = None

    def run(self, timeout):
        def target():
            logging.info(f"RUNNING: {self.cmd} (Timeout: {timeout})")
            self.process = subprocess.Popen(self.cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            (out, err) = self.process.communicate()
            logging.info('OUT: {}'.format(out))
            if err:
                logging.info('ERROR: {}'.format(err))

        thread = threading.Thread(target=target)
        thread.start()

        thread.join(timeout)
        if thread.is_alive():
            print('Terminating process')
            self.process.terminate()
            thread.join()
        if self.process.returncode != 0:
            raise Exception(f'Failed: {self.cmd} with return code {self.process.returncode}')


def runcmd(cmd, timeout=3600):
    command = Command(cmd)
    command.run(timeout=timeout)


def read_txt_from_url_as_lines(url):
    profile_raw = urllib.request.urlopen(url).read()
    profile_lines = profile_raw.decode('utf-8').split('\n')
    return profile_lines


def open_yaml_from_url(url):
    raw = urllib.request.urlopen(url).read()
    return yaml.load(raw, Loader=yaml.SafeLoader)


class RegistryFile:

    def __init__(self, config_file):
        self.config = yaml.load(open(config_file, 'r'), Loader=yaml.SafeLoader)

    def get_registry_id(self):
        if "registry_id" in self.config:
            return self.config.get("registry_id")
        else:
            return "unknown"

    def get_mapping_dir(self):
        if "mapping_dir" in self.config:
            return self.config.get("mapping_dir")
        else:
            return "mappings"

    def get_registry_title(self):
        if "registry_title" in self.config:
            return self.config.get("registry_title")
        else:
            return "unknown"

    def get_registry_description(self):
        if "registry_description" in self.config:
            return self.config.get("registry_description")
        else:
            return "No description provided."


    def get_mapping_ids(self):
        mapping_ids = []
        mappings = self.config.get("mappings")

        for o in mappings:
            mapping_ids.append(o['mapping_set_id'])
        return list(set(mapping_ids))

    def get_mappings(self):
        mappings = self.config.get("mappings")
        mappings_indexed = {}
        
        for m in mappings:
            mappings_indexed[m['mapping_set_id']]=m
        
        return mappings_indexed


def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def sha256sum(filename):
    h  = hashlib.sha256()
    b  = bytearray(128*1024)
    mv = memoryview(b)
    with open(filename, 'rb', buffering=0) as f:
        for n in iter(lambda : f.readinto(mv), 0):
            h.update(mv[:n])
    return h.hexdigest()

def load_yaml(filepath):
    with open(filepath, 'r') as f:
        data = yaml.load(f, Loader=yaml.SafeLoader)
    return data


def robot_prepare_ontology(o_path, o_out_path, o_metrics_path, base_iris, make_base, robot_prefixes={}, robot_opts="-v"):
    logging.info(f"Preparing {o_path} for dashboard.")
    try:
        callstring = ['robot','measure']
        if robot_opts:
            callstring.append(f"{robot_opts}")
        callstring.extend(['-i', o_path])
        for prefix in robot_prefixes:
            callstring.extend(['--prefix', f"{prefix}: {robot_prefixes[prefix]}"])
        callstring.extend(['--metrics', 'extended-reasoner','-f','yaml','-o',o_metrics_path, 'merge'])
        if make_base:
            callstring.extend(['remove'])
            #base_iris_string = " ".join([f"--base-iri \"{s}\"" for s in sbase_iris])
            for s in base_iris:
                callstring.extend(['--base-iri',s])
            callstring.extend(["--axioms", "external", "-p", "false"])
        callstring.extend(['--output', o_out_path])
        logging.info(callstring)
        check_call(callstring)
    except Exception as e:
        raise Exception(f"Preparing {o_path} for dashboard failed...", e)

def count_up(dictionary, value):
    if value not in dictionary:
        dictionary[value] = 0
    dictionary[value] = dictionary[value] + 1
    return dictionary


def save_yaml(dictionary, file_path):
    with open(file_path, 'w') as file:
        yaml.dump(dictionary, file)



def get_hours_since(timestamp):
    modified_date = datetime.fromtimestamp(timestamp)
    now = datetime.now()
    duration = now - modified_date
    hours_since = (duration.total_seconds() // 3600)
    return hours_since

def compute_obo_score(impact, reuse, dashboard, impact_external, weights):
    impact_weight = weights['impact']
    reuse_weight = weights['reuse']
    dashboard_weight = weights['dashboard']
    impact_external_weight = weights['impact_external']
    #sum_weights = impact_weight + reuse_weight + dashboard_weight + impact_external_weight
    #score_sum = sum([impact_weight * impact, reuse_weight * reuse, dashboard_weight * dashboard,
    #                 impact_external_weight * impact_external])
    #formula = f"({impact_weight}*impact+{dashboard_weight}*dashboard+{reuse_weight}*reuse+{impact_external_weight}*impact_external)/{sum_weights}"

    sum_weights = impact_weight+dashboard_weight
    score_sum = sum([impact_weight*impact, dashboard_weight*dashboard])
    formula = f"({impact_weight}*impact+{dashboard_weight}*dashboard)/{sum_weights}"
    score = score_sum/sum_weights
    return { "score": score, "formula" : formula }


def compute_dashboard_score(data, weights, maximpacts):

    if 'failure' in data:
        return 0

    oboscore = 100
    no_base = 0
    report_errors = 0
    report_warning = 0
    report_info = 0

    overall_error = 0
    overall_warning = 0
    overall_info = 0

    if 'base_generated' in data and data['base_generated'] == True:
        no_base = weights['no_base']

    if 'results' in data:
        if 'ROBOT Report' in data['results']:
            if 'results' in data['results']['ROBOT Report']:
                report_errors = data['results']['ROBOT Report']['results']['ERROR']
                report_warning = data['results']['ROBOT Report']['results']['WARN']
                report_info = data['results']['ROBOT Report']['results']['INFO']

    if 'summary' in data:
        overall_error = data['summary']['summary_count']['ERROR']
        overall_warning = data['summary']['summary_count']['WARN']
        overall_info = data['summary']['summary_count']['INFO']

    oboscore = oboscore - score_max(weights['no_base'] * no_base, maximpacts['no_base'])
    oboscore = oboscore - score_max(weights['overall_error'] * overall_error, maximpacts['overall_error'])
    oboscore = oboscore - score_max(weights['overall_warning'] * overall_warning, maximpacts['overall_warning'])
    oboscore = oboscore - score_max(weights['overall_info'] * overall_info, maximpacts['overall_info'])
    oboscore = oboscore - score_max(weights['report_errors'] * report_errors, maximpacts['report_errors'])
    oboscore = oboscore - score_max(weights['report_warning'] * report_warning, maximpacts['report_warning'])
    oboscore = oboscore - score_max(weights['report_info'] * report_info, maximpacts['report_info'])
    return "%.2f" % oboscore


def round_float(n):
    strfloat = "%.3f" % n
    return (float(strfloat))

def score_max(score,maxscore):
    if score > maxscore:
        return maxscore
    else:
        return score

def get_prefix_from_url_namespace(ns, curie_map):
    for prefix in curie_map:
        if ns==curie_map[prefix]:
            return prefix
    if ns.startswith(obo_purl) and ns.endswith("_"):
        ns = ns.replace(obo_purl,"")
        ns = ns[:-1]
        return ns
    msg = f"Namespace {ns} not found in curie map, aborting.."
    raise Exception(msg)

def get_base_prefixes(curie_map, base_namespaces):
    internal_ns = []
    for ns in base_namespaces:
        prefix = get_prefix_from_url_namespace(ns, curie_map)
        internal_ns.append(prefix)
    return internal_ns

def compute_percentage_reused_entities(entity_use_map, internal_ns):
    internal_entities = 0
    external_entities = 0
    for prefix in entity_use_map:
        if prefix in internal_ns:
            internal_entities += entity_use_map[prefix]
        else:
            external_entities += entity_use_map[prefix]

    reuse_score = 100*(external_entities/(external_entities+internal_entities))
    score_string = "%.2f" % round(reuse_score, 2)
    return float(score_string)
