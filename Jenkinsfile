library 'reference-pipeline'
library 'AppServiceAccount'
library 'fedex-pipeline-core-lib@develop'

pipeline {

  agent {
    kubernetes {
      defaultContainer 'wls-12-2-1-4'
      label 'build-agent'
      yaml libraryResource('pods/wls-12.2.1.4.yaml')
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  parameters {
    choice(name: 'ENVIRONMENT', choices: 'Lab (Manual)\nCloudOps (Automated/EDC)\nCloudOps (Automated/CLW)\nAST (POC)', description: 'Target Environment')
    choice(name: 'ACTION', choices: 'sandbox\nprovision\ndeploy\nstart\nrestart\nstop\nkill\nundeploy\ndeprovision', description: 'Target Action')
  }

  environment {

    CF_PAM_ID = "1900001"
    EAI_NUMBER = "3538245"
    EAI_NAME = "WLAutoDeploy"
    GIT_BRANCH = "${env.BRANCH_NAME}"

    SSH_OPTIONS='-oStrictHostKeyChecking=no -oBatchMode=yes -oLogLevel=error -oUserKnownHostsFile=/dev/null'

    //
    // CloudOps Provisioning Config
    //
    OKTA_CREDS=credentials('okta_3536567_devtest')
    S3_CREDS=credentials('s3_3536567_devtest')
    MF_BROKER="mf-broker-prod.app.wtcbo4.paas.fedex.com"
    S3_ENDPOINT="https://swift-bo.swift.ute.fedex.com"
    ISSUER="https://purpleid-stage.oktapreview.com/oauth2/auss1ynuf4k5qzlNA0h7/v1/token?grant_type=client_credentials&response_type=token"

    //
    // WebLogic Config
    //
    DOMAIN_CREDS=credentials('wlvm_weblogic_admin')
    // !!! See the Environment stage for more defined with WLVM_* !!!

  }

  stages {

    stage('Environment') {
      steps {

        /* for debugging
        println '======================= ORIGINAL ENVIRONMENT VARS ======================='
        sh 'env | sort'
        println '^^^^^^^^^^^^^^^^^^^^^^^ ORIGINAL ENVIRONMENT VARS ^^^^^^^^^^^^^^^^^^^^^^^'
        */

        script{

          switch(env.ENVIRONMENT) {
            case 'Lab (Manual)':
              env.WLVM_TARGET_SERVERS='u0011359.test.cloud.fedex.com,u0011360.test.cloud.fedex.com,u0011361.test.cloud.fedex.com'
              env.WLVM_TARGET_JRE='/opt/java/hotspot/8/64_bit/jdk1.8.0_331'
              env.WLVM_TARGET_ORACLE='/opt/weblogic/wl12214_220419'
              env.WLVM_TARGET_WLS="${WLVM_TARGET_ORACLE}/wlserver"
              env.WLVM_TARGET_OPT='/opt/fedex/wlkube/wlvm'
              env.WLVM_TARGET_VAR='/var/fedex/wlkube/wlvm'
              env.WLVM_TARGET_LOG="${WLVM_TARGET_VAR}/log"
              env.WLVM_TARGET_TMP='/tmp/wlvm'
              env.WLVM_SSH_AGENT='WDTeval'
              env.WLVM_SSH_USER='f262337'
              env.WLVM_SERVER_MANAGED_PORT=8001
              env.WLVM_TARGET='L1'
              break
            case 'CloudOps (Automated/EDC)':
              env.WLVM_TARGET_SERVERS='u0011359.test.cloud.fedex.com,u0011360.test.cloud.fedex.com,u0011361.test.cloud.fedex.com'
              env.WLVM_TARGET_JRE='/opt/java/hotspot/8/latest'
              env.WLVM_TARGET_ORACLE='/opt/weblogic/wl12214_220419'
              env.WLVM_TARGET_WLS="${WLVM_TARGET_ORACLE}/wlserver"
              env.WLVM_TARGET_OPT='/opt/fedex/wltest/wlvm/deploy'
              env.WLVM_TARGET_VAR='/var/fedex/wltest/wlvm/deploy'
              env.WLVM_TARGET_LOG="${WLVM_TARGET_VAR}/log"
              env.WLVM_TARGET_TMP="${WLVM_TARGET_VAR}/tmp"
              env.WLVM_SSH_AGENT='WLVM-POC'
              env.WLVM_SSH_USER='wltest'
              env.WLVM_SERVER_MANAGED_PORT=8001
              env.WLVM_TARGET='L1'
              break 
            case 'CloudOps (Automated/CLW)':
              env.WLVM_TARGET_SERVERS='u0011359.test.cloud.fedex.com,u0011360.test.cloud.fedex.com,u0011361.test.cloud.fedex.com'
              env.WLVM_TARGET_JRE='/opt/java/hotspot/8/latest'
              env.WLVM_TARGET_ORACLE='/opt/weblogic/wl12214_220419'
              env.WLVM_TARGET_WLS="${WLVM_TARGET_ORACLE}/wlserver"
              env.WLVM_TARGET_OPT='/opt/fedex/wltest/wlvm'
              env.WLVM_TARGET_VAR='/var/fedex/wltest/wlvm'
              env.WLVM_TARGET_LOG="${WLVM_TARGET_VAR}/log"
              env.WLVM_TARGET_TMP="${WLVM_TARGET_VAR}/tmp"
              env.WLVM_SSH_AGENT='WDTeval'
              env.WLVM_SSH_USER='wltest'
              env.WLVM_TF_WORKSPACE='colo'
              env.WLVM_SERVER_MANAGED_PORT=8001
              env.WLVM_TARGET='L1'
              break
            case 'AST (POC)':
              env.WLVM_TARGET_SERVERS='u0003424.test.cloud.fedex.com,u0003425.test.cloud.fedex.com,u0003426.test.cloud.fedex.com'
              env.WLVM_TARGET_JRE='/opt/java/hotspot/8/latest'
              env.WLVM_TARGET_ORACLE='/opt/weblogic/wl12214_210119'
              env.WLVM_TARGET_WLS="${WLVM_TARGET_ORACLE}/wlserver"
              env.WLVM_TARGET_OPT='/opt/fedex/wlca/wlvm'
              env.WLVM_TARGET_VAR='/var/fedex/wlca/wlvm'
              env.WLVM_TARGET_LOG="${WLVM_TARGET_VAR}/log"
              env.WLVM_TARGET_TMP='/tmp/wlvm'
              env.WLVM_SSH_AGENT='WLCA'
              env.WLVM_SSH_USER='wlca'
              env.WLVM_SERVER_MANAGED_PORT=8001
              env.WLVM_TARGET='L1'
              break
          }

          env.WLVM_ROOT="${WORKSPACE}"
          env.WLVM_HOME="${WLVM_ROOT}/wlvm"
          env.WLVM_PACKAGE="${WLVM_HOME}/package"
          env.WLVM_PACKAGE_TOOL='wdt'
          env.WLVM_PACKAGE_SECRET_WDT='mysupersecret'
          env.WLVM_PACKAGE_SECRET_WLST="${WLVM_HOME}/etc/c2sSecretWlstCisDomain"

          env.WLVM_DOMAIN_USERNAME="${DOMAIN_CREDS_USR}"
          env.WLVM_DOMAIN_PASSWORD="${DOMAIN_CREDS_PSW}"
          env.WLVM_DOMAIN_PARENT="${WLVM_TARGET_OPT}/domain"
          env.WLVM_DOMAIN_NAME='L1CisDomain'
          env.WLVM_DOMAIN_HOME="${WLVM_DOMAIN_PARENT}/${WLVM_DOMAIN_NAME}"
          env.WLVM_DOMAIN_PRODUCTION=false
          env.WLVM_DOMAIN_TARGET='CisCluster'
          env.WLVM_SERVER_ADMIN_NAME='CisAdminServer'
          env.WLVM_SERVER_ADMIN_PORT=7001
          env.WLVM_SERVER_MANAGED_PREFIX='CisManagedServer'
          // WLVM_SERVER_MANAGED_PORT=8001 // unique to each environment
          env.WLVM_SERVER_LOG=false
          env.WLVM_SERVER_APPD=false
          env.WLVM_APP_EAI="${EAI_NUMBER}"
          env.WLVM_APP_VERSION='2.0'
          
          env.WLVM_CONTROL_KILL=30

        }

        println '======================= UPDATED ENVIRONMENT VARS  ======================='
        sh 'env | sort'
        println '^^^^^^^^^^^^^^^^^^^^^^^ UPDATED ENVIRONMENT VARS  ^^^^^^^^^^^^^^^^^^^^^^^'
      }
    }

    stage('Sandbox') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'sandbox'
        }
      }
      steps {
        checkSsh(_wlvmGlobalConfig())
      }
    }

    stage('Provision') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'provision'
        }
      }
      steps {
        withEnv(['http_proxy=internet.proxy.fedex.com:3128', 'https_proxy=internet.proxy.fedex.com:3128',"TF_VAR_client_id=${OKTA_CREDS_USR}","TF_VAR_secret=${OKTA_CREDS_PSW}","TF_VAR_issuer=${ISSUER}","TF_VAR_mf_broker_host=${MF_BROKER}","AWS_ACCESS_KEY_ID=${S3_CREDS_USR}","AWS_SECRET_ACCESS_KEY=${S3_CREDS_PSW}","AWS_S3_ENDPOINT=${S3_ENDPOINT}"],) {
          println "Provisioning cloudops environment from ${GIT_BRANCH}"
          sh 'pwd'
          dir('tf/') {
            sh 'terraform init -input=false'
            script {
              try {
                sh "terraform workspace new ${WLVM_TF_WORKSPACE}"
              } catch (Exception e) {
                sh 'terraform workspace list'
              }
            }
            sh "terraform workspace select ${WLVM_TF_WORKSPACE}"
            sh "terraform apply -var-file=\"${WLVM_TF_WORKSPACE}.tfvars\" -auto-approve"
            sh 'terraform show -json'
          }
        }
      }
    }

    stage('Build') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'deploy'
        }
      }
      steps {
        wlvmBuild(_wlvmGlobalConfig())
      }
    }

    stage('Package') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'deploy'
        }
      }
      steps {
        wlvmPackage(_wlvmGlobalConfig())
      }
    }

    stage('Load') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'deploy'
        }
      }
      steps {
        wlvmLoad(_wlvmGlobalConfig())
      }
    }

    stage('Deploy') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'deploy'
        }
      }
      steps {
        wlvmDeploy(_wlvmGlobalConfig())
      }
    }

    stage('Start') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'deploy'
          environment name: 'ACTION', value: 'start'
        }
      }
      steps {
        wlvmStart(_wlvmGlobalConfig())
      }
    }

    stage('Restart') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'restart'
        }
      }
      steps {
        wlvmRestart(_wlvmGlobalConfig())
      }
    }

    stage('Stop') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'stop'
          environment name: 'ACTION', value: 'undeploy'
          environment name: 'ACTION', value: 'deprovision'
        }
      }
      steps {
        wlvmStop(_wlvmGlobalConfig())
      }
    }

    stage('Kill') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'kill'
          environment name: 'ACTION', value: 'undeploy'
          environment name: 'ACTION', value: 'deprovision'
        }
      }
      steps {
        wlvmKill(_wlvmGlobalConfig())
      }
    }

    stage('Clean') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'undeploy'
          environment name: 'ACTION', value: 'deprovision'
        }
      }
      steps {
        wlvmClean(_wlvmGlobalConfig())
      }
    }

    stage('Deprovision') {
      when {
        anyOf {
          environment name: 'ACTION', value: 'deprovision'
        }
      }
      steps {
        withEnv(['http_proxy=internet.proxy.fedex.com:3128', 'https_proxy=internet.proxy.fedex.com:3128',"TF_VAR_client_id=${OKTA_CREDS_USR}","TF_VAR_secret=${OKTA_CREDS_PSW}","TF_VAR_issuer=${ISSUER}","TF_VAR_mf_broker_host=${MF_BROKER}","AWS_ACCESS_KEY_ID=${S3_CREDS_USR}","AWS_SECRET_ACCESS_KEY=${S3_CREDS_PSW}","AWS_S3_ENDPOINT=${S3_ENDPOINT}"],) {
          println "Provisioning cloudops environment from ${GIT_BRANCH}"
          sh 'pwd'
          dir('tf/') {
            sh 'terraform init -input=false'
            script {
              try {
                sh "terraform workspace new ${WLVM_TARGET}"
              } catch (Exception e) {
                sh 'terraform workspace list'
              }
            }
            sh "terraform workspace select ${WLVM_TARGET}"
            sh "terraform destroy -var-file=\"${WLVM_TARGET}.tfvars\" -auto-approve"
          }
        }
      }
    }

  }

}

