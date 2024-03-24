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

## Now lets bring it to Nautilus:
_Documentation: https://docs.nationalresearchplatform.org/userdocs/jupyter/jupyter-pod/_


Port forwarding:
`kubectl port-forward <pod> 8888:8888`
