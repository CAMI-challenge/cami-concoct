# Docker for CONCOCT (http://github.com/BinPro/CONCOCT) v0.4.1
# VERSION 0.4.1
# 
# This docker creates and sets up an Ubuntu environment with all
# dependencies for CONCOCT v0.4.1 installed.
#
# To login to the docker with a shared directory from the host do:
#
# sudo docker run -v /my/host/shared/directory:/my/docker/location -i -t binnisb/concoct_0.4.1 /bin/bash
#

FROM cami/binning:latest
MAINTAINER CONCOCT developer group, concoct-support@lists.sourceforge.net

# Proxy settings. Comment out if not needed

#ENV MY_PROXY http://rzproxy.helmholtz-hzi.de:3128
#RUN echo 'Acquire::http::Proxy "'$MY_PROXY'";\nAcquire::ftp::Proxy "'$MY_PROXY'";\n' > /etc/apt/apt.conf.d/proxy

#ENV http_proxy $MY_PROXY
#ENV https_proxy $MY_PROXY
#ENV ftp_proxy $MY_PROXY
#ENV HTTP_PROXY $MY_PROXY
#ENV HTTPS_PROXY $MY_PROXY
#ENV FTP_PROXY $MY_PROXY

#---------------------------------------------------------------------------------------------------------------


ENV PATH /opt/miniconda/bin:$PATH
ENV PATH /opt/velvet_1.2.10:$PATH

# apt-get
RUN apt-get -qq update && apt-get install -qq -y --fix-missing -o DPkg::Options::=--force-confnew \
apt-utils wget build-essential libgsl0-dev git zip unzip

# Get basic ubuntu packages needed
#RUN apt-get update -qq
#RUN apt-get install -qq apt-utils
#RUN apt-get install -qq wget build-essential libgsl0-dev git zip unzip

# Set up Miniconda environment for python2
RUN wget http://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O /opt/miniconda.sh; chmod +x /opt/miniconda.sh;
RUN /opt/miniconda.sh -p /opt/miniconda -b;
RUN /opt/miniconda/bin/conda update --yes conda
RUN /opt/miniconda/bin/conda install --yes python=2.7

# Velvet for assembly
RUN apt-get install -qq zlib1g-dev
RUN cd /opt;\
    wget www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz -O velvet.tgz;\
    tar xf velvet.tgz;\
    cd velvet_1.2.10;\
    sed -i "s/MAXKMERLENGTH=31/MAXKMERLENGTH=128/" Makefile ;\
    make

RUN apt-get -qq update && apt-get install -qq -y --fix-missing -o DPkg::Options::=--force-confnew \
bedtools \
libfuse2 openjdk-7-jre-headless udev \
samtools \
bowtie2 \
parallel \
r-base git

#RUN apt-get -qq install python



# Bedtools2.17
#RUN apt-get install -qq bedtools

# Picard tools 1.118
# To get fuse to work, I need the following (Issue here: https://github.com/dotcloud/docker/issues/514,
# solution here: https://gist.github.com/henrik-muehe/6155333).
ENV MRKDUP /opt/picard-tools-1.118/MarkDuplicates.jar
#RUN apt-get install -qq libfuse2 openjdk-7-jre-headless udev
RUN cd /tmp && apt-get download fuse && ls -a \
&& dpkg-deb -x fuse_* .\
&& dpkg-deb -e fuse_*\
&& rm fuse_*.deb\
&& echo '#!/bin/bash\nexit 0\n' > DEBIAN/postinst\
&& dpkg-deb -b . /fuse.deb\
&& dpkg -i /fuse.deb\
&& cd /opt\
&& wget "http://downloads.sourceforge.net/project/picard/picard-tools/1.118/picard-tools-1.118.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fpicard%2Ffiles%2Fpicard-tools%2F1.118%2F&ts=1396879817&use_mirror=freefr" -O picard-tools-1.118.zip\
    && unzip picard-tools-1.118.zip

# Samtools 0.1.19
#RUN apt-get install -qq samtools

# Bowtie2.1.0
#RUN apt-get install -qq bowtie2

# Parallel 20130622-1
#RUN apt-get install -qq parallel



# Install prodigal 2.60
RUN cd /opt;\
    wget --no-check-certificate https://prodigal.googlecode.com/files/Prodigal-2.60.tar.gz;\
    tar xf Prodigal-2.60.tar.gz;\
    cd Prodigal-2.60;\
    make;\
    ln -s /opt/Prodigal-2.60/prodigal /bin/prodigal

# Install R
#RUN apt-get install -qq r-base git

# Install R packages
RUN cd /opt;\
    RREPO='"http://cran.rstudio.com/"';\
    printf "install.packages(\"ggplot2\", repo=$RREPO)\ninstall.packages(\"reshape\",repo=$RREPO)\ninstall.packages(\"gplots\",repo=$RREPO)\ninstall.packages(\"ellipse\",repo=$RREPO)\ninstall.packages(\"grid\",repo=$RREPO)\ninstall.packages(\"getopt\",repo=$RREPO)" > dep.R;\
    Rscript dep.R

# Install python dependencies and fetch and install CONCOCT 0.4.1 
RUN cd /opt\
    && conda update --yes conda\
    && conda install --yes python=2.7 atlas cython numpy scipy biopython pandas pip scikit-learn pysam\
    && pip install bcbio-gff\
    && pip install biopython\
    && git clone https://github.com/BinPro/CONCOCT \
    && cd CONCOCT\
    && python setup.py install

# && wget --no-check-certificate https://github.com/BinPro/CONCOCT/archive/0.4.1.tar.gz\
# && tar xf 0.4.1.tar.gz\

ENV CONCOCT /opt/CONCOCT
ENV CONCOCT_TEST /opt/Data/CONCOCT-test-data
ENV CONCOCT_EXAMPLE /opt/Data/CONCOCT-complete-example

#------------------------------------------------------------------------------------------------------------

COPY tasks $DCKR_TASKDIR
COPY scripts /scripts/