def _wlvmGlobalConfig() {

  println """============ _wlvmGlobalConfig ============
  ACTION: ${ACTION}
  WLVM_HOME: ${WLVM_HOME}
  WLVM_PACKAGE: ${WLVM_PACKAGE}
  WLVM_TARGET_SERVERS: ${WLVM_TARGET_SERVERS}
  WLVM_TARGET_OPT: ${WLVM_TARGET_OPT}
  WLVM_TARGET_VAR: ${WLVM_TARGET_VAR}
  WLVM_TARGET_TMP: ${WLVM_TARGET_TMP}
  WLVM_DOMAIN_PARENT: ${WLVM_DOMAIN_PARENT}
  WLVM_DOMAIN_HOME: ${WLVM_DOMAIN_HOME}
  WLVM_SERVER_ADMIN_NAME: ${WLVM_SERVER_ADMIN_NAME}
  WLVM_SERVER_MANAGED_PREFIX: ${WLVM_SERVER_MANAGED_PREFIX}
  WLVM_CONTROL_KILL: ${WLVM_CONTROL_KILL}
  WLVM_SSH_AGENT: ${WLVM_SSH_AGENT}
  SSH_OPTIONS: ${SSH_OPTIONS}
  WLVM_SSH_USER: ${WLVM_SSH_USER}"""

  return [
    cmd:[
      parameter:"${ACTION}"
    ],
    source:[
      home:"${WLVM_HOME}",
      tmp:"${WLVM_PACKAGE}"
    ],
    target:[
      hosts:"${WLVM_TARGET_SERVERS}",
      opt:"${WLVM_TARGET_OPT}",
      var:"${WLVM_TARGET_VAR}",
      tmp:"${WLVM_TARGET_TMP}"
    ],
    domain:[
      home:"${WLVM_DOMAIN_HOME}"
    ],
    admin:[
      name:"${WLVM_SERVER_ADMIN_NAME}"
    ],
    managed:[
      prefix:"${WLVM_SERVER_MANAGED_PREFIX}"
    ],
    control:[
      kill:"${WLVM_CONTROL_KILL}"
    ],
    ssh:[
      agent:"${WLVM_SSH_AGENT}",
      options:"${SSH_OPTIONS}",
      user:"${WLVM_SSH_USER}"
    ]
  ]
}

