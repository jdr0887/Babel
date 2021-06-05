from src.prefixes import CHEMBLCOMPOUND
from src.babel_utils import pull_via_ftp, make_local_name
import ftplib
import pyoxigraph

def pull_chembl(moleculefilename):
    fname = get_latest_chembl_name()
    if not fname is None:
        # fname should be like chembl_28.0_molecule.ttl.gz
        #Pull via ftp is going to add the download_dir, so this is a hack until pull_via_ftp is nicer.
        oname = 'CHEMBL/'+moleculefilename.split('/')[-1]
        pull_via_ftp('ftp.ebi.ac.uk', '/pub/databases/chembl/ChEMBL-RDF/latest/', fname, decompress_data=True, outfilename=oname)
        pull_via_ftp('ftp.ebi.ac.uk', '/pub/databases/chembl/ChEMBL-RDF/latest/', 'cco.ttl.gz', decompress_data=True, outfilename='CHEMBL/cco.ttl')


def get_latest_chembl_name() -> str:
    # get a handle to the ftp directory
    ftp = ftplib.FTP("ftp.ebi.ac.uk")

    # login
    ftp.login()

    # move to the target directory
    ftp.cwd('/pub/databases/chembl/ChEMBL-RDF/latest')

    # get the directory listing
    files: list = ftp.nlst()

    # close the ftp connection
    ftp.quit()

    # parse the list to determine the latest version of the files
    for f in files:
        if f.endswith('_molecule.ttl.gz'):
            return f
    return None


class ChemblRDF:
    """Load the mesh rdf file for querying"""
    def __init__(self,ifname,ccofile):
        from datetime import datetime as dt
        print('loading chembl')
        start = dt.now()
        self.m= pyoxigraph.MemoryStore()
        with open(ccofile,'rb') as inf:
            self.m.load(inf,'application/turtle')
        with open(ifname,'rb') as inf:
            self.m.load(inf,'application/turtle')
        end = dt.now()
        print('loading complete')
        print(f'took {end-start}')
    def pull_labels(self,ofname):
        s="""PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
             PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
             PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
             SELECT ?molecule ?label
             WHERE {
                ?molecule a ?type .
                ?type rdfs:subClassOf* cco:Substance .
                ?molecule rdfs:label ?label .
            }
        """
        qres = self.m.query(s)
        with open(ofname, 'w', encoding='utf8') as outf:
            for row in list(qres):
                iterm = str(row['molecule'])
                ilabel = str(row['label'])
                #chemblid = iterm[:-1].split('/')[-1]
                #label = ilabel.strip().split('"')[1]
                outf.write(f'{CHEMBLCOMPOUND}:{iterm}\t{ilabel}\n')

def pull_chembl_labels(infile,ccofile,outfile):
    m = ChemblRDF(infile,ccofile)
    m.pull_labels(outfile)

