# Safe network container

Running a local Safe network in a container.


## Usage

```txt
$ docker run --detach --name sn docker.io/bzeeman/sn_container
```

The image will run the genesis node on port 12000. Other nodes are run on port 12001 and up. It might take tens of seconds before the network is fully up and running.

To fully stop and kill the container:

```txt
$ docker rm --force sn
```

### Genesis key

The genesis node emits a genesis key that is needed to connect to the network. This information is embedded in a file and can be accessed like this:

```txt
$ docker exec -it sn cat /root/.safe/node/node_connection_info.config
```

### Logging

The full logs can be accessed by e.g.:

```
$ docker exec -it sn sh -c 'less /root/.safe/node/12000/*.log.*'
```

### Networking

Docker runs the container on the default bridge network by default. An example to get the container IP in its bridge network is the following:

```txt
$ docker exec -it sn hostname -i
172.17.0.2
```

The container can also be run on the host network by adding `--network=host` to the `docker run` command. Similarly, custom network bridges can be used, which are useful for accessing from other containers with the help of DNS.

### Command Line Interface

> :warning: The CLI is not always available if there is no up-to-date CLI that matches the node version.

If the network is up and running, one can use the built-in Safe CLI to operate on the network.

```txt
$ docker exec sn safe cat safe://non-existent
Error: ContentNotFound: Content not found at safe://non-existent
```

Or run the CLI interactively.

```txt
$ docker exec -it sn safe
Welcome to Safe CLI interactive shell!
...
```

Or log into the container shell 

```txt
$ docker exec -it sn sh
$ pwd
/home/sn

$ cat .safe/node/node_connection_info.config
[
  "127.0.0.1:12000"
]

$ safe --version
sn_cli 0.20.0
```

## Build

This project was tested with Podman, but should be working with Docker without changes. The following will build it, tagged as localhost:

```sh
docker build --tag localhost/sn_container:latest .
```
