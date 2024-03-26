#!/bin/bash

# Pull the latest changes from your desired branch
git clone https://github.com/Dr-Nathan-Fox/EcoViz_CLIP
#cp -R ./jupyter-notebooks/llm/. .
#rm -rf ./jupyter-notebooks

# Execute the main process of the container (passed as CMD in Dockerfile or command in Docker Compose)
exec "$@"