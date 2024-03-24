FROM quay.io/jupyter/minimal-notebook:latest
LABEL authors="sergeygurvich"

# Install dependencies
RUN pip install matplotlib pandas transformers torch torchvision torchaudio

# Clone git repo
RUN git clone https://github.com/Dr-Nathan-Fox/EcoViz_CLIP

# Run JupyterLab when the container launches
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser"]

# Locally:
# docker build . -t segurvich/ecoviz_clip:minimal --platform=linux/amd64
# docker run -d -p 8888:8888 segurvich/ecoviz_clip:minimal
# docker push segurvich/ecoviz_clip:minimal

# Nautilus:
# https://docs.nationalresearchplatform.org/userdocs/jupyter/jupyter-pod/
# Apply:
# kubectl create -f  EcoViz_CLIP.yaml
# kubectl get pods
# kubectl exec -it sergey-clip bash
# kubectl logs sergey-clip

# Port forwarding:
# kubectl port-forward sergey-clip 8888:8888

# kubectl delete -f  EcoViz_CLIP.yaml
