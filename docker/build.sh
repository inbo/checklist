# extract version from DESCIPTION
version=$(grep Version DESCRIPTION | awk '{print $2}')
echo "Building version $version"
docker build --pull --no-cache --tag inbobmk/checklist:version-$version .
docker build --pull --tag inbobmk/checklist:version-$version .
docker build --pull --progress=plain --tag inbobmk/checklist:version-$version .
docker login
docker push inbobmk/checklist:version-$version

docker run -it --entrypoint=/bin/bash --rm inbobmk/checklist:version-$version

git checkout main
git pull
docker build --pull --no-cache --tag inbobmk/checklist:latest .
docker build --pull --tag inbobmk/checklist:latest .
docker push inbobmk/checklist:latest