//
// Sandbox
//

def checkSsh(Map config) {
  sshagent([config.ssh.agent]) {
    String[] hosts=config.target.hosts.split(',')
    hosts.each { host ->  
      sh """#!/bin/bash
      echo "========== in ssh: ${WLVM_SSH_USER}@${host}      =========="
      ssh ${SSH_OPTIONS} ${WLVM_SSH_USER}@${host} '
      whoami;
      pwd;'
      echo "========== exiting ssh: ${WLVM_SSH_USER}@${host} =========="
      """
    }
  }
}

//
// Build
//

def wlvmBuild(Map config) {
  dir(config.source.home) {
    sh("./build.sh")
  }
}

//
// Package
//

def wlvmPackage(Map config) {
  sh("mkdir -p ${config.source.tmp}")
  dir(config.source.home) {
    sh("./package.sh")
  }
}

//
// Load
//

def wlvmLoad(Map config) {
  // Prepare archive for load
  dir(config.source.tmp) {
    sh('zip -r stage .')
  }
  // Load archive
  String[] hosts=config.target.hosts.split(',')
  for (host in hosts) {
    config.action=['host':host]
    _wlvmHostLoad(config)
  }
  config.remove('action')
  // Clean prepared archive
  sh("rm ${config.source.tmp}/stage.zip")
}

