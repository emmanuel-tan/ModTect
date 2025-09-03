FROM continuumio/miniconda2 

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN conda install -y -c conda-forge -c bioconda samtools=1.20 && \
    conda clean -afy

CMD ["bash", "-lc", "python --version && samtools --version"]

