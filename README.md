# Safe network container

Running a local Safe network in a container.


## Usage

```txt
$ docker run --detach --network=host --name sn docker.io/bzeeman/sn_container
```

The image will run the genesis node on port 12000. Other nodes are run on port 12001 and up. After launching the nodes, the authenticator is started and the `safe` CLI tool is automatically authorised and ready to be used. This might tens of seconds before the network is fully up and running.

If the network is up and running, one can use the built-in Safe CLI to operate on the network.

```txt
$ podman exec sn safe cat safe://non-existent
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
docker build --file Containerfile --tag localhost/sn_container:latest
```