def _wlvmHostLoad(Map config) {
  if (!_wlvmHostLoaded(config)) {
    sshagent([config.ssh.agent]) {
      sh(_wlvmHostSsh(config, "mkdir -p ${config.target.tmp}"))
      sh(_wlvmHostScp(config, "${config.source.tmp}/stage.zip", config.target.tmp, false))
      sh(_wlvmHostSsh(config, "'cd ${config.target.tmp} && unzip stage.zip && rm stage.zip'"))
    }
  }
}

def _wlvmHostLoaded(Map config) {
  boolean result
  String cmd="'[ -d ${config.target.tmp} ]; echo \$?'"
  sshagent([config.ssh.agent]) {
    String value=sh(script:_wlvmHostSsh(config, cmd), returnStdout:true).trim()
    result=value.equals("0")
  }
  return result
}

//
// Deploy
//

def wlvmDeploy(Map config) {
  String[] hosts=config.target.hosts.split(',')
  boolean hasManaged=(hosts.size()>1)
  if (hosts.size() == 1) {
    config.action=['host':hosts[0], 'admin':true, 'managed':0]
    _wlvmHostDeploy(config)
  } else {
    hosts.eachWithIndex { host, index ->
      boolean isAdmin=(index==0)
      int managedIndex=index+1
      config.action=['host':hosts[index], 'admin':isAdmin, 'managed':managedIndex]
      _wlvmHostDeploy(config)
    }
  }
  config.remove('action')
}

