FROM jupyter/r-notebook

USER root

RUN pip install tensorflow

RUN conda install --yes \
        r-essentials \
        r-reticulate \
        r-mvtnorm \ 
        r-gdata \
        r-matrixcalc \
        r-gtools \
        r-mpoly \
        r-moments \
        r-dplyr \
        r-vip \
        r-tensorflow \
        r-keras \
    && conda clean --all --yes

WORKDIR /srv

COPY RNNScript_EcoVisWorkshop.R RNNScript_EcoVisWorkshop.R
#COPY main.ipynb main.ipynb
COPY TSresponse_clean.RDS TSresponse_clean.RDS

RUN chown -R jovyan /srv/

USER jovyan