# Mouse-Human Ontology Mapping Initiative (MHMI)

Studying the phenotypic effects of genes is critical to understanding disease. The phenotypic effects of variants and lesions in large numbers of mouse genes are known due to the accumulated small-scale efforts of the mouse genetics community combined with a large amount of data from genome-wide gene targeting combined with systematic phenotyping. This data can be leveraged to help understand phenotypes not only in mice, but also in humans. A key component required for the integration of human and mouse phenotype data is meaningfully linking the dominant controlled vocabularies (ontologies) used for describing phenotype. For human data the Human Phenotype Ontology is widely used, while for mouse (and rat) data, the Mammalian Phenotype ontology is typically used. 

There are roughly four categories of such mapping approaches:
- __Manually curated mappings:__ An expert determines correspondences between a set of terms from one terminology to another. There are many potential mappings, so most manual curation efforts cater for a specific use case (mappings of phenotypic abnormalities relevant to COVID or Alzheimers, for example). 
- __Automated terminological mappings:__ A mapping algorithm takes two or more vocabularies as an input and attempts to create cross-vocabulary links between the terms by using a variety of approaches, from terminological mappings (e.g. based on label, natural language information) to graph-based approaches. These links usally manifest themselves as semantic mapping relations such as exact, broad, narrow and close matches. Mappings of this kind are used for many different use cases, such as knowledge graph integration (https://monarchinitiative.org/) and data aggregation across species.
- __Automated phenotpyic similarity profiles:__ A semantic similarity algorithm takes two or more vocabularies as an input and computes cross-vocabulary links based on semantic similarity measures (e.g. Jaccard, Resnik, Cosine). A semantic similarity profile does not specify a semantic mapping relation such as "exact", "broad" etc (see above). Instead, a pair of terms (for example a mouse and human phenotype term) is associated with a semantic similarity score, usally between 0 and 1, where 1 indicates equivalence. Tools such as [Exomiser](https://www.nature.com/articles/nprot.2015.124), an NHS accredited tool for variant prioritisation and rare disease diagnostics, make heavy use of such phenotypic profiles (especially HP-MP). 
- __Computable phenotype definitions:__ Experts define the phenotypes they are using (for example in the Human Phenotype Ontology) using standardised design patterns. Definitions developed this way are interoperable across species and can be exploited by an automated reasoner to compute logical relationships between phenotypes. The most significant efforts in this direction are the [Unified Phenotype Ontology](https://ols.monarchinitiative.org/ontologies/upheno2) and [Phenome.NET](https://pubmed.ncbi.nlm.nih.gov/21737429/), which seek to integrate a large number of different species-specific phenotype ontologies. The leading international effort for developing standardised design patterns is the [Phenotype Reconciliation Effort](https://github.com/obophenotype/upheno/wiki/Phenotype-Ontologies-Reconciliation-Effort).

The first complication of all these are approaches is that they are _error prone_ for different reasons. The most important reasons are:
1. _Experts make mistakes_ - both when manually mapping and when defining computable phenotype definitions. Often this is due to ambiguity and variation in the use of language to describe phenotypes.
2. Some _assumptions_ are made during the mapping process, for example: 
   - How "rough/vague" a mapping is still acceptable in my case, if an exact match cannot be found (this differs from use case to use case)? Should Fever be mapped to increased body temperature?  Should Shivering be mapped to tremors?
   - Should I define my phenotype in terms of a physical measurement or observation  or in terms of an abnormal biological process (abnormally increased levels of insulin vs abnormally increased insulin production)? 

Furthermore, analysts may expect mappings to different degrees of fuzziness - from crisp 1:1 mappings to n:n mappings determined by phenotypic similarity.

Next, all approaches are to some degree _incomplete_. Manually curated mappings fill the gap where automated mapping approaches, which largely rely on terminological content, fail to perform well (or at all), but they are usually curated for a specific use case (mappings of phenotypic abnormalities relevant to COVID or Alzheimers, for example). Automatic mappings fail to perform well especially in the area of phenotype due to the often largely divergent terminological content (e.g. preferred labels used by clinical vs. model organism communities).

Lastly, all approaches have some degree of interdependence. For example, the automated mappings are used to augment cases where no logical definitions / design patterns exist, and logical definitions, in turn, are used to compute mappings.

The MHMI aims to collect and standardise the dissemination of mouse-phenotype mappings and develop a set of best practices for their use. It leverages advanced tooling to compute mappings and reconcile them with manually curated ones, mitigating the problems above.

If you are interested in taking part in the Initiative or have use cases that you feel would benefit from these mappings, feel free to join the [Monarch Initiative \& Friends Mailing list](https://groups.google.com/g/monarch-friends) and drop us a message. 

Current active/prospective participants and contributors include:

| Name | Github | Institution | Role |
| ---- | ------- | ----------- | ----- |
| David Osumi-Sutherland | @dosumis | EMBL-EBI, Monarch Initiative | Coordinator, semantics specialist |
| Susan Bello | @sbello| JAX, MGI, Alliance of Genome Resources | Coordinator, ontology engineer, bio-curator |
| Nicolas Matentzoglu | @matentzn | Semanticly, Monarch Initiative | Coordinator, semantic engineer |
| Anna Anagnostopoulos | @anna-anagnostop| JAX, MGI, Alliance of Genome Resources | ontology engineer, bio-curator |
| Nicole Vasilevsky | @nicolevasilevsky| OHSU, Monarch Initiative | ontology engineer, bio-curator |
| Leigh Carmody | @LCCarmody| JAX, Monarch Initiative | ontology engineer, bio-curator |
| Anna Anagnostopoulos | @anna-anagnostop| JAX, MGI, Alliance of Genome Resources | ontology engineer, bio-curator |
| Thomas Liener | @LLTommy | Pistoia Alliance | semantic engineer |
| Ben Stear | @benstear | Department of Biomedical and Health Informatics, Children's Hospital of Philadelphia | Bioinformatics Scientist I |
| Deanne Taylor | @taylordm | Department of Biomedical and Health Informatics, Children's Hospital of Philadelphia | Director of Bioinformatics |
| Francisco Requena | @frequena | Institut Imagine (Paris) | Ph.D. Student at the Clinical Bioinformatics lab |
| Justin Reese | @justaddcoffee | Lawrence Berkeley Lab | computational biologist |
| Li Xiaoxu | @xianshu-li | Laboratoire de Physiologie Intégrative et Systémique (EPFL) | |
| Violeta Munoz Fuentes | @viomunoz | EMBL-EBI, IMPC | |
| Colin McKerlie |  | The Hospital for Sick Children | PI, Comparative Pathologist |


## Specific goals

### Collecting all manually curated MP-HP mappings in one place and offering them in a standard format

- Many manual mappings between MP and HP have been performed for various purposes (COVID (MGI effort), IMPC knockouts, HPO, MPO xrefs, HMDC phenotype headers (MGI Effort))
- During our uPheno evaluation efforts, we often review automated mapping based on logical inferences. There should be a separate effort to store manually reviewed mappings of automated approaches, which we could use for validation -> when previously validated inferences suddenly disappear, etc.
We will offer these manually curated mappings in a standard format (SSSOM)

Sub goals:
- Tightly align the upper levels of HP/MP to be able to provide some sanity checking for automated approaches.

### Build a conceptual and empirical model for using various forms of automated mappings for stakeholder use cases

- We will offer a range of automated mappings, from label based, EQ based to semantic similarity and traditional automated mapping approaches using the approaches explored by the OAEI.
- We will document their use cases carefully, and offer simple python notebooks for example evaluations.
- We will develop a model on how to evaluate the effectiveness of automated mapping approaches for the use cases provided by our stakeholders.
- We will determine the set of interventions needed to gradually improve automated approaches in a scalable and sustainable way.

### Build infrastructure to combine automated and manually curated mappings

- There is a huge potential in using automated approaches to validate manual curations. For example, manual mappings could be compared to semantic similarity mappings, with a low semantic similarity indicating problematic choices.
- On the flipside, expert-level mappings can be used as gold standards to evaluate automated mapping approaches. Such information can lead directly to tweaks in the mapping algorithms, but also indicate areas in the ontology that could benefit from more careful axiomatisation or reconciliation.

### Initial stakeholder use cases in focus of working group

- Increasing the clinical relevance of search results on mouse-phenotyping.org (IMPC) of mouse phenotyping in general
- Variant prioritisation 
   - for diagnosis of children with developmental disorders (CHOP)
   - of rare disease patients (Exomiser)


## Stakeholder use cases for mouse-phenotype mappings using ontologies

*Deanne Taylor*, Director of Bioinformatics, Department of Biomedical and Health Informatics, Children's Hospital of Philadelphia:

> Congenital birth defects and other developmental disorders likely result from mistiming in the regulated choreography of early development.  Perturbations arise from a combination of genetic, epigenetic and environmental factors. There is a great interest (and much work) spent in identifying the specific genetic elements that may contribute to a birth-defect related phenotype  Mice are most often used for "genetic laboratories" for comparison to human development.  For instance, in gene-to-phenotype studies such as found in the IMPC, a mouse gene is disabled or manipulated,  and then the phenotype profile is measured. If the phenotype resembles a human congenital birth defect, we can test for similar changes in genomes from children with that condition.  The IMPC classifies phenotypes in Mammalian Phenotype Ontology (MP). Disorders of early development often impact physiology in striking and visible ways, so are easily systematized, and organisms can be classified based on those obsevations.   
> Fyler code system was the earliest known example for comprehensively classifying congenital birth defects (https://link.springer.com/chapter/10.1007/978-1-4471-6587-3_12 ).  Both the MP and HPO have Fyler code annotations within relevant terms.  It would be useful to use the Fyler codes as a “silver standard” (not gold – we’re not there yet!) to determine how well we can match up congenital defect MP and HPO codes. Our simple use case: First, establish a gold standard crosswalk on developmental defects (MP/HPO).  Can we identify all truly matching MP/HPO links between Kids First and IMPC, with a crosswalk on at least on Fyler codes or other associated HPO terms

*Ben Stear*, Bioinformatics Scientist I, Department of Biomedical and Health Informatics, Children's Hospital of Philadelphia: 

> Our main use case is to identify genes of interest from children with cancer/structural birth defects. When a child comes in with a birth defect we want to be able to map their phenotype(s) to the corresponding mouse phenotype(s) in order to take advantage of the extensive gene-knockout research that's been done in mice. Once we have identified the corresponding mouse phenotype, we can then identify genes associated with that phenotype, and then from there get a list of human orthologs for further analysis. 


*Violeta Munoz-Fuentes*, Mouse Informatics, EMBL-EBI

> The IMPC is making a catalogue of gene function using the mouse as a model, knocking out one protein gene at a time and recording the phenotype alterations that are observed in the knockout (KO) mice as compared to the wildtype or background strain. By understanding the physiological systems that get affected, the IMPC can link gene with function. Significant phenotype alterations in the KO mice are primarily annotated using the Mammalian Phenotype Ontology, but other ontologies may also be used, as needed (MA, MPATH, PATO, Uberon, EMAPA).
The ultimate goal of the IMPC is to help diagnose human disease. One way to get support for the involvement of a rare variant found in the genome of a patient with a rare disease is by phenorreplication of the patient’s phenotype in an animal model for which that gene has been knocked out (or the variant engineered). In the case of the IMPC, these phenotypes are described primarily using MP terms. Because patients can be / are described using HP terms, there is a need for MP – HP mappings. Some example use cases: 
> 1.	A clinician has a patient with a rare disease. After sequencing, several genes are identified as potential candidates. The clinician looks up the genes orthologous to the human genes in the IMPC (or other) database. These genes are annotated with significant MP terms, but the clinician needs to see them mapped to HP terms, as the latter are the ones that are used to describe the patient.
> 2.	A researcher wants to find genes associated with the cardiovascular function in humans. The researcher looks up “cardiovascular disease” (EFO term) in the GWAS Catalog and 331 variants are reported. Both genes and traits associated with these variants are listed (traits are curated from publications and mapped to the EFO). The researcher wants to see, for the orthologous mouse genes in the IMPC database, which phenotypes are reported in mice, and which ones are not ([issue](https://github.com/obophenotype/mp_hp_mapping/issues/1)).
> 3.	A researcher has a subset of IMPC genes that are associated with the cardiovascular function. S/he maps them to the orthologous human genes and looks them up in Open Targets (EFO 3). S/he wants to know which of the phenotype hits reported in humans are also reported in mice and which ones are not. 

 

*Francisco Requena*, Ph.D. Student at the Clinical Bioinformatics lab, Institut Imagine (Paris):

> My work consists of the interpretation of the mutations found in the DNA of patients with genetic diseases. Phenotypic similarity analysis allows us to take advantage of patients' clinical features to find the causal gene(s). Unfortunately, hundreds of new associations of genetic diseases are discovered every year. Therefore, our current knowledge about the associations of HP terms and genes is limited. As an alternative, we have available extensive information on the effect of altered genes in mouse models with their respective phenotypical consequences. For those genes without HP term annotation, an interesting approach is semantic similarity between MP terms (mouse model) and HP terms (patient).


*Li Xiaoxu*, Laboratoire de Physiologie Intégrative et Systémique (EPFL)

> My project revolves around using our large datasets in mouse genetic reference populations (https://www.systems-genetics.org/, PMID: 29199021) to infer information about humans. One important step in this procedure is matching the many phenotypes we measured in the mice to their human equivalents, hence my interest.


