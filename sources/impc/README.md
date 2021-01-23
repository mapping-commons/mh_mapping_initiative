# IMPC mappings

## IMPC mapping methodology

1. Identify terms ... TODO

## Methodology to turn into SSSOM

1. From the raw mapping tables (xlsx format), we extract four column:
   1. MP/MA/PATO ontology term
   1. MP/MA/PATO ontology term name
   1. HP/UBERON ontology term
   1. HP/UBERON ontology term name
1. Given the official IMPC colour coding (Exact match: white; Lexical match: green; Logical match: yellow; No match: orange) the following default determinations are made:
   1. `Exact match`:
      - match_type: SSSOM:Lexical
      - predicate_id: skos:exactMatch
   1. `Lexical match`:
      - match_type: SSSOM:Lexical
      - predicate_id: skos:closeMatch
   1. `Logical match`:
      - match_type: SSSOM:Logical
      - predicate_id: skos:closeMatch
   1. `No match`:
      - match_type: SSSOM:HumanCurated
      - predicate_id: skos:closeMatch
1. After this default assignment, we asked two Mouse and two Human curators to review the resulting matches, and specify them if possible to one of the following:
   - skos:exactMatch
   - skos:narrowMatch
   - skos:broadMatch
