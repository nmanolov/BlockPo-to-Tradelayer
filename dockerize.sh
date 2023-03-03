

# build ubuntu image with lib dependencies
docker build -f Dockerfile-build -t tradelayer-build .

# build source image
docker build -f Dockerfile-source -t tradelayer-source .

docker run --rm -ti -v build:/build tradelayer-source ./autogen.sh
docker run --rm -ti -v build:/build tradelayer-source ./configure

# compile everything in shared space 
docker run --rm -ti -v build:/build --cpus=2 tradelayer-source make --jobs=4

# install litecoin in the container 
container_hash=$(docker run -d -v build:/build tradelayer-source make install)
container_status=$(docker container inspect $container_hash -f "{{ .State.Status }}")
while [ $container_status != 'exited' ]
do
  sleep 1
  container_status=$(docker container inspect $container_hash -f "{{ .State.Status }}")
done

# create an image with litecoin installed from the container
docker commit $container_hash tradelayer-installed 
docker rm $container_hash

docker build -t tradelayer .


