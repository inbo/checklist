# extract version from DESCIPTION
version=$(grep Version DESCRIPTION | awk '{print $2}')
echo "Building version $version"
docker build --pull --no-cache --rm --tag inbobmk/checklist:version-$version .
docker build --pull --rm --tag inbobmk/checklist:version-$version .
docker build --pull --rm --progress=plain --tag inbobmk/checklist:version-$version .
docker login
docker push inbobmk/checklist:version-$version

docker run -it --rm inbobmk/checklist:version-$version
