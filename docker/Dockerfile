# Let's start with an OS+JDK+MVN+GRADLE
FROM nexus2.prod.cloud.fedex.com:8444/fdx/jenkins/default-tools-image

# Prepare WebLogic Server (WLS) installation
USER root
RUN groupadd weblogic \
 && useradd -g weblogic weblogic \
 && usermod -a -G weblogic jenkins \
 && mkdir -p /opt/weblogic
COPY oraInst.loc /opt/weblogic/
COPY wls.rsp /tmp/weblogic/
RUN cd /tmp/weblogic \
 && wget --progress=bar:force https://nexus.prod.cloud.fedex.com:8443/nexus/repository/rawbinaries/eai3536567/com/oracle/wls/12.2.1.4/fmw_12.2.1.4.0_wls_lite_Disk1_1of1.zip \
 && chown -R weblogic:weblogic /opt/weblogic \
 && chown -R weblogic:weblogic /tmp/weblogic \
 && chmod 750 /opt/weblogic

# Install Terraform
ARG TERRAFORM_VERSION
RUN mkdir -p /tmp/terraform \
 && cd /tmp/terraform \
 && wget --progress=bar:force https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
 && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ \
 && rm -rf /tmp/terraform

# Install WLS
USER weblogic
RUN unzip -q /tmp/weblogic/fmw_12.2.1.4.0_wls_lite_Disk1_1of1.zip "*.jar" -d /tmp/weblogic \
 && ${JAVA_HOME}/bin/java -Xmx1024m \
     -jar /tmp/weblogic/fmw_12.2.1.4.0_wls_lite_generic.jar \
     -silent ORACLE_HOME=/opt/weblogic/wl12214 \
     -responseFile /tmp/weblogic/wls.rsp \
     -invPtrLoc /opt/weblogic/oraInst.loc \
     -ignoreSysPrereqs -force -novalidation \
 && rm -rf /tmp/weblogic
ENV ORACLE_HOME=/opt/weblogic/wl12214
ENV WL_HOME=/opt/weblogic/wl12214/wlserver

# Install wlfullclient.jar
RUN cd ${WL_HOME}/server/lib \
 && java -jar wljarbuilder.jar

# Install WebLogic Maven Plug-In
USER jenkins
RUN cd ${ORACLE_HOME}/oracle_common/plugins/maven/com/oracle/maven/oracle-maven-sync/12.2.1 \
 && mvn install:install-file -DpomFile="oracle-maven-sync-12.2.1.pom" -Dfile="oracle-maven-sync-12.2.1.jar" \
 && mvn com.oracle.maven:oracle-maven-sync:push -Dmaven.local.repo="${HOME}/.m2/repository/" -DoracleHome=${ORACLE_HOME}

# Initialize Terraform
RUN terraform init \
 && mkdir -p ${HOME}/.terraform.d/plugins \
 && mkdir -p /tmp/terraform \
 && cd /tmp/terraform \
 && wget --progress=bar:force https://nexus.prod.cloud.fedex.com:8443/nexus/repository/release/eai3536567/com/fedex/cloudops/terraform-provider-cloudops/0.1.07/terraform-provider-cloudops-0.1.07.tar.gz \
 && tar -xzf terraform-provider-cloudops-0.1.07.tar.gz -C ${HOME}/.terraform.d/plugins/ \
 && wget --progress=bar:force https://nexus.prod.cloud.fedex.com:8443/nexus/repository/release/eai3536567/com/fedex/cloudops/terraform-provider-cloudops/0.1.06/terraform-provider-cloudops-0.1.06.tar.gz \
 && tar -xzf terraform-provider-cloudops-0.1.06.tar.gz -C ${HOME}/.terraform.d/plugins/ \
 && rm -rf /tmp/terraform

# Finalize Dockerized build 
#ENTRYPOINT ["/build/docker-entrypoint.sh"]
