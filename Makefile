sources/upheno/upheno_mapping_lexical.csv:
	wget https://data.monarchinitiative.org/upheno2/current/upheno-release/all/upheno_mapping_lexical.csv -O $@
	
sources/upheno/upheno_mapping_logical.csv:
	wget https://data.monarchinitiative.org/upheno2/current/upheno-release/all/upheno_mapping_logical.csv -O $@
	
sources: sources/upheno/upheno_mapping_lexical.csv
sources: sources/upheno/upheno_mapping_logical.csv

tmp/:
	mkdir -p $@

tmp/owlsim.cache: | tmp/
	wget https://archive.monarchinitiative.org/latest/owlsim/owlsim.cache -O $@

sources/monarch_mp_hp_sim.tsv: #tmp/owlsim.cache
	echo "subject_id	object_id	information_content_mica_score	mica" | cat tmp/owlsim.cache | grep MP_.*HP_.*_ | sed 's/_/:/g'  > $@





#######################################
##### Mappings 

.PHONY: mappings
mappings: ./scripts/update_registry.py
	python $< update-registry -r mappings.yml

mappings/%_sssom.tsv:
	sh scripts/ingest/$*.sh $@

.PHONY: mapping_set_%
mapping_set_%: mappings/%_sssom.tsv
	echo "Build $<"

### IMPC Mappings ######

mappings/mp_hp_impc_eye_sssom.tsv: sources/impc/sssom/impc_eye_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_hwt_sssom.tsv: sources/impc/sssom/impc_hwt_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_owt_sssom.tsv: sources/impc/sssom/impc_owt_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/ma_uberon_impc_pat_sssom.tsv: sources/impc/sssom/impc_pat_003_ma_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_pat_sssom.tsv: sources/impc/sssom/impc_pat_003_mp_terms_30_oct_2020.tsv
	cp $< $@

mappings/pato_hp_impc_pat_sssom.tsv: sources/impc/sssom/impc_pat_003_pato_terms_30_oct_2020.tsv
	cp $< $@

mappings/mp_hp_impc_xry_sssom.tsv: sources/impc/sssom/impc_xry_003_mp_terms_30_oct_2020.tsv
	cp $< $@



	