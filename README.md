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

``RUN apt-get update``

- Then we need to actually install ``wget``. In the install, since we’re installing in a Docker image, we’ll want to use some options to make it cleaner.
- The command should look like the following.

``RUN apt-get install -y --no-install-recommends wget``

- Once all of the software we want to install has been installed, we will want to run a clean to help keep our image clean and smaller.

``RUN apt-get clean``

- We can run all the apt-get commands with the same RUN command if we wish, by utilizing &&.

<code>#Install OS library dependencies
RUN apt-get update && apt-get install -y --no-install-recommends wget \
    && apt-get clean</code>

### 3. Install Conda

- We next will need to install conda into the image. We will be using miniconda for this.
- First we need to create a directory for conda.

``RUN mkdir /opt/conda``

- Then we need to download the install.

``RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/conda/miniconda.sh``

- Finally we can run the install script.

``RUN bash /opt/conda/miniconda.sh -b -u -p /opt/conda``

- We can clean up the image a bit by removing the install script.

``RUN rm /opt/conda/miniconda.sh``

- Just like with the previous step, we can pull everything into a single RUN command.

<code>#Install conda
RUN mkdir /opt/conda \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/conda/miniconda.sh \
    && bash /opt/conda/miniconda.sh -b -u -p /opt/conda \
    && rm /opt/conda/miniconda.sh</code>

### 4. Install conda environment.

- First we need to create a conda environment file.



### 5. Build, Test, and Upload An Image
Once you have your Dockerfile saved within a directory (folder) designed for the image, the next step is to build the container.

The Docker base command to build a Docker container from a Dockerfile, looks like the following.



docker build -t username/container-name:tag directory
In our case, we’ll be using a directory named docker-example and we’ll simply call the container docker-example.

username refers to your Docker Hub username.

So, our Docker build command should look like the following.



docker build -t username/docker-example:latest docker-example/
If it builds successfully, you should get output of information about the building process, but at the end you’ll see the following.

image-20250408-143558.png
Now we can run the Docker image we’ve created.

The base Docker run command is as follows.



docker run username/container-name:tag command
For our example image, this will look like the following.



docker run username/docker-example:latest cowsay "Hello World!"
Your output should look like the following.

image-20250408-143701.png
Once we are certain our Docker image is functioning correctly, we can then push it to Docker Hub.

The basic push command looks as follows.



docker push username/container-name:tag
You should see output like the following for the push.

image-20250408-143742.png
4. Expanding An Image
While it’s fun to tell our cow what to say, what if we had it say randomly generated fortunes?

We can do this by also installing the fortune library into our docker container.

Luckily, once our base image has been designed this requires changing only 1 line in our Dockerfile.

We will add fortune and fortunes to our apt-get install command, like the following.



&& apt-get install -y --no-install-recommends cowsay fortune fortunes \
Once that is changed, we can save the Dockerfile and rebuild the image.

Now we can pipe fortune into cowsay and create our fortune telling cow.

Unfortunately when running Docker, to be able to use the pipe command we need to add /bin/bash -c to our command.

So our new Docker run command should look like the following.



docker run username/docker-example:latest /bin/bash -c "fortune | cowsay"
If everything is working correctly, we should get output like the following.

image-20250408-143948.png
You can re-upload your image to Docker Hub so that you have the newest image available for the next part.

Your complete Dockerfile should now look like the following.



#Start from bionic base Ubuntu image.
FROM ubuntu:bionic
#Install cowsay
RUN apt-get update \
&& apt-get install -y --no-install-recommends cowsay fortune fortunes \
&& apt-get clean
#Add cowsay to the PATH variable
ENV PATH="$PATH:/usr/games"
RUN export PATH
Using a Docker Container on the Compute1 Platform
Now that we have our docker container created and uploaded to Docker Hub, we can use it to run the software we installed on the RIS Compute Platform.

If you are not knowledgeable on how to use the RIS Compute Platform, you can go over the following documentation. 
Compute1 Quickstart 

To get the output we want on the RIS Compute Platform, we will have to use the following commands.



export LSF_DOCKER_PRESERVE_ENVIRONMENT=false
bsub -Is -q workshop-interactive -G compute-workshop -a 'docker(username/docker-example:latest)' /bin/bash -c "fortune | cowsay"
We need to use the LSF_DOCKER_PRESERVE_ENVIRONMENT variable because we had to set environment variables within our container and we want to use those instead of preserving those on the Compute Platform.

Again, in this case the username is your Docker Hub username.

If everything is working correctly, you should see results like the following.

image-20250408-144302.png
cowsay has a fun little additional aspect. If a fortune telling cow isn’t fantastic enough, we can always use a dragon.

If you add the -f dragon option to the cowsay command, you can turn your cow into a dragon.



export LSF_DOCKER_PRESERVE_ENVIRONMENT=false
bsub -Is -q workshop-interactive -G compute-workshop -a 'docker(username/docker-example:latest)' /bin/bash -c "fortune | cowsay -f dragon"
image-20250408-144519.png
Advanced Container Addition
As an advanced step, we can add another library that will add color to our cows and dragons.

lolcat adds rainbow coloring to the display.

Once we add it to our container, update, and upload to Docker Hub, we can add the color via lolcat with the following command.

There are no hints for this step as it is advanced and designed for the user to figure out.



export LSF_DOCKER_PRESERVE_ENVIRONMENT=false
bsub -Is -q workshop-interactive -G compute-workshop -a 'docker(username/docker-example:latest)' /bin/bash -c "fortune | cowsay | lolcat"
image-20250408-144650.png
Example of Using the Compute Platform for Development
As mentioned before you can develop a Docker image on the Compute Platform.

The first thing you’ll need to do is let Docker Hub know your credentials by using the following command.



LSB_DOCKER_LOGIN_ONLY=1 bsub -G compute-workshop -q workshop-interactive -Is -a 'docker_build' -- .
This command only needs to be done once and will ask for your Docker Hub credentials (you’ll need an Docker Hub account prior to this step).

The login credentials you’ll need to use are those for Docker Hub NOT your WashU credentials.

image-20250408-144801.png
Once you have this set, you can start development of your Docker image.

If you wish to use the Compute Platform to develop images or other software, we suggest checking out our documentation on doing so (Coming Soon!).

For this simple example, we’ll use the vi text editor that’s available on the Compute Platform.

You need to create a directory called docker-example and then cd into that directory.

Once in the docker-example directory, you will need to create your Dockerfile via the following command



vi Dockerfile
Once in the editor you will need to press the I key to be able to edit the file. Now you just need to put in the information in the Dockerfile like developed above.

Once you’ve entered the info, then you press the escape key to disengage edit mode.

Then you need to press the : key and type wq and hit the Enter key. This will write your changes and quit the editor.

Now you can use the cat command on your file to make sure it contains the correct information.

image-20250408-145023.png
In order to build and push our Docker image, we need to cd back out of docker-example directory.

image-20250408-145047.png
Then we need to use the following command to build and push our Docker image.



bsub -G compute-workshop -q workshop-interactive -Is -a 'docker_build(username/docker-example)' -- latest docker-example
Where username is your Docker Hub username.

Once this is entered you will see the normal Docker building information. 

image-20250408-145136.png
image-20250408-145147.png
Now that the container is built and pushed, we can use the container like we need above in order to have our fortune telling cow.



export LSF_DOCKER_PRESERVE_ENVIRONMENT=false
bsub -Is -q workshop-interactive -G compute-workshop -a 'docker(username/docker-example:latest)' /bin/bash -c "fortune | cowsay"
image-20250408-145229.png
