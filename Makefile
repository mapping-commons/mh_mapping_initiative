MAPPINGS_DIR=mappings

sources/upheno/upheno_mapping_lexical.csv:
	wget https://data.monarchinitiative.org/upheno2/current/upheno-release/all/upheno_mapping_lexical.csv -O $@
	
sources/upheno/upheno_mapping_logical.csv:
	wget https://data.monarchinitiative.org/upheno2/current/upheno-release/all/upheno_mapping_logical.csv -O $@
	
sources: sources/upheno/upheno_mapping_lexical.csv
sources: sources/upheno/upheno_mapping_logical.csv

tmp/:
	mkdir -p $@


#######################################
##### Mapping validation  #############
#######################################

validate-%:
	sssom validate $(MAPPINGS_DIR)/$*.sssom.tsv

MAPPINGS=$(notdir $(wildcard $(MAPPINGS_DIR)/*.sssom.tsv))
VALIDATE_MAPPINGS=$(patsubst %.sssom.tsv, validate-%, $(notdir $(wildcard $(MAPPINGS_DIR)/*.sssom.tsv)))

validate_mappings: $(VALIDATE_MAPPINGS)

#######################################
##### Mappings  #######################
#######################################

.PHONY: mappings
mappings: ./scripts/update_registry.py
	python $< update-registry -r registry.yml

### IMPC Mappings ######

mappings/mp_hp_eye_impc.sssom.tsv: sources/impc/sssom/impc_eye_003_mp_terms_30_oct_2020.tsv
	sssom parse $< --metadata sources/impc/basic_sssom_metadata.yml -o $@
	sssom annotate $@ --mapping_set_id=mp_hp_eye_impc --mapping_set_description="The IMPC Mouse Morphology Mappings: Eye Morphology Test" -o $@

mappings/mp_hp_hwt_impc.sssom.tsv: sources/impc/sssom/impc_hwt_003_mp_terms_30_oct_2020.tsv
	sssom parse $< --metadata sources/impc/basic_sssom_metadata.yml -o $@
	sssom annotate $@ --mapping_set_id=mp_hp_hwt_impc --mapping_set_description="The IMPC Mouse Morphology Mappings: Heart Weight Test" -o $@

mappings/mp_hp_owt_impc.sssom.tsv: sources/impc/sssom/impc_owt_003_mp_terms_30_oct_2020.tsv
	sssom parse $< --metadata sources/impc/basic_sssom_metadata.yml -o $@
	sssom annotate $@ --mapping_set_id=mp_hp_owt_impc --mapping_set_description="The IMPC Mouse Morphology Mappings: Organ Weight Test" -o $@

mappings/ma_uberon_pat_impc.sssom.tsv: sources/impc/sssom/impc_pat_003_ma_terms_30_oct_2020.tsv
	sssom parse $< --metadata sources/impc/basic_sssom_metadata.yml -o $@
	sssom annotate $@ --mapping_set_id=ma_uberon_pat_impc --mapping_set_description="The IMPC Mouse Morphology Mappings: Gross Pathology & Tissue Collection Test (Anatomy)" -o $@

mappings/mp_hp_pat_impc.sssom.tsv: sources/impc/sssom/impc_pat_003_mp_terms_30_oct_2020.tsv
	sssom parse $< --metadata sources/impc/basic_sssom_metadata.yml -o $@
	sssom annotate $@ --mapping_set_id=mp_hp_pat_impc --mapping_set_description="The IMPC Mouse Morphology Mappings: Gross Pathology & Tissue Collection Test (Phenotype)" -o $@

mappings/pato_hp_pat_impc.sssom.tsv: sources/impc/sssom/impc_pat_003_pato_terms_30_oct_2020.tsv
	sssom parse $< --metadata sources/impc/basic_sssom_metadata.yml -o $@
	sssom annotate $@ --mapping_set_id=pato_hp_pat_impc --mapping_set_description="The IMPC Mouse Morphology Mappings: Gross Pathology & Tissue Collection Test (PATO)" -o $@

mappings/mp_hp_xry_impc.sssom.tsv: sources/impc/sssom/impc_xry_003_mp_terms_30_oct_2020.tsv
	sssom parse $< --metadata sources/impc/basic_sssom_metadata.yml -o $@
	sssom annotate $@ --mapping_set_id=mp_hp_xry_impc --mapping_set_description="The IMPC Mouse Morphology Mappings: X-ray Test" -o $@

#### Pistoia mappings ####

mappings/%_pistoia.sssom.tsv: sources/pistoia/calculated_output_%.rdf
	sssom parse $< --input-format alignment-api-xml --prefix-map-mode sssom_default_only -o $@
	sssom annotate $@ --mapping_set_id=$*_pistoia --mapping_provider="https://www.pistoiaalliance.org/projects/current-projects/ontologies-mapping/" --license="https://creativecommons.org/publicdomain/zero/1.0/" --mapping_set_description="The Pistoia Ontology Mappings: $*" -o $@

.PHONY: mapping_set_%
mapping_set_%: mappings/%.sssom.tsv
	echo "Build $<"