def _wlvmHostDeploy(Map config) {
  if (!_wlvmDomainDeployed(config)) {
    sshagent([config.ssh.agent]) {

      // Create domain
      sh(_wlvmHostSsh(config, "'cd ${config.target.tmp} && . ./env.sh && ./create.sh'"))

      // If domain has managed server...
      if (config.action.managed) {
        String domainSerialized="${config.domain.home}/security/SerializedSystemIni.dat"
        String adminBoot="${config.domain.home}/servers/${config.admin.name}/security/boot.properties"
        String managedSecurity="${config.domain.home}/servers/${config.managed.prefix}${config.action.managed}/security"
        String managedBoot="${managedSecurity}/boot.properties"
        // Synchronize security files
        if (config.action.admin) {
          // Download from domain with admin server
          sh(_wlvmHostScp(config, domainSerialized, "${config.source.tmp}/SerializedSystemIni.dat", true))
          sh(_wlvmHostScp(config, adminBoot, "${config.source.tmp}/boot.properties", true))
        } else {
          // Sync SerializedSystemIni.dat file to domain without admin server
          sh(_wlvmHostScp(config, "${config.source.tmp}/SerializedSystemIni.dat", domainSerialized, false))
        }
        // Sync boot.properties file
        sh(_wlvmHostSsh(config, "mkdir -p ${managedSecurity}"))
        sh(_wlvmHostScp(config, "${config.source.tmp}/boot.properties", managedBoot, false))
      }

      // Clean up domain packaging
      sh(_wlvmHostSsh(config, "'cd ${config.target.tmp} && rm -r stage && rm create.sh'"))

    }
  }
}

//
// Start
//

def wlvmStart(Map config) {
  String[] hosts=config.target.hosts.split(',')
  // Admin server
  config.action=[host:hosts[0], managed:0]
  _wlvmServerStart(config)
  sh 'sleep 30'
  // Managed servers
  if (hosts.size() > 1) {
    hosts.eachWithIndex { host, index ->
      config.action=[host:host, managed:index+1]
      _wlvmServerStart(config)
    }
  }
  config.remove('action')
}

def _wlvmServerStart(Map config) {
  String pid=_wlvmServerPid(config)
  if (!pid) {
    String cmd
    if (config.action.managed==0) { // Admin
      cmd="'cd ${config.target.tmp} && . ./env.sh && ./start.sh'"
    } else { // Managed
      cmd="'cd ${config.target.tmp} && . ./env.sh && ./start.sh ${config.action.managed}'"
    }
    sshagent([config.ssh.agent]) {
      sh(_wlvmHostSsh(config, cmd))
    }
  }
}

