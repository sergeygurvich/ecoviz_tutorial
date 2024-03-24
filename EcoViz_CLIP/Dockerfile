FROM quay.io/jupyter/minimal-notebook:latest
LABEL authors="sergeygurvich"

# Install dependencies
RUN pip install matplotlib pandas transformers torch torchvision torchaudio

# Clone git repo
RUN git clone https://github.com/Dr-Nathan-Fox/EcoViz_CLIP

# Run JupyterLab when the container launches
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser"]

# Locally:
# docker build . -t segurvich/ecoviz_clip --platform=linux/amd64
# docker run -d -p 8888:8888 segurvich/ecoviz_clip
# docker push segurvich/ecoviz_clip

# Nautilus:
# https://docs.nationalresearchplatform.org/userdocs/jupyter/jupyter-pod/
# Port forwarding:
# kubectl port-forward <pod> 8888:8888
