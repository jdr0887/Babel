# Dockerfile for running the Babel build.

# We use Debian as our basic system (since that's what I'm most familiar with).
# Debian 11 should be supported until June 2026
FROM debian:11

# Install software we need to run the remaining code.
RUN apt update
RUN apt dist-upgrade
RUN apt install -y python3 python3-pip python3-venv
RUN apt install -y gcc
RUN apt install -y git
RUN pip3 install --upgrade pip

# We install some additional software while building this Docker.
# Once built, we no longer need them.
RUN apt-get install -y htop
RUN apt-get install -y screen
RUN apt-get install -y vim

# Set up a local user account for running Babel.
RUN useradd -U -m runner
USER runner
WORKDIR /home/runner/babel

# Copy directory into Docker.
COPY --chown=runner . /home/runner/babel

# We can download some source files that Babel would otherwise need to download
# later. This means that this Docker will need to be rebuilt whenever these files
# change. They can be commented out if you would like the Docker to download these
# files when it is started.
#ADD --chown=runner https://ftp.ncbi.nih.gov/gene/DATA/gene2ensembl.gz babel_downloads/NCBIGene/gene2ensembl.gz
#ADD --chown=runner https://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz babel_downloads/NCBIGene/gene_info.gz
#ADD --chown=runner https://ftp.ncbi.nih.gov/gene/DATA/gene_orthologs.gz babel_downloads/NCBIGene/gene_orthologs.gz
#ADD --chown=runner https://ftp.ncbi.nih.gov/gene/DATA/gene_refseq_uniprotkb_collab.gz babel_downloads/NCBIGene/gene_refseq_uniprotkb_collab.gz
#ADD --chown=runner https://ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen babel_downloads/NCBIGene/mim2gene_medgen
#ADD --chown=runner https://ftp.ncbi.nlm.nih.gov/pubchem/Compound/Extras/CID-SMILES.gz babel_downloads/PUBCHEM.COMPOUND/CID-SMILES.gz

# Make sure installed Python packages are on the PATH
ENV PATH="/home/runner/.local/bin:${PATH}"

# Create and activate a local Python venv
ENV VIRTUAL_ENV=/home/runner/babel/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Install requirements from the lockfile.
# RUN pip3 install -r requirements.lock
RUN pip3 install -r requirements.txt

# Our default entrypoint is to start the Babel run.
# I'm not sure what a good number of cores is, so I'm
# starting with 5 for now. 
ENTRYPOINT bash -c 'snakemake --cores 5'