//
// Stop
//

def wlvmStop(Map config) {
  String[] hosts=config.target.hosts.split(',')
  // Admin server
  config.action=[host:hosts[0], managed:0]
  _wlvmServerStop(config)
  // Managed servers
  if (hosts.size() > 1) {
    hosts.eachWithIndex { host, index ->
      config.action=[host:host, managed:index+1]
      _wlvmServerStop(config)
    }
  }
  config.remove('action')
}

def _wlvmServerStop(Map config) {
  String pid=_wlvmServerPid(config)
  if (pid) {
    String cmd
    if (config.action.managed==0) { // Admin
      cmd="'cd ${config.target.tmp} && . ./env.sh && ./stop.sh'"
    } else { // Managed
      cmd="'cd ${config.target.tmp} && . ./env.sh && ./stop.sh ${config.action.managed}'"
    }
    sshagent([config.ssh.agent]) {
      sh(_wlvmHostSsh(config, cmd))
    }
  }
}

//
// Restart
//

def wlvmRestart(Map config) {
  String[] hosts=config.target.hosts.split(',')
  // Admin server
  config.action=[host:hosts[0], managed:0]
  _wlvmServerRestart(config)
  sh 'sleep 30'
  // Managed servers
  if (hosts.size() > 1) {
    hosts.eachWithIndex { host, index ->
      config.action=[host:host, managed:index+1]
      _wlvmServerRestart(config)
    }
  }
  config.remove('action')
}

def _wlvmServerRestart(Map config) {
  _wlvmServerStop(config)
  _wlvmServerStart(config)
}

//
// Kill
//

def wlvmKill(Map config) {
  String[] hosts=config.target.hosts.split(',')
  // Admin server
  config.action=[host:hosts[0], managed:0]
  _wlvmServerKill(config)
  // Managed servers
  if (hosts.size() > 1) {
    hosts.eachWithIndex { host, index ->
      config.action=[host:host, managed:index+1]
      _wlvmServerKill(config)
    }
  }
  config.remove('action')
}

def _wlvmServerKill(Map config) {
  // Kill server gracefully
  _wlvmServerKillWithSignal(config, '-TERM')
  String pid=_wlvmServerPid(config)
  // Wait for server to be killed
  int seconds=0
  while (pid && (seconds < config.control.kill)) {
    sh 'sleep 5'
    seconds+=5
    pid=_wlvmServerPid(config)
  }
  // Kill server forcibly
  if (pid) {
    _wlvmServerKillWithSignal(config, '-9')
  }
  // Kill other daemons
  String cmd
  if (config.action.managed==0) { // Admin
    cmd="'cd ${config.target.tmp} && . ./env.sh && ./kill.sh'"
  } else { // Managed
    cmd="'cd ${config.target.tmp} && . ./env.sh && ./kill.sh ${config.action.managed}'"
  }
  sshagent([config.ssh.agent]) {
    sh(_wlvmHostSsh(config, cmd))
  }
}

def _wlvmServerKillWithSignal(Map config, String signal) {
  String pid=_wlvmServerPid(config)
  if (pid) {
    sshagent([config.ssh.agent]) {
      sh(_wlvmHostSsh(config, "kill ${signal} ${pid}"))
    }
  }
}

//
// Clean
//

def wlvmClean(Map config) {
  String[] hosts=config.target.hosts.split(',')
  for (host in hosts) {
    config.action=[host:host]
    _wlvmHostClean(config)
  }
  config.remove('action')
}

