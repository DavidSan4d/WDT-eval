# 30,000-Foot View

This project serves as an example implementation for deploying a WebLogic application to ephemeral virtual machines (WLVMs).
This infrastructure is a part of the larger Autobahn/Condor Enterprise initiative, specifically targeting dev/test optimization via automatic environment provisioning.

## Dependencies

All applications deploying to WLVMs must satisfy the following dependencies:

* Java 8
* WebLogic 12.2.1.4
* GitLab
* Jenkins Core
* Terraform

## Automate

Even before integration, one should automate, automate, automate.
Integration will be dependent on:

* Automatically building application archives (jar/war/ear)
* Automatically packaging application and dependencies with domain creation, deployment, and control scripts
* Automatically deploying domain with application, dependencies, and control scripts
* Automatically controlling (start/stop/kill) domain admin/managed servers
* Automatically cleaning existing deployment to support redeployment without reprovisioning

The infrastructure doesn't dictate ***how*** you should achieve this.
For example, application teams traditionally use custom WLST scripts to create the domain.
Instead, it embraces any existing automation by allowing teams to implement a wrapper script for each phase.

### Build

As previously stated, the infrastructure does not dictate which build tool to use.
By default, the Jenkins build VM supports (***and recommends***) Maven and Gradle.
However, it can support other build tools such as Ant, as long as the project includes the tool with all dependencies in the source.
In fact, this project does exactly that.

