# IBM Garage command-line tools

[![Docker Repository on Quay](https://quay.io/repository/cloudnativetoolkit/cli-tools/status "Docker Repository on Quay")](https://quay.io/repository/cloudnativetoolkit/cli-tools)

This repository builds a Docker image whose container is a client for using IBM Cloud.

The container includes the following tools:
- terraform cli
- IBM Cloud terraform provider
- kubectl cli
- git cli
- perl cli
- jq cli
- yq3 cli
- yq4 cli
- helm cli

**Warning: The material contained in this repository has not been thoroughly tested. Proceed with caution.**

## Getting started

### Prerequisites

To run this image, the following tools are required:

- `Docker` - kinda obvious, but since we are running a Docker image, you need to have the tool available

### Running the client

Start the client to use it.

- To run the `icclient` container:

    ```bash
    docker run -itd --name icclient garagecatalyst/ibm-garage-cli-tools
    ```

    This  assumes the image's default name, `ibm-garage-cli-tools`.

Once the client is running in the backgroud, use it by opening a shell in it.

- To use the `icclient` container, exec shell into it:

    ```bash
    docker exec -it icclient /bin/bash
    ```

    Your terminal is now in the container. 

Use this shell to run commands using the installed tools and scripts.

When you're finished running commands, to exit the client.

- To leave the `icclient` container shell, as with any shell:

    ```bash
    exit
    ```

    The container will keep running after you exit its shell.

If the client stops:

- To run the `icclient` container again:

    ```bash
    docker start icclient
    ```

The `icclient` container is just a Docker container, so all [Docker CLI commands](https://docs.docker.com/engine/reference/commandline/cli/) work.

### Using the client

From a client shell, run `image-help` to get a list of available tools, scripts, and ENV properties:

```bash
$ image-help
Available env properties (can be overridden for individual commands):
 > BM_API_KEY - the IBM Cloud api key
 > REGION - the IBM Cloud region (e.g. us-south)
 > RESOURCE_GROUP - the IBM Cloud resource group
 > CLUSTER_NAME - the name of the kubernetes cluster in IBM Cloud
 > SL_USERNAME - the Classic Infrastructure user name or API user name (e.g. 282165_joe@us.ibm.com)
 > SL_API_KEY - the Classic Infrastructure api key

Available tools:
 > terraform (with helm, kube, and ibm provider plugins)
 > calicoctl
 > ibmcloud (with container-service, container-registry, and cloud-databases plugins)
 > kubectl
 > kustomize
 > oc
 > helm
 > docker
 > git
 > nvm
 > node (v11.12.0 currently installed)
 > solsa
 > yo

Available scripts:
 > init.sh {BM_API_KEY} {REGION} {RESOURCE_GROUP} {CLUSTER_NAME}
 > createNamespaces.sh
 > deleteNamespace.sh
 > installHelm.sh
 > cluster-pull-secret-apply.sh
 > setup-namespace-pull-secrets.sh
 > checkPodRunning.sh
 > copy-secret-to-namespace.sh
```

## Development

### Prerequisites

To use/build this image, the following tools are required:

- `Docker` - kinda obvious, but since we are building, testing and running a Docker image, you need to have
the tool available
- `node/npm` - (optional) used to consolidate the configuration and scripts for working with the image, it
is **highly** recommended that `npm` is used; however, it is possible to run the scripts directly by looking
at `package.json` and providing the appropriate values

### Using the image

To use the image, a local image of the tool is required. You can get the image either by pulling from Docker Hub or 
building locally:

```bash
npm run pull
```

**OR**

```bash
npm run build
```

After that, start the image in an interactive terminal with:

```bash
npm start
```

### File Layout

- `package.json` - scripts and config for the image build
- `Dockerfile` - the docker image definition
- `config.yaml` - the test config file for the `container-structure-test` tool
- `scripts/` - directory for shell scripts used by `package.json` scripts to build, test, and 
push the image
- `src/` - directory containing files that should be included in the built image
