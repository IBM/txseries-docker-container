# Supported tags and respective Dockerfile links
`latest` ([Dockerfile](https://github.com/IBM/txseries-docker-container/blob/master/Dockerfile)) - Currently supporting TXSeries V9.2 Beta

# Quick reference

* **Where to get help**\
[DeveloperWorks forum](https://www.ibm.com/developerworks/community/forums/html/forum?id=11111111-0000-0000-0000-000000001014)

* **Where to find TXSeries product related information**\
[Product Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSAL2T_9.1.0/com.ibm.cics.tx.doc/ic-homepage.html)

*  **Where to file issues**\
[GitHub Issue tracker](https://github.com/IBM/txseries-docker-container/issues)

*  **Maintained by**\
IBM

*  **Supported architectures**\
x86

*  **Helm Charts for Kubernetes based orchestration**\
[ibm-txseries-charts](https://github.com/IBM/ibm-txseries-charts)

*  **System requirements for TXSeries V9.2 Beta Docker Container**\
[GitHub docs](https://github.com/IBM/txseries-docker-container/blob/master/DOCS/92_Beta_SysReq.md)

# TXSeries for Multiplatforms - Overview

TXSeries for Multiplatforms (TXSeries) is a mixed-language application server for COBOL and C applications. TXSeries offers a reliable, scalable, and highly available platform to develop, deploy, and host, mission-critical applications. Refer to [MarketPlace](https://www.ibm.com/in-en/marketplace/txseries-for-multiplatforms) for more information.

TXSeries V9.2 open beta delivers capabilities that enable deployment of applications on Container-as-a-service platforms using Docker technology for Cloud environments. 

# Images

This image contains TXSeries V9.2 Beta Docker image under the tag `latest`. See the section **Usage** for more details.

# Usage

The TXSeries Docker image contains TXSeries image with or without the profile setup (default being profile setup enabled). With this image, you can run TXSeries regions, SFS servers, cicsteld process,etc. 

You can specify whether pre-configured region setup is required or not using environment variables. By default, the TXSeries docker image starts a single TXSeries region and SFS server.

For any of the profiled or non-profiled setup, you can verify successful installation of TXSeries using Installation Verification Program (IVP). See the section **Running the Installation Verification Program (IVP)** for more details.

**Default profile**

You can run the TXSeries docker container with default profile. Following snippet shows usage of the command for default profile configuration. 

```sh
docker run -p CICSTELD_TARGET_PORT:3270 \
           -p IPIC_LISTENER_TARGET_PORT:1435 \
           -p TXSERIES_ADMIN_CONSOLE_TARGET_PORT:9443 \
           -it -e LICENSE=accept ibmcom/txseries
```

For example,
```sh
docker run -p 3271:3270 -p 1436:1435 -p 9444:9443 \
           -it -e LICENSE=accept ibmcom/txseries
```

With the above command, the container will start the default TXSeries region *TXREGION* and SFS Server *TXSFS*. The docker image will have the following features provisioned:
*	IPIC port listening on 1436
*	cicsteld port listening on 3271
*	TXSeries CICS application program auto installation configured
*	Configured TXSeries Installation Verification Programs ( IVP )
*	TXSeries Administration Console listening on 9444 ( HTTPS ); https://*Host_IP_Address*:9444/txseries/admin
  
You can use TXSeries Administration Console to configure TXSeries region/SFS using user id *txadmin* and password *txadmin*. 

**Customizing the profile**

You can customize your profile and create TXSeries docker image in the profiled setup. Following table lists the environment variables that can be used for customization.

| Environment variable | Description |
|---|---|
| REGION_NAME | TXSeries region name; by default, TXREGION |
| SFS_NAME | SFS Server name; by default, TXSFS |
| REGION_START_TYPE | The start types of TXSeries region: cold or auto; by default, auto |
| SFS_START_TYPE | The start types of SFS server: cold or auto; by default, auto |
| TXADMIN_PASSWORD | Password of txadmin user; by default, txadmin |
| TELD_PORT | Teld port; by default, 3270 |
| LANG | Locale setting for the region, by default en_US |

Following example shows how to create a profile with custom names for TXSeries region and SFS server.
```sh
docker run -p 3271:3270 -p 1436:1435 -p 9444:9443 \
           -it -e LICENSE=accept -e REGION_NAME=MYREGION \
           -e SFS_NAME=MYSFS ibmcom/txseries
```

**Customization with additional configuration for TXSeries region and SFS**

You can run the TXSeries docker image with profiled setup and with specific region/SFS server settings. If you want to customize default profiled region/sfs server to have additional configuration, you can do so through a shell script, say *CONFIGURE.sh*. This script will need to accept TXSeries region name and SFS server name as command line arguments in that order and you can write the custom commands inside this script using the command line arguments. Following is an example snippet of *CONFIGURE.sh*.

```sh
#To install fileset.sdt in SFS server from command line argument $2
 cicssdt -s /.:/cics/sfs/$2 -i fileset.sdt
#To add an File Definition (FD) entry FILEA in region with the name $1
 cicsadd -r $1 -c fd FILEA BaseName="testfile" IndexName="testidx"
 
```

Once this script is ready, copy it to docker image /work directory. 

The below Dockerfile snippet shows an example of copying script to /work directory:

```sh
From ibmcom/txseries
COPY CONFIGURE.sh /work/setup.sh
RUN chmod +x /work/setup.sh
```

**Working with compiled CICS applications**

You can run the TXSeries docker image with profiled setup and with pre-existing compiled CICS applications. You can drop the compiled CICS applications inside drop-in folder, that is /work/autoinstall-dropin/ and the profiled TXSeries region will execute them through program auto installation feature. 

The below Dockerfile snippet shows an example of copying compiled TXSeries applications and setup.sh to drop-ins directory

```sh
From ibmcom/txseries
COPY CONFIGURE.sh /work/setup.sh
RUN chmod +x /work/setup.sh
COPY <Compiled Applications> /work/autoinstall-dropin/
```

**Setup without profile**

You can run the TXSeries docker image without profile. You can run your own region and SFS Server inside docker container by setting the environment variable PROFILED=false while running the container. 

You can do this in the following ways:
1. Run the docker run command as below:

```sh
docker run --env LICENSE=accept --env PROFILED=false \
           --publish 9443:9443 --detach ibmcom/txseries
```
The above command starts the container without creating any TXSeries region or SFS server. To create  and configure SFS and TXSeries regions, use TXSeries administration console from a web browser by using following URL

https://HOST_IP_ADDRESS:9443/txseries/admin 

2. Another option to run CICS commands to create SFS servers and CICS regions  is directly running the command from container process space. To run the commands you can use docker exec command , for example,

```sh
docker exec --tty --interactive ${CONTAINER_ID} bash
```
Using this technique, you can have full control over all aspects of the TXSeries installation and you can use CICS commands to create and configure TXSeries regions and SFS servers.

**Running the Installation Verification Program**

You can connect to TXSeries region using a 3270 terminal to run the Installation verification program (IVP). This IVP is an employee management application, using which employee details can be added, modified, browsed or deleted. This application uses SFS as file server for storing employee data in VSAM files. 

From 3270 terminal you can connect to *Host IP Address*:*CICSTELD_TARGET_PORT* and execute *MENU* transaction. Following steps provide more details on using the IVP.

* In the ENTER TRANSACTION field, type ADDS.
* In the NUMBER field, type an employee number, say 111111.
* Press Return. TXSeries displays the FILE ADD screen.
* In the FILE ADD screen, type values into the fields as required. When you have finished typing values into the fields, press Return.
* The IVP will store the user data in a VSAM file.
* To browse the newly added record type BRWS in the ENTER TRANSACTION field.
* Type the required employee number, say 111111, in the NUMBER field and press return.

With successful execution of the above IVP sample, you can confirm that the TXSeries docker image is correctly installed and configured.

# Providing Persistence

You might want to persist the transaction logs to preserve them through server restarts. This is useful in server failure and restart scenarios. To achieve persistence, you must attach the volume to the containers. Follow the below steps:

* To persist region data and sfs data, a volume should be attached to the container. Attach the volumes to /var/cics_regions, /var/cics_servers and /var/cics_clients as below:

```sh
docker run --name mycontainer -it \
                   -v region:/var/cics_regions \                                   
                   -v sfs:/var/cics_servers \
                   -v client:/var/cics_clients \
                   -p 3270:3270 -p 1435:1435 \
                   -p 9443:9443  -e LICENSE=accept \
                   ibmcom/txseries
```

* If container is started with profiled option and the container is restarted, then TXSeries region and SFS server will be auto started.

# Note

When you create your own images from ibmcom/txseries, ensure not to use ENTRYPOINT command in Dockerfile.

# License

* Dockerfile and associated scripts in this project are licensed under [Apache License 2.0](https://github.com/IBM/txseries-docker-container/blob/master/LICENSE).

* View TXSeries V9.2 Open Beta license [here](http://www14.software.ibm.com/cgi-bin/weblap/lap.pl?li_formnum=L-ACRR-AZ2DGU). Accept the license using "-e LICENSE=accept" when you run the "docker run" command. Following is an example:

`docker run -p 3270:3270 -p 1435:1435 -p 9443:9443 -it -e LICENSE=accept txseries`
