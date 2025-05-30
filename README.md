# RIS-Docker-Example

## What will this documentation provide?

- An introduction to using Docker.
- An example of utilizing Docker to create images.
- Leveraging Docker images to do analysis on the RIS Compute Platform.

## What is needed?

- Access to the RIS Compute Platform.
- Knowledge of how to submit jobs on the RIS Compute Platform.
- Docker installed on your local computer or ability to utilize Docker development on compute, [documentation found here.](https://washu.atlassian.net/wiki/spaces/RUD/pages/1705115761/Docker+and+the+RIS+Compute1+Platform?atlOrigin=eyJpIjoiNTdkZGE2ZGU0MTYwNDA5NmJhNzM2ODY4OGU1ZGYzOTYiLCJwIjoiYyJ9)
- An account on Docker Hub.

## What is Docker?

- The technical definition of Docker is an open-source project that automates the deployment of software applications inside containers by providing an additional layer of abstraction and automation of OS-level virtualization on Linux.
- The simpler definition is that Docker is a tool that allows users to deploy applications within a sandbox (containers) to run on the host operating system (RIS Compute Platform).
- This method allows for all dependencies and environments to be able to remain unique to the software without interacting or interfering with other software’s environments.

## What is a container?

- A container is a virtual machine (VM), that runs software applications.
- This means that a container is virtual computer that has an operating system (OS) and whatever software users installed.
- Docker has created a syntax language for creating these virtual computers which get referred to then as Docker containers.
- You can find more information about why RIS chose Docker and containers [here.](https://washu.atlassian.net/wiki/spaces/RUD/pages/1705115761/Docker+and+the+RIS+Compute1+Platform?atlOrigin=eyJpIjoiNTdkZGE2ZGU0MTYwNDA5NmJhNzM2ODY4OGU1ZGYzOTYiLCJwIjoiYyJ9)

## Where can I find Docker?

- You can find official Docker documentation [here.](https://docs.docker.com/)
- You can find Docker containers and a place to host Docker containers [here.](https://hub.docker.com/)
- You can download Docker [here.](https://www.docker.com/products/docker-desktop)

## Creating a Docker Container

### 1. Decide The Base Container

- The first thing you’ll want to when creating a docker container, is decide what type of container you want to start with as the base.
- You can start with a base container of just an operating system, like Ubuntu, or you can start with a container that already has software installed.
- Basic OS Docker Containers (This list is not comprehensive.)
  - [Ubuntu](https://hub.docker.com/_/ubuntu)
  - [debian](https://hub.docker.com/_/debian)
  - [CentOS](https://hub.docker.com/_/centos)
  - [Alpine](https://hub.docker.com/_/alpine)
  - [Windows](https://hub.docker.com/_/microsoft-windows-base-os-images)
- Base Software Docker Containers (This list is not comprehensive.)
  - [R](https://hub.docker.com/_/r-base)
  - [Python](https://hub.docker.com/_/python)
  - [Miniconda](https://hub.docker.com/r/continuumio/miniconda3)
  - [Jupyter](https://hub.docker.com/u/jupyter)
- For our example we are going to start with the noVNC image created by RIS. [Docs here.](https://washu.atlassian.net/wiki/spaces/RUD/pages/1782055006/noVNC)
- There are multiple tags to choose from for this image, we will use the following tag: ``ubuntu22.04_cuda12.4_runtime``
- To do that we need to open up a text editor and create the base of our container.

<code>#Docker Image to Build From. Using noVNC base to do so. There are multiple tags to choose from.``
#FROM ghcr.io/washu-it-ris/novnc:ubuntu22.04
FROM ghcr.io/washu-it-ris/novnc:ubuntu22.04_cuda12.4_runtime
#FROM ghcr.io/washu-it-ris/novnc:ubuntu22.04_cuda12.4_devel</code>

### 2. Install OS Libraries and Dependencies
- The next step is to determine what OS libraries we’re going to install.
- For this example we’ll be installing ``wget``.
- To do this, we’ll have to use apt-get to install the software.
- First we’ll want to do an update using the following command.

```RUN apt-get update```

- Then we need to actually install ``wget``. In the install, since we’re installing in a Docker image, we’ll want to use some options to make it cleaner.
- The command should look like the following.

```RUN apt-get install -y --no-install-recommends wget```

- Once all of the software we want to install has been installed, we will want to run a clean to help keep our image clean and smaller.

```RUN apt-get clean```

- We can run all the apt-get commands with the same RUN command if we wish, by utilizing &&.

```
#Install OS library dependencies
RUN apt-get update && apt-get install -y --no-install-recommends wget \
    && apt-get clean</code>
```

### 3. Install Conda

- We next will need to install conda into the image. We will be using miniconda for this.
- First we need to create a directory for conda.

```RUN mkdir /opt/conda```

- Then we need to download the install.

```RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/conda/miniconda.sh```

- Finally we can run the install script.

```RUN bash /opt/conda/miniconda.sh -b -u -p /opt/conda```

- We can clean up the image a bit by removing the install script.

``RUN rm /opt/conda/miniconda.sh``

- Just like with the previous step, we can pull everything into a single RUN command.

```
#Install conda
RUN mkdir /opt/conda \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/conda/miniconda.sh \
    && bash /opt/conda/miniconda.sh -b -u -p /opt/conda \
    && rm /opt/conda/miniconda.sh</code>
```

### 4. Add conda to PATH

- We need to add the conda path to the PATH variable.

```
#Add conda to PATH
ENV PATH=/opt/conda/bin:$PATH
```

### 5. Install conda environment.

- First we need to create a conda environment file.
- In this environment, we are going to install the following:
  - matplotlib
  - pandas
  - numpy
  - scipy
  - torch
  - torchvision
  - torchaudio
- In order to do this, we create a yml file with the following.

```
name: dt-summer-corps
channels:
  - conda-forge
  - bioconda
dependencies:
  - pip
  - pip:
    - matplotlib
    - pandas
    - numpy
    - scipy
    - torch
    - torchvision
    - torchaudio
```

- Now that we have the environment file created, we need to copy it into the Docker image.

```
#Copy conda environment file into Docker
COPY environment.yml .
```

- Finally, we need to install the conda environment.

```
#Build conda environment
RUN conda env create -f environment.yml
```

### 6. Build, Test, and Upload An Image

- Once you have your Dockerfile saved within a directory (folder) designed for the image, the next step is to build the container.
- The Docker base command to build a Docker container from a Dockerfile, looks like the following.

```
docker build -t username/container-name:tag directory
```

- In our case, we’ll be using a directory named dt-summer-corps and we’ll simply call the container ``dt-summer-corps``.
- ``username`` refers to your Docker Hub username.
- So, our Docker build command should look like the following.

```
docker build -t username/dt-summer-corps:latest dt-summer-corps/
```

- If it builds successfully, you should get output of information about the building process.
- Now we can run the Docker image we’ve created.
- The base Docker run command is as follows.

```
docker run username/container-name:tag command
```

- For our example image, this will look like the following.

```
docker run username/dt-summer-corps:latest python --version
```

- Once we are certain our Docker image is functioning correctly, we can then push it to Docker Hub.
- The basic push command looks as follows.

```
docker push username/container-name:tag
```

### 7. Using a Docker Container on the Compute1 Platform

- Now that we have our docker container created and uploaded to Docker Hub, we can use it to run the software we installed on the RIS Compute Platform.
-If you are not knowledgeable on how to use the RIS Compute Platform, you can [check out our documentation](https://washu.atlassian.net/wiki/spaces/RUD/overview).
- To get the output we want on the RIS Compute Platform, we will have to use the following commands.

```
PATH=/opt/conda/bin:$PATH bsub -Is -q general-interactive -G compute-dt-summer-corp -a 'docker(username/dt-summer-corps:latest)' /bin/bash 
```

- Again, in this case the username is your Docker Hub username.
- If everything is working correctly, you should get a prompt and be able to activate the conda environment.

## Additional Notes

- If you wish to use a conda envrionment on the Compute1 platform, you need to add the following to your .bashrc.

```
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```