> **Note**
>
> The Docker build VM image is located [here](https://gitlab.prod.fedex.com/APP3535985/dockerized-builds/-/tree/master/wls-12.2.1.4).

### Package

Packaging will be largely dependent on your target environment and deployment tool of choice.
Based on the environment targeted for deployment (such as L1 for example), it is the responsibility of the application team to bundle everything appropriately.

### Deploy

It is ***recommended*** teams adopt WebLogic Deploy Tooling (WDT) versus WLST, as it lets you write a declarative metadata model to describe your deployment versus scripting.
Similar to Ant, the project will need to include the tool in the source and package it appropriately.
See section [below](#weblogic-deploy-tooling-wdt) for more information.

### Control

Custom support to start, stop, and kill admin/managed servers is provided.

### Clean

Custom support to clean an existing deployment is provided.

## Project Structure

Only the following directories and files are considered mandatory:

| Name | Description |
| ----- | ----- |
| `tf/` | Terraform configuration file directory to provision target ephemeral WebLogic VMs |
| `tf/main.tf` | Main configuration file |
| `tf/variables.tf` | Variable definition file |
| `tf/L<#>.tfvars` | Target environment specific (traditionally L1&vert;L2&vert;L3&vert;...) configuration file |
| `wlvm/` | Custom wrapper script directory for existing automation |
| `wlvm/build.sh` | Script to build application archives (jar/war/ear) |
| `wlvm/package.sh` | Script to package application archives and dependencies with domain creation, deployment, and control scripts |
| `wlvm/env.sh` | Script sourced on target VMs |
| `wlvm/create.sh` | Script to create domain as well as install application with dependencies and control scripts on target VMs |
| `wlvm/start.sh` | Script to start admin (first target VM only) and all managed servers on target VMs |
| `wlvm/stop.sh` | Script to stop all admin and managed servers on target VMs |
| `wlvm/kill.sh` | Script to kill all admin and managed servers on target VMs |
| `wlvm/clean.sh` | Script to remove all domains, dependencies, and control scripts on target VMs |
| `Jenkinsfile` | Jenkins pipeline |

The actual location of the application source will be dependent on your project build tool.
For example, Maven and Gradle are very opinionated and enforce a common directory layout, whereas Ant (as used by this project) is far less opinionated.
This project adopted the following additional structure:

| Name | Description |
| ----- | ----- |
| `source/` | Application source and dependencies directory |
| `build/` | Application build script directory (includes build tool itself) |
| `domain/` | WebLogic domain creation, deployment and control script directory (supports both WDT and WLST) |

### Jenkins Pipeline

The Jenkins pipeline defines the following stages.
Many of the stages optionally invoke a custom wrapper script from the `wlvm/` source directory, primarily to support existing automation.

| Stage | Wrapper | Description |
| ----- | ----- | ----- |
| Environment | - | Displays value of each environment variable available to the pipeline |
| Provision | - | Provisions ephemeral VMs via Terraform configuration in the
`/tf` source directory |
| Build | `build.sh` | Builds application archives |
| Package | `package.sh` | Packages application archives and dependencies with domain creation, deployment, and control scripts |
| Load | - | Bundles package and stages in temporary location on each target VM via SSH agent |
| Deploy | `env.sh`, `create.sh` | On each target VM, this creates domain and installs application, dependencies, and control scripts |
| Start | `env.sh`, `start.sh` | On each target VM, this starts all admin and managed servers |
| Stop | `env.sh`, `stop.sh` | On each target VM, this stops all admin and managed servers |
| Restart | - | On each target VM, this stops (if required) then starts all admin and managed servers |
| Kill | `env.sh`, `kill.sh` | On each target VM, this kills all admin and managed servers |
| Clean | `env.sh`, `clean.sh` | On each target VM, this removes all domains, dependencies and control scripts |
| Deprovision | - | Deprovisions ephemeral VMs and makes them available for provisioning |

> **Note**
>
> This pipeline will eventually be refactored into a reference pipeline for WebLogic ephemeral VM deployments!

### Actions

One or more stages are invoked by each action as follows:

| Action | Environment | Provision | Build | Package | Load | Deploy | Start | Restart | Stop | Kill | Clean | Deprovision |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| Provision | **Yes** | **Yes** | - | - | - | - | - | - | - | - | - | - |
| Deploy | **Yes** | - | **Yes** | **Yes** | **Yes** | **Yes** | **Yes** | - | - | - | - | - |
| Start | **Yes** | - | - | - | - | - | **Yes** | - | - | - | - | - |
| Stop | **Yes** | - | - | - | - | - | - | - | **Yes** | - | - | - |
| Restart | **Yes** | - | - | - | - | - | - | **Yes** | - | - | - | - |
| Kill | **Yes** | - | - | - | - | - | - | - | - | **Yes** | - | - |
| Undeploy | **Yes** | - | - | - | - | - | - | - | **Yes** | **Yes** | **Yes** | - |
| Deprovision | **Yes** | - | - | - | - | - | - | - | - | - | - | **Yes** |

> **Note**
>
> The pipeline can be built with parameters via the Jenkins Core [user interface](https://jenkins.clw1.prod.fedex.com/iaasascode/job/app-3536567/job/wlvm-audit/).

### Environment

This is not an exhaustive list, but some common environment variables are:

#### General

| Name | Description | Example |
| ----- | ----- | ----- |
| `EAI_NUMBER` | Application EAI number | 3536567 |
| `EAI_NAME` | Application EAI name | IaaSAsCode |
| `GIT_BRANCH` | Git project source branch | `${env.BRANCH_NAME}` |

#### Build VM

| Name | Description | Example |
| ----- | ----- | ----- |
| `WLVM_ROOT` | Source root directory | `${WORKSPACE}` |
| `WLVM_HOME` | Custom wrapper scripts home directory | `${WLVM_ROOT}/wlvm` |
| `WLVM_PACKAGE` | Temporary packaging directory | `${WLVM_HOME}/package` |

#### Terraform

| Name | Example |
| ----- | ----- |
| `OKTA_CREDS` | `credentials('okta_3536567_devtest')` |
| `MF_BROKER` | mf-broker-prod.app.wtcbo4.paas.fedex.com |
| `ISSUER` | https://purpleid-stage.oktapreview.com/oauth2/auss1ynuf4k5qzlNA0h7/v1/token?grant_type=client_credentials&response_type=token |
| `S3_CREDS` | `credentials('s3_3536567_devtest')` |
| `S3_ENDPOINT` | https://swift-bo.swift.ute.fedex.com |

> **Note**
>
> Refer to Terraform and Jenkins cookbook recipe for more information!

#### Target VM

| Name | Description | Example |
| ----- | ----- | ----- |
| `WLVM_TARGET` | Target environment | L1 |
| `WLVM_TARGET_SERVERS` | Target server names | c0032643.test.cloud.fedex.com,c0032644.test.cloud.fedex.com |
| `WLVM_TARGET_JRE` | Java home directory | `/opt/java/hotspot/8/latest` |
| `WLVM_TARGET_ORACLE` | WebLogic parent directory | `/opt/weblogic/wl12214_210119` |
| `WLVM_TARGET_WLS` | WebLogic server directory | `${WLVM_TARGET_ORACLE}/wlserver` |
| `WLVM_TARGET_OPT` | Main application directory (domain, application archives, dependencies and control scripts) | `/opt/fedex/iaasascode/wlvm` |
| `WLVM_TARGET_VAR` | Application variable data directory (logs) | `/var/fedex/iaasascode/wlvm` |
| `WLVM_TARGET_TMP` | Temporary working directory | `/tmp/wlvm` |
| `WLVM_SSH_AGENT` | SSH Agent IDentifier | WLVM-POC |
| `WLVM_SSH_USER` | SSH Agent username | mc474768 |
| `WLVM_SSH_OPTIONS` | ssh/scp command line options | `-oStrictHostKeyChecking=no -oBatchMode=yes -oLogLevel=error -oUserKnownHostsFile=/dev/null` |

> **Note**
>
> There is an effort to parameterize and/or automate some of these environment variables.
> In the interim, one will need to explicitly set some values, particularly after the VMs are provisioned.

#### Domain

| Name | Description | Example |
| ----- | ----- | ----- |
| `WLVM_DOMAIN_USERNAME` | Domain username | weblogic |
| `WLVM_DOMAIN_PASSWORD` | Domain password | WebLog1c |
| `WLVM_DOMAIN_PARENT` | Domain parent directory | `${WLVM_TARGET_OPT}/domain` |
| `WLVM_DOMAIN_NAME` | Domain name | L1CisDomain |
| `WLVM_DOMAIN_HOME` | Domain home directory |
`${WLVM_DOMAIN_PARENT}/${WLVM_DOMAIN_NAME}` | | `WLVM_DOMAIN_PRODUCTION` | Production mode enabled | false |
| `WLVM_DOMAIN_TARGET` | Domain resource/application target | CisCluster |

#### Admin/Managed Server

| Name | Description | Example |
| ----- | ----- | ----- |
| `WLVM_SERVER_ADMIN_NAME` | Admin server name | CisAdminServer |
| `WLVM_SERVER_ADMIN_PORT` | Admin server port | 7001 |
| `WLVM_SERVER_MANAGED_PREFIX` | Managed server name prefix | CisManagedServer |
| `WLVM_SERVER_MANAGED_PORT` | Managed server port | 8001 |
| `WLVM_SERVER_APPD` | Start AppDynamics agent | `false` |

#### Control

| Name | Description | Example |
| ----- | ----- | ----- |
| `WLVM_CONTROL_KILL` | How many seconds to wait for server to stop gracefully | 30 |

## WebLogic Deploy Tooling (WDT)

Official [documentation](https://github.com/oracle/weblogic-deploy-tooling).

WDT makes it easy to stand up WebLogic environments and perform domain lifecycle operations in a repeatable fashion based on a metadata model.
This model can be treated as source and evolve as the project evolves.

The high-level steps are:

1. Setup tool
2. Discover configuration from existing domain deployment and create model
3. Encrypt sensitive properties
4. Create domain from model

### Setup

Official [documentation](https://github.com/oracle/weblogic-deploy-tooling#downloading-and-installing-the-software).

```
$ ssh <user>@<server>
$ cd /tmp
$ export http_proxy=http://internet.proxy.fedex.com:3128
$ export https_proxy=${http_proxy}
$ wget https://github.com/oracle/weblogic-deploy-tooling/releases/download/release-1.9.8/weblogic-deploy.zip
$ unzip weblogic-deploy.zip
$ rm weblogic-deploy.zip
$ export JAVA_HOME=/opt/java/hotspot/8/64_bit/jdk1.8.0_261
$ export ORACLE_HOME=/opt/weblogic/wl12214_201020
$ export PATH=${PATH}:/tmp/weblogic-deploy/bin
```

### Discover Domain Tool

Official [documentation](https://oracle.github.io/weblogic-deploy-tooling/userguide/tools/discover/).

The Discover Domain Tool (`discoverDomain`) introspects an existing domain and creates both a model file describing the domain and an archive file of the binaries deployed to the domain.

```
$ mkdir -p /tmp/domain
$ cd /tmp/domain
$ discoverDomain.sh -domain_home /opt/fedex/<app>/domains/Domain -archive_file Domain.zip -model_file Domain.yaml -variable_file Domain.properties
$ ls -l
-rw-r--r-- 1 mc474768 fxusers     8295 Jan 12 22:44 Domain.properties
-rw-r--r-- 1 mc474768 fxusers    42579 Jan 12 22:44 Domain.yaml
-rw-r--r-- 1 mc474768 fxusers 80023650 Jan 12 22:44 Domain.zip
```

* The properties file contains user values and placeholders for passwords that are required to be explicitly populated then encrypted
* The YAML file is the model for domainInfo, topology, resources and appDeployments
* The zip file contains all archives (jar/war/ear) to deploy

### Encrypt Model Tool

Official [documentation](https://oracle.github.io/weblogic-deploy-tooling/userguide/tools/encrypt/).

The Encrypt Model Tool (`encryptModel`) encrypts the passwords in a model (or its variable file) using a user-provided passphrase.

1. Explicitly populate passwords in Domain.properties file appropriately.
2. Encrypt passwords using encryption passphrase *mysupersecret*

```
$ encryptModel.sh -model_file Domain.yaml -variable_file Domain.properties
JDK version is 1.8.0_261-b12
JAVA_HOME = /opt/java/hotspot/8/64_bit/jdk1.8.0_261
CLASSPATH = /tmp/weblogic-deploy/lib/weblogic-deploy-core.jar:/opt/weblogic/wl1213_201020/wlserver/server/lib/weblogic.jar
JAVA_PROPERTIES = -Djava.util.logging.config.class=oracle.weblogic.deploy.logging.WLSDeployCustomizeLoggingConfig -Dpython.cachedir.skip=true -Dpython.path=/opt/weblogic/wl1213_201020/wlserver/common/wlst/modules/jython-modules.jar/Lib -Dpython.console=
/opt/java/hotspot/8/64_bit/jdk1.8.0_261/bin/java -cp /tmp/weblogic-deploy/lib/weblogic-deploy-core.jar:/opt/weblogic/wl1213_201020/wlserver/server/lib/weblogic.jar -Djava.util.logging.config.class=oracle.weblogic.deploy.logging.WLSDeployCustomizeLoggingConfig -Dpython.cachedir.skip=true -Dpython.path=/opt/weblogic/wl1213_201020/wlserver/common/wlst/modules/jython-modules.jar/Lib -Dpython.console= org.python.util.jython /tmp/weblogic-deploy/lib/python/encrypt.py -oracle_home /opt/weblogic/wl1213_201020 -model_file CisDomain.yaml -variable_file CisDomain.properties
####<Jan 12, 2021 11:13:51 PM> <INFO> <WebLogicDeployToolingVersion> <logVersionInfo> <WLSDPLY-01750> <The WebLogic Deploy Tooling encryptModel version is 1.9.8:master.10cd854:Dec 16, 2020 20:11 UTC>
Enter the encryption passphrase to use: mysupersecret
Re-enter the encryption passphrase to use: mysupersecret
####<Jan 12, 2021 11:15:42 PM> <INFO> <encrypt> <__encrypt_model_and_variables> <WLSDPLY-04209> <encryptModel encrypted 3 variables and wrote them to file Domain.properties>

encryptModel.sh completed successfully (exit code = 0)
```

**Before**

```
AdminUserName=weblogic
AdminPassword=WebLog1c
```

**After**

```
AdminUserName=weblogic
AdminPassword={AES}aG1TbklqOUNyVjliTXpkNXFwTzR1QWxyT21YaFl6dE46RWtZQXNjUnNBTWdYdlV4ejpZUDhFc08wOUV2TT0=
```

> **Note**
>
> The model YAML and properties can now be stored in the source repository.
> The archive will be built from source.

### Create Domain Tool

Official [documentation](https://oracle.github.io/weblogic-deploy-tooling/userguide/tools/create/).

The Create Domain Tool (`createDomain`) understands how to create a domain and populate the domain with all resources and applications specified in the model.

```
$ mkdir -p /opt/fedex/<app>/domains
$ createDomain.sh -use_encryption -domain_type WLS -domain_parent /opt/fedex/<app>/domains -model_file Domain.yaml -archive_file Domain.zip -variable_file Domain.properties
```

> **Note**
>
> The tool will prompt for the encryption passphrase.
> The password can be piped from STDIN to avoid the prompt.

**Domain Home**

The domain name from the model will be appended to the location of the domain parent directory to become the domain home.
Using the example above with the following model:

```
topology:
    Name: Domain
```

The domain home becomes:

`/opt/fedex/<app>/domains/Domain`

**Development vs Production Mode**

A domain is in production mode if the `ServerStartMode` option is set to prod *or* the domain `ProductionModeEnabled` is set to `true`.
The default value for both of these attributes is development mode.
The following is a model example with both attributes explicitly set to development mode.

```
domainInfo:
    ServerStartMode: dev
topology:
    ProductionModeEnabled: false
```

**boot.properties**

The `boot.properties` file is stored in the domain home on the machine where WDT runs.
Using the example above, it is stored for each server as:

`/opt/fedex/<app>/domains/Domain/servers/<server_name>/security/boot.properties`
