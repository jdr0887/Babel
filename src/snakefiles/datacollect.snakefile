import src.datahandlers.mesh as mesh
import src.datahandlers.obo as obo
import src.datahandlers.umls as umls
import src.datahandlers.ncbigene as ncbigene
import src.datahandlers.ensembl as ensembl
import src.datahandlers.hgnc as hgnc
import src.datahandlers.omim as omim
import src.datahandlers.uniprotkb as uniprotkb
import src.datahandlers.mods as mods
import src.datahandlers.ncit as ncit
import src.datahandlers.doid as doid
import src.datahandlers.orphanet as orphanet
import src.datahandlers.reactome as reactome
import src.datahandlers.rhea as rhea
import src.datahandlers.ec as ec
import src.datahandlers.smpdb as smpdb
import src.datahandlers.pantherpathways as pantherpathways
import src.datahandlers.unichem as unichem
import src.datahandlers.chembl as chembl
import src.datahandlers.gtopdb as gtopdb
import src.datahandlers.kegg as kegg
import src.datahandlers.unii as unii
import src.datahandlers.hmdb as hmdb
import src.datahandlers.pubchem as pubchem
import src.datahandlers.drugcentral as drugcentral
import src.datahandlers.ncbitaxon as ncbitaxon
import src.datahandlers.chebi as chebi
import src.datahandlers.hgncfamily as hgncfamily
import src.datahandlers.pantherfamily as pantherfamily
import src.datahandlers.complexportal as complexportal

import src.prefixes as prefixes

#####
#
# Data sets: pull data sets, and parse them to get labels and synonyms
#
####

### Complex Portal
# https://www.ebi.ac.uk/complexportal/

rule get_complexportal:
    output:
        config['download_directory']+'/ComplexPortal'+'/559292.tsv'
    run:
        complexportal.pull_complexportal()

rule get_complexportal_labels_and_synonyms:
    input:
        infile = config['download_directory']+'/ComplexPortal'+'/559292.tsv'
    output:
        lfile = config['download_directory']+'/ComplexPortal'+'/559292_labels.tsv',
        sfile = config['download_directory']+'/ComplexPortal'+'/559292_synonyms.tsv'
    run:
        complexportal.make_labels_and_synonyms(input.infile, output.lfile, output.sfile)

### MODS

rule get_mods:
    output:
        expand("{download_directory}/{mod}/GENE-DESCRIPTION-JSON_{mod}.json", download_directory = config['download_directory'], mod = config['mods']),
    run:
        mods.pull_mods()

rule get_mods_labels:
    input:
        expand("{download_directory}/{mod}/GENE-DESCRIPTION-JSON_{mod}.json",download_directory=config['download_directory'], mod=config['mods']),
    output:
        expand("{download_directory}/{mod}/labels",download_directory=config['download_directory'], mod=config['mods']),
    run:
        mods.write_labels(config['download_directory'])

### UniProtKB

rule get_uniprotkb:
    output:
        config['download_directory']+'/UniProtKB/uniprot_sprot.fasta',
        config['download_directory']+'/UniProtKB/uniprot_trembl.fasta',
        config['download_directory']+'/UniProtKB/idmapping.dat'
    run:
        uniprotkb.pull_uniprotkb()

rule get_uniprotkb_labels:
    input:
        sprot_input=config['download_directory']+'/UniProtKB/uniprot_sprot.fasta',
        trembl_input=config['download_directory']+'/UniProtKB/uniprot_trembl.fasta',
    output:
        outfile=config['download_directory']+'/UniProtKB/labels'
    run:
        uniprotkb.pull_uniprot_labels(input.sprot_input,input.trembl_input,output.outfile)

### MESH

rule get_mesh:
    output:
        config['download_directory']+'/MESH/mesh.nt'
    run:
        mesh.pull_mesh()

rule get_mesh_labels:
    input:
        config['download_directory']+'/MESH/mesh.nt'
    output:
        config['download_directory']+'/MESH/labels'
    run:
        mesh.pull_mesh_labels()

rule get_mesh_synonyms:
    #We don't actually get any.  Maybe we could from the nt?
    output:
        ofn=config['download_directory']+'/MESH/synonyms'
    shell:
        "touch {output.ofn}"

### UMLS / SNOMEDCT

rule get_umls_labels_and_synonyms:
    output:
        config['download_directory']+'/UMLS/labels',
        config['download_directory']+'/UMLS/synonyms',
        config['download_directory']+'/SNOMEDCT/labels',
        config['download_directory']+'/SNOMEDCT/synonyms'
    run:
        umls.pull_umls()

