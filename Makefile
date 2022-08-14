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
	python $< update-registry -r mappings.yml

### IMPC Mappings ######

mappings/mp_hp_impc_eye.sssom.tsv: sources/impc/sssom/impc_eye_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_hwt.sssom.tsv: sources/impc/sssom/impc_hwt_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_owt.sssom.tsv: sources/impc/sssom/impc_owt_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/ma_uberon_impc_pat.sssom.tsv: sources/impc/sssom/impc_pat_003_ma_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_pat.sssom.tsv: sources/impc/sssom/impc_pat_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/pato_hp_impc_pat.sssom.tsv: sources/impc/sssom/impc_pat_003_pato_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_xry.sssom.tsv: sources/impc/sssom/impc_xry_003_mp_terms_30_oct_2020.tsv
	cp $< $@

CONTEXT_URL=https://raw.githubusercontent.com/biolink/biolink-model/master/context.jsonld
mappings_context.yml:
	wget $(CONTEXT_URL) -O $@

mappings/%_pistoia.sssom.tsv: sources/pistoia/calculated_output_%.rdf mappings_context.yml
	sssom convert -i $< -f alignment-api-xml -c mappings_context.yml -o $@

mappings/%.sssom.tsv:
	sh scripts/ingest/$*.sh $@

.PHONY: mapping_set_%
mapping_set_%: mappings/%.sssom.tsv
	echo "Build $<"