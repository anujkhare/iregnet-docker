# To test iregnet in an isolated environment besides Travis
FROM ubuntu:precise

MAINTAINER Anuj Khare <khareanuj18@gmail.com>

ENV BRANCH=master

# base packages
RUN apt-get update && \ 
    apt-get install -yqq git vim build-essential gcc g++ gfortran libblas-dev liblapack-dev libncurses5-dev libreadline-dev libjpeg-dev libpng-dev zlib1g-dev libbz2-dev liblzma-dev cdbs qpdf texinfo

RUN apt-get install -yqq software-properties-common

# Required for devtools
RUN apt-get -yqq build-dep libcurl4-gnutls-dev && \
    apt-get -yqq install libcurl4-gnutls-dev

RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" >> /etc/apt/sources.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
  apt-get update && \
  apt-get install -yqq r-base

# For testthat - generating pdf file
RUN apt-get install -yqq texlive-latex-full

# Downloading iregnet
RUN mkdir -p /opt/code/  && cd /opt/code/ && \
    git clone https://github.com/anujkhare/iregnet.git

# Clean up
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo 'options(repos = c(CRAN = "http://cran.rstudio.com/"))' > ~/.Rprofile
# Download devtools
RUN Rscript -e 'install.packages(c("devtools"), dependencies=TRUE, repos="http://cran.rstudio.com/")'

# checkout the required branch
RUN cd /opt/code/iregnet && \
    git pull && \
    git checkout $BRANCH

# Download dependencies
RUN cd /opt/code/iregnet && Rscript -e 'deps <- devtools::dev_package_deps(dependencies = NA); print(deps); devtools::install_deps(dependencies=TRUE); if(!all(deps$package %in% installed.packages())) { message("missing: ", paste(setdiff(deps$package, installed.packages()), collapse=", ")); q(status = 1, save = "no")}'

# Run Testthat
RUN cd /opt/code/iregnet && R CMD check .

CMD [ "/bin/bash"]