### OBO Ontologies

rule get_ontology_labels_and_synonyms:
    output:
        expand("{download_directory}/{onto}/labels", download_directory = config['download_directory'], onto = config['ubergraph_ontologies']),
        expand("{download_directory}/{onto}/synonyms", download_directory = config['download_directory'], onto = config['ubergraph_ontologies'])
    run:
        obo.pull_uber(config['ubergraph_ontologies'])

### NCBIGene

rule get_ncbigene:
    output:
        getfiles=expand("{download_directory}/NCBIGene/{ncbi_files}", download_directory=config['download_directory'],ncbi_files=config['ncbi_files'])
    run:
        ncbigene.pull_ncbigene(config['ncbi_files'])

rule get_ncbigene_labels_and_synonyms:
    output:
        config['download_directory']+'/NCBIGene/labels',
        config['download_directory']+'/NCBIGene/synonyms'
    input:
        config['download_directory']+'/NCBIGene/gene_info.gz'
    run:
        ncbigene.pull_ncbigene_labels_and_synonyms()

### ENSEMBL

rule get_ensembl:
    output:
        outfile=config['download_directory']+'/ENSEMBL/BioMartDownloadComplete'
    run:
        ensembl.pull_ensembl(output.outfile)

### HGNC

rule get_hgnc:
    output:
        outfile=config['download_directory']+'/HGNC/hgnc_complete_set.json'
    run:
        hgnc.pull_hgnc()

rule get_hgnc_labels_and_synonyms:
    output:
        config['download_directory']+'/HGNC/labels',
        config['download_directory']+'/HGNC/synonyms'
    input:
        infile=rules.get_hgnc.output.outfile
    run:
        hgnc.pull_hgnc_labels_and_synonyms(input.infile)

### HGNC.FAMILY

rule get_hgncfamily:
    output:
        outfile=config['download_directory'] + '/HGNC.FAMILY/family.csv'
    run:
        hgncfamily.pull_hgncfamily()

rule get_hgncfamily_labels:
    input:
        infile=rules.get_hgncfamily.output.outfile
    output:
        outfile = config['download_directory'] + '/HGNC.FAMILY/labels',
    run:
        hgncfamily.pull_labels(input.infile,output.outfile)

### PANTHER.FAMILY

rule get_pantherfamily:
    output:
        outfile=config['download_directory'] + '/PANTHER.FAMILY/family.csv'
    run:
        pantherfamily.pull_pantherfamily()

rule get_pantherfamily_labels:
    input:
        infile=rules.get_pantherfamily.output.outfile
    output:
        outfile = config['download_directory'] + '/PANTHER.FAMILY/labels',
    run:
        pantherfamily.pull_labels(input.infile,output.outfile)


### OMIM

rule get_omim:
    output:
        outfile=config['download_directory']+'/OMIM/mim2gene.txt'
    run:
        omim.pull_omim()


### NCIT

rule get_ncit:
    output:
        outfile = config['download_directory']+'/NCIT/NCIt-SwissProt_Mapping.txt'
    run:
        ncit.pull_ncit()

### DOID

rule get_doid:
    output:
        outfile = config['download_directory']+'/DOID/doid.json'
    run:
        doid.pull_doid()

rule get_doid_labels_and_synonyms:
    input:
        infile = config['download_directory']+'/DOID/doid.json'
    output:
        labelfile = config['download_directory'] + '/DOID/labels',
        synonymfile = config['download_directory'] + '/DOID/synonyms'
    run:
        doid.pull_doid_labels_and_synonyms(input.infile, output.labelfile, output.synonymfile)

### Orphanet

rule get_orphanet:
    output:
        outfile = config['download_directory']+'/Orphanet/Orphanet_Nomenclature_Pack_EN.zip'
    run:
        orphanet.pull_orphanet()

rule get_orphanet_labels_and_synonyms:
    input:
        infile = config['download_directory']+'/Orphanet/Orphanet_Nomenclature_Pack_EN.zip'
    output:
        labelfile = config['download_directory'] + '/Orphanet/labels',
        synonymfile = config['download_directory'] + '/Orphanet/synonyms'
    run:
        orphanet.pull_orphanet_labels_and_synonyms(input.infile, output.labelfile, output.synonymfile)

### Reactome