def _wlvmHostClean(Map config) {
  // do we care if _wlvmDomainDeployed(config) == true?
  // if (_wlvmDomainDeployed(config) && !_wlvmDomainRunning(config)) {
  if (!_wlvmDomainRunning(config)) {
    sshagent([config.ssh.agent]) {

      if (_dirExists(config, "${config.target.tmp}")){
        println "deleting ${config.target.tmp}"
        sh(_wlvmHostSsh(config, "'cd ${config.target.tmp} && . ./env.sh && ./clean.sh'"))
        sh(_wlvmHostSsh(config, "'rm -r ${config.target.tmp}'"))
      } else {
        println "${config.target.tmp} does not exist"
      }
      if (_dirExists(config, "${config.target.opt}")){
        println "deleting ${config.target.opt}"
        sh(_wlvmHostSsh(config, "'rm -r ${config.target.opt}'"))
      } else {
        println "${config.target.opt} does not exist"
      }
      if (_dirExists(config, "${config.target.var}")){
        println "deleting ${config.target.var}"
        sh(_wlvmHostSsh(config, "'rm -r ${config.target.var}'"))
      } else {
        println "${config.target.var} does not exist"
      }
    }
  } else {
    println "_wlvmDomainDeployed(config) = " + _wlvmDomainDeployed(config)
    println "_wlvmDomainRunning(config) = " + _wlvmDomainRunning(config)
  }
}

def _wlvmDomainRunning(Map config) {
  boolean result=false
  String[] pids=_wlvmDomainPids(config)
  if (pids) { result=true }
  return result
}

def _wlvmDomainPids(Map config) {
  String[] result
  String cmd="ps -ef | grep -E \"\\-Dweblogic.Name=\" | grep -v 'grep' | awk '{print \$2}'"
  sshagent([config.ssh.agent]) {
    String value=sh(script:_wlvmHostSsh(config, cmd), returnStdout:true).trim()
    if (value) { result=value.split("\\s+") }
  }
  return result
}

//
// Utility
//

def _wlvmDomainDeployed(Map config) {
  boolean result
  String cmd="'[ -d ${config.domain.home} ]; echo \$?'"
  sshagent([config.ssh.agent]) {
    String value=sh(script:_wlvmHostSsh(config, cmd), returnStdout:true).trim()
    result=value.equals("0")
  }
  return result
}

def _wlvmServerDeployed(Map config) {
  boolean result
  String domain=_wlvmServerDomain(config)
  String cmd="'[ -d ${domain} ]; echo \$?'"
  sshagent([config.ssh.agent]) {
    String value=sh(script:_wlvmHostSsh(config, cmd), returnStdout:true).trim()
    result=value.equals("0")
  }
  return result
}

def _wlvmServerRunning(Map config) {
  return _wlvmServerPid(config) as boolean
}

def _wlvmServerPid(Map config) {
  String result
  String name=_wlvmServerName(config)
  String cmd="ps -ef | grep -E \"\\-Dweblogic.Name=${name}\" | grep -v 'grep' | awk '{print \$2}'"
  sshagent([config.ssh.agent]) {
    result=sh(script:_wlvmHostSsh(config, cmd), returnStdout:true).trim()
  }
  return result
}

def _wlvmServerDomain(Map config) {
  String result
  String name=_wlvmServerName(config)
  result="${config.domain.home}/servers/${name}"
  return result
}

def _wlvmServerName(Map config) {
  String result
  if (config.action.managed==0) { // Admin
    result=config.admin.name
  } else { // Managed
    result="${config.managed.prefix}${config.action.managed}"
  }
  return result
}

def _wlvmHostSsh(Map config, String cmd) {
  return "ssh ${config.ssh.options} ${config.ssh.user}@${config.action.host} ${cmd}"
}

def _dirExists(Map config, dir) {
  boolean result
  String cmd="'[ -d ${dir} ]; echo \$?'"
  sshagent([config.ssh.agent]) {
    String value=sh(script:_wlvmHostSsh(config, cmd), returnStdout:true).trim()
    result=value.equals("0")
  }
  return result
}

def _hostArray(Map config) {
  String[] hosts=config.target.hosts.split(',')
  return hosts
}

def _wlvmHostScp(Map config, String from, String to, boolean isDownload) {
  String result
  if (isDownload) {
    result="scp ${config.ssh.options} ${config.ssh.user}@${config.action.host}:${from} ${to}"
  } else {
    result="scp ${config.ssh.options} ${from} ${config.ssh.user}@${config.action.host}:${to}"
  }
  return result
}
