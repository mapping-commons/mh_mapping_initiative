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
	tsvalid $(MAPPINGS_DIR)/$*.sssom.tsv --comment "#"
	sssom validate $(MAPPINGS_DIR)/$*.sssom.tsv
	sssom convert $(MAPPINGS_DIR)/$*.sssom.tsv -o $(MAPPINGS_DIR)/$*.sssom.ttl

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

##################################

EFO_OBA_URL=https://raw.githubusercontent.com/obophenotype/bio-attribute-ontology/master/src/mappings/oba-efo.sssom.tsv

mappings/efo-oba.sssom.tsv:
	wget "$(EFO_OBA_URL)" -O $@
.PRECIOUS: mappings/efo-oba.sssom.tsv

UPHENO_OBA_URL=https://github.com/obophenotype/upheno-dev/blob/master/src/ontology/reports/phenotype_trait.sssom.tsv

tmp/impc_traits.tsv:
	wget https://raw.githubusercontent.com/obophenotype/upheno-dev/master/src/ontology/reports/impc_traits.tsv -O $@

tmp/gwas_traits.tsv:
	wget https://raw.githubusercontent.com/obophenotype/upheno-dev/master/src/ontology/reports/gwas_traits.tsv -O $@

mappings/upheno-oba.tsv:
	wget "$(UPHENO_OBA_URL)" -O $@
.PRECIOUS: mappings/mp-oba.sssom.tsv

mappings/mp-oba.sssom.tsv: mappings/upheno-oba.tsv
	python python scripts/mh_mapping_commongs.py hp-oba $< > $@ mp-oba $< > $@
.PRECIOUS: mappings/mp-oba.sssom.tsv

mappings/hp-oba.sssom.tsv:  mappings/upheno-oba.tsv
	python scripts/mh_mapping_commons.py hp-oba $< > $@
.PRECIOUS: mappings/hp-oba.sssom.tsv

MP_EFO_URL=https://raw.githubusercontent.com/obophenotype/upheno-dev/master/src/ontology/reports/mp-efo.sssom.tsv
mappings/mp-efo.sssom.tsv:
	wget "$(MP_EFO_URL)" -O $@

mappings/mp-hp.sssom.tsv: mappings/upheno-species-independent.sssom.tsv
	python scripts/mh_mapping_commons.py mp-hp $< > $@

mappings/mp-efo.sssom.tsv:  mappings/efo-oba.sssom.tsv \
							mappings/mp-oba.sssom.tsv \
							mappings/mp-hp.sssom.tsv \
							mappings/mp-efo.sssom.tsv \
							tmp/gwas_traits.tsv \
							tmp/impc_traits.tsv
	python3 scripts/mh_mapping_commons.py mappings/efo-oba.sssom.tsv mappings/mp-oba.sssom.tsv mappings/mp-impc.sssom.tsv > $@

