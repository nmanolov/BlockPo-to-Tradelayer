startingStage=$1

[ -z $startingStage ] && startingStage=build

case "$startingStage" in
    "build-dependency")
      echo "build ubuntu image with lib dependencies"
      docker build -f Dockerfile-build -t tradelayer-build .
      ;;
esac
case "$startingStage" in
     "build-dependency" | "build-source")
        echo "build source image"
        docker build -f Dockerfile-source -t tradelayer-source .
        ;;
esac
case "$startingStage" in
    "build-dependency" | "build-source" | "configure")
        docker run --rm -ti -v build:/build tradelayer-source ./autogen.sh
        docker run --rm -ti -v build:/build tradelayer-source ./configure
        ;;
esac
case "$startingStage" in
    "build-dependency" | "build-source" | "configure" | "make")
        echo "compile everything in shared space"
        docker run --rm -ti -v build:/build --cpus=2 tradelayer-source make --jobs=4
        ;;
esac
case "$startingStage" in
    "build-dependency" | "build-source" | "configure" | "make" | "install")
        echo "running make install in a container "
        container_hash=$(docker run -d -v build:/build tradelayer-source make install)
        echo $container_hash
        container_status=$(docker container inspect $container_hash -f "{{ .State.Status }}")
        while [ $container_status != 'exited' ]
        do
          sleep 1
          container_status=$(docker container inspect $container_hash -f "{{ .State.Status }}")
          echo "container ${container_hash:0:8} is $container_status"
        done
        echo "create an image with litecoin installed from the container"
        docker commit $container_hash tradelayer-installed 
        docker rm $container_hash
        ;;
esac
case "$startingStage" in
    "build-dependency" | "build-source" | "configure" | "make" | "install" | "build")
        echo "building an image with litecoind installed"
        docker build -t tradelayer .
        ;;
esac