rule get_reactome:
    output:
        outfile = config['download_directory']+'/REACT/Events.json'
    run:
        reactome.pull_reactome(output.outfile)

rule get_reactome_labels:
    input:
        infile=config['download_directory'] + '/REACT/Events.json',
    output:
        labelfile=config['download_directory'] + '/REACT/labels',
    run:
        reactome.make_labels(input.infile,output.labelfile)

### RHEA

rule get_rhea:
    output:
        outfile = config['download_directory'] + '/RHEA/rhea.rdf',
    run:
        rhea.pull_rhea()

rule get_rhea_labels:
    input:
        infile=config['download_directory'] + '/RHEA/rhea.rdf',
    output:
        labelfile=config['download_directory'] + '/RHEA/labels',
    run:
        rhea.make_labels(output.labelfile)

### EC

rule get_EC:
    output:
        outfile = config['download_directory'] + '/EC/enzyme.rdf'
    run:
        ec.pull_ec()

rule get_EC_labels:
    input:
        infile=config['download_directory'] + '/EC/enzyme.rdf'
    output:
        labelfile=config['download_directory'] + '/EC/labels',
        synonymfile =config['download_directory'] + '/EC/synonyms'
    run:
        ec.make_labels(output.labelfile,output.synonymfile)

### SMPDB

rule get_SMPDB:
    output:
        outfile=config['download_directory'] + '/SMPDB/smpdb_pathways.csv'
    run:
        smpdb.pull_smpdb()

rule get_SMPDB_labels:
    input:
        infile=config['download_directory'] + '/SMPDB/smpdb_pathways.csv'
    output:
        labelfile=config['download_directory'] + '/SMPDB/labels'
    run:
        smpdb.make_labels(input.infile,output.labelfile)

### PantherPathways

rule get_panther_pathways:
    output:
        outfile = config['download_directory'] + '/PANTHER.PATHWAY/SequenceAssociationPathway3.6.6.txt'
    run:
        pantherpathways.pull_panther_pathways()

rule get_panther_pathway_labels:
    input:
        infile=config['download_directory'] + '/PANTHER.PATHWAY/SequenceAssociationPathway3.6.6.txt'
    output:
        labelfile=config['download_directory'] + '/PANTHER.PATHWAY/labels'
    run:
        pantherpathways.make_pathway_labels(input.infile,output.labelfile)

### Unichem

rule get_unichem:
    output:
        config['download_directory'] + '/UNICHEM/UC_XREF.txt.gz',
        config['download_directory'] + '/UNICHEM/UC_STRUCTURE.txt',
    run:
        unichem.pull_unichem()

rule filter_unichem:
    input:
        infile= config ['download_directory'] + '/UNICHEM/UC_XREF.txt.gz'
    output:
        outfile=config['download_directory']+'/UNICHEM/UC_XREF.srcfiltered.txt'
    run:
        unichem.filter_xrefs_by_srcid(input.infile,output.outfile)

### CHEMBL

rule get_chembl:
    output:
        moleculefile=config['download_directory']+'/CHEMBL.COMPOUND/chembl_latest_molecule.ttl',
        ccofile=config['download_directory']+'/CHEMBL.COMPOUND/cco.ttl'
    run:
        chembl.pull_chembl(output.moleculefile)

rule chembl_labels_and_smiles:
    input:
        infile=config['download_directory']+'/CHEMBL.COMPOUND/chembl_latest_molecule.ttl',
        ccofile=config['download_directory']+'/CHEMBL.COMPOUND/cco.ttl',
    output:
        outfile=config['download_directory']+'/CHEMBL.COMPOUND/labels',
        smifile=config['download_directory']+'/CHEMBL.COMPOUND/smiles'
    run:
        chembl.pull_chembl_labels_and_smiles(input.infile,input.ccofile,output.outfile,output.smifile)

### DrugBank requires a login... not sure how to handle

### GTOPDB We're only pulling ligands.  Maybe one day we'll want the whole db?

rule get_gtopdb:
    output:
        outfile=config['download_directory']+'/GTOPDB/ligands.tsv'
    run:
        gtopdb.pull_gtopdb_ligands()

rule gtopdb_labels_and_synonyms:
    input:
        infile=config['download_directory']+'/GTOPDB/ligands.tsv'
    output:
        labelfile=config['download_directory']+'/GTOPDB/labels',
        synfile  =config['download_directory']+'/GTOPDB/synonyms'
    run:
        gtopdb.make_labels_and_synonyms(input.infile,output.labelfile,output.synfile)

