#Docker Image to Build From. Using noVNC base to do so. There are multiple tags to choose from.
#FROM ghcr.io/washu-it-ris/novnc:ubuntu22.04
FROM ghcr.io/washu-it-ris/novnc:ubuntu22.04_cuda12.4_runtime
#FROM ghcr.io/washu-it-ris/novnc:ubuntu22.04_cuda12.4_devel

#Install OS library dependencies
RUN apt-get update && apt-get install -y --no-install-recommends wget \
    && apt-get clean

#Install conda
RUN mkdir /opt/conda \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/conda/miniconda.sh \
    && bash /opt/conda/miniconda.sh -b -u -p /opt/conda \
    && rm /opt/conda/miniconda.sh

#Add conda to PATH
ENV PATH=/opt/conda/bin:$PATH

#Copy conda environment file into Docker
COPY environment.yml .

#Build conda environment
RUN conda env create -f environment.yml
