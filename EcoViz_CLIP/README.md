# CLIP: From Local to Nautilus Tutorial

## Setup:
1. Install Docker (https://docs.docker.com/engine/install/)
2. Install kubectl (https://kubernetes.io/docs/tasks/tools/)
3. Create DockerHub account (https://hub.docker.com)

## Start building docker image locally:

### 1. Build the image using Dockerfile
`docker build . -t segurvich/ecoviz_clip --platform=linux/amd64`

### 2. Test the image locally:
`docker run -d -p 8888:8888 segurvich/ecoviz_clip`

### 3. Push the image to DockerHub (need to have account)
`docker push segurvich/ecoviz_clip`

## Now lets bring everything to Nautilus:
_Documentation: https://docs.nationalresearchplatform.org/userdocs/jupyter/jupyter-pod/_

### 1. Create pod in Nautilus using EcoViz_CLIP.yaml:
`kubectl create -f  EcoViz_CLIP.yaml`

### 2. List current pods and their status:
`kubectl get pods`

### 3. Describe our pod (get info):
`kubectl describe pod sergey-clip`

### 4. Once created, we can get logs:
`kubectl logs sergey-clip`

### 5. Once created, we can go inside the pod:
`kubectl exec -it sergey-clip bash`

### 6. Setup port forwarding to access Jupyter Lab from local browser:
`kubectl port-forward sergey-clip 8888:8888`

### 7. Tear down:
`kubectl delete -f  EcoViz_CLIP.yaml`
