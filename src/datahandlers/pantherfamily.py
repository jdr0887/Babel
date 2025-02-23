from src.babel_utils import make_local_name, pull_via_ftp
from src.prefixes import PANTHERFAMILY

def pull_pantherfamily():
    outfile=f'{PANTHERFAMILY}/family.csv'
    pull_via_ftp('ftp.pantherdb.org','/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/','PTHR17.0_human',outfilename=outfile)

def pull_labels(infile,outfile):
    with open(infile,'r') as inf:
        data = inf.read()
    lines = data.strip().split('\n')
    SUBFAMILY_COLUMN = 3
    MAINFAMILY_NAME_COLUMN = 4
    SUBFAMILY_NAME_COLUMN = 5
    panther_families=[]
    labels = {}
    done = set()
    with open(outfile,'w') as labelf:
        for line in lines[1:]:
            parts = line.split('\t')
            if len(parts) < 5:
                continue
            sf = parts[SUBFAMILY_COLUMN]
            mf = sf.split(':')[0]
            mfname = parts[MAINFAMILY_NAME_COLUMN]
            sfname = parts[SUBFAMILY_NAME_COLUMN]
            if mf not in done:
                main_family = f'{PANTHERFAMILY}:{mf}'
                #panther_families.append(main_family)
                #labels[main_family]=mfname
                labelf.write(f'{main_family}\t{mfname}\n')
                done.add(mf)
            if sf not in done:
                sub_family = f'{PANTHERFAMILY}:{sf}'
                #panther_families.append(sub_family)
                #labels[sub_family]=sfname
                labelf.write(f'{sub_family}\t{sfname}\n')
                done.add(sf)
