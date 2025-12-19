# extract version from DESCIPTION
version=$(grep Version DESCRIPTION | awk '{print $2}')
echo "Building version $version"
docker build --pull --no-cache --tag inbobmk/checklist:version-$version .
docker build --pull --tag inbobmk/checklist:version-$version .
docker build --pull --progress=plain --tag inbobmk/checklist:version-$version .
docker login
docker push inbobmk/checklist:version-$version

docker run -it -e GITHUB_TOKEN=$GITHUB_PAT --entrypoint=/bin/bash --rm inbobmk/checklist:version-$version

docker build --pull --no-cache --tag inbobmk/checklist:devel .
docker build --pull --progress=plain --tag inbobmk/checklist:devel .
# docker push inbobmk/checklist:devel
docker run -it --rm -e GITHUB_TOKEN=$GITHUB_PAT \
  -e GITHUB_SHA=$(git rev-parse HEAD) -e GITHUB_REPOSITORY=inbo/checklist \
  -e ZENODO_SANDBOX=$ZENODO_SANDBOX --entrypoint=/bin/bash \
  inbobmk/checklist:devel

git checkout main
git pull
docker build --pull --no-cache --tag inbobmk/checklist:latest .
docker build --pull --tag inbobmk/checklist:latest .
docker push inbobmk/checklist:latest
docker run -it -e GITHUB_TOKEN=$GITHUB_PAT --entrypoint=/bin/bash --rm inbobmk/checklist:latest

docker run -it --rm -e GITHUB_TOKEN=$GITHUB_PAT \
  -e GITHUB_SHA=e31bd845b614a759139cda1007e1162df17851ea \
  -e GITHUB_REPOSITORY=inbo/mbag-mas \
  -e ZENODO_SANDBOX=$ZENODO_SANDBOX --entrypoint=/bin/bash \
  inbobmk/checklist:devel