#KEGG We're also only getting compounds now.  And we're going through the api b/c data files are not available
# so no data pull, just making labels

rule keggcompound_labels:
    output:
        labelfile=config['download_directory'] + '/KEGG.COMPOUND/labels'
    run:
        kegg.pull_kegg_compound_labels(output.labelfile)

# UNII

rule get_unii:
    output:
        config['download_directory']+'/UNII/Latest_UNII_Names.txt',
        config['download_directory']+'/UNII/Latest_UNII_Records.txt'
    run:
        unii.pull_unii(config['download_directory'] + '/UNII')

rule unii_labels_and_synonyms:
    input:
        infile=config['download_directory']+'/UNII/Latest_UNII_Names.txt'
    output:
        labelfile=config['download_directory']+'/UNII/labels',
        synfile  =config['download_directory']+'/UNII/synonyms'
    run:
        unii.make_labels_and_synonyms(input.infile,output.labelfile,output.synfile)

# HMDB

rule get_HMDB:
    output:
        outfile=config['download_directory']+'/HMDB/hmdb_metabolites.xml'
    run:
        hmdb.pull_hmdb()

rule hmdb_labels_and_synonyms:
    input:
        infile=config['download_directory']+'/HMDB/hmdb_metabolites.xml'
    output:
        labelfile=config['download_directory']+'/HMDB/labels',
        synfile  =config['download_directory']+'/HMDB/synonyms',
        smifile  =config['download_directory']+'/HMDB/smiles'
    run:
        hmdb.make_labels_and_synonyms_and_smiles(input.infile,output.labelfile,output.synfile,output.smifile)

# PUBCHEM:

rule get_pubchem:
    output:
        config['download_directory'] +'/PUBCHEM.COMPOUND/CID-MeSH',
        config['download_directory'] +'/PUBCHEM.COMPOUND/CID-Synonym-filtered.gz',
        config['download_directory'] + '/PUBCHEM.COMPOUND/CID-Title.gz'
    run:
        pubchem.pull_pubchem()

rule get_pubchem_structures:
    output:
        config['download_directory'] + '/PUBCHEM.COMPOUND/CID-InChI-Key.gz',
        config['download_directory'] + '/PUBCHEM.COMPOUND/CID-SMILES.gz',
    run:
        pubchem.pull_pubchem_structures()

rule pubchem_labels:
    input:
        infile = config['download_directory'] + '/PUBCHEM.COMPOUND/CID-Title.gz'
    output:
        outfile = config['download_directory'] + '/PUBCHEM.COMPOUND/labels'
    run:
        pubchem.make_labels_or_synonyms(input.infile,output.outfile)


rule pubchem_synonyms:
    input:
        infile = config['download_directory'] + '/PUBCHEM.COMPOUND/CID-Synonym-filtered.gz',
    output:
        outfile  = config['download_directory'] + '/PUBCHEM.COMPOUND/synonyms'
    run:
        pubchem.make_labels_or_synonyms(input.infile,output.outfile)

# DRUGCENTRAL

rule get_drugcentralx:
    output:
        config['download_directory'] + '/DrugCentral/structures.smiles.tsv'
    run:
        drugcentral.pull_drugcentralx()

rule get_drugcentral:
    output:
        structfile = config['download_directory'] + '/DrugCentral/structures',
        labelfile = config['download_directory'] + '/DrugCentral/labels',
        xreffile = config['download_directory'] + '/DrugCentral/xrefs'
    run:
        drugcentral.pull_drugcentral(output.structfile,output.labelfile,output.xreffile)

# NCBITaxon

rule get_ncbitaxon:
    output:
        config['download_directory'] + '/NCBITaxon/taxdump.tar'
    run:
        ncbitaxon.pull_ncbitaxon()

rule ncbitaxon_labels_and_synonyms:
    input:
        infile = config['download_directory'] + '/NCBITaxon/taxdump.tar'
    output:
        lfile = config['download_directory'] + '/NCBITaxon/labels',
        sfile = config['download_directory'] + '/NCBITaxon/synonyms'
    run:
        ncbitaxon.make_labels_and_synonyms(input.infile,output.lfile,output.sfile)

# CHEBI: some comes via obo, but we need the SDF file too

rule get_chebi:
    output:
        config['download_directory'] + '/CHEBI/ChEBI_complete.sdf',
        config['download_directory'] + '/CHEBI/database_accession.tsv',
    run:
        chebi.pull_chebi()
