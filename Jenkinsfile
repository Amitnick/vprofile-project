pipeline {

    agent any

    options {
        ansiColor('xterm')
    }

    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "18.222.73.88:8081"
        NEXUS_REPOSITORY = "vprofile-release"
        NEXUS_REPOGRP_ID    = "vpro-maven-group"
        NEXUS_CREDENTIAL_ID = "admin"
        NEXUSIP="18.222.73.88"
        NEXUSPORT="8081"
        ARTVERSION = "${env.BUILD_ID}"
        scannerHome="vpro-sonar"
    }

    stages{

        stage('CHECKOUT') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [[$class: 'WipeWorkspace']], userRemoteConfigs: [[url: 'https://github.com/Amitnick/vprofile-project.git']]])
            }
        }

        stage('UNIT TEST'){
            steps {
                sh 'mvn test'
            }
        }

        stage('INTEGRATION TEST'){
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage ('CODE ANALYSIS: CHECKSTYLE'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('CODE ANALYSIS with SONARQUBE') {
            environment {
                scannerHome = tool 'mysonarscanner4'
            }

            steps {
                withSonarQubeEnv('sonar-pro') {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                       -Dsonar.projectName=vprofile-repo \
                       -Dsonar.projectVersion=1.0 \
                       -Dsonar.sources=src/ \
                       -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                       -Dsonar.junit.reportsPath=target/surefire-reports/ \
                       -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                       -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }

                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('BUILD'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('OWASP-CHECK') {
            steps {
                dependencyCheck additionalArguments: '--format JSON', odcInstallation: 'OWASP-check'
            }
        }

        stage ('GENERATE REPORT'){
            steps {
                recordIssues(tools: [checkStyle(id: 'CheckStyle-Issues', pattern: 'target/checkstyle-result.xml'), owaspDependencyCheck(id: 'OWASP-issues', pattern: 'dependency-check-report.json')])
            }
        }

        stage("CHECK INTO ARTIFACTORY") {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version} ARTVERSION";
                        nexusArtifactUploader artifacts: [[artifactId: "${pom.artifactId}", classifier: '', file: "${artifactPath}", type: "${pom.packaging}"]], credentialsId: 'nexusServerLogin', groupId: 'QA1', nexusUrl: "${NEXUS_URL}", nexusVersion: 'nexus3', protocol: 'http', repository: 'vprofile-release', version: "${env.BUILD_ID}"
                    }
                    else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }

        stage ('CONTAINERISE'){
            steps {
                sh 'ls ./docker/app'
                sh 'aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 567798517868.dkr.ecr.us-east-2.amazonaws.com'
                sh "cp target/*.war ./docker/app/ && cd ./docker/app && docker build -t vpro-app ."
                sh "docker tag vpro-app 567798517868.dkr.ecr.us-east-2.amazonaws.com/vpro-app:${env.BUILD_ID} && docker push 567798517868.dkr.ecr.us-east-2.amazonaws.com/vpro-app:${env.BUILD_ID}"
                sh "docker tag vpro-app 567798517868.dkr.ecr.us-east-2.amazonaws.com/vpro-app:latest && docker push 567798517868.dkr.ecr.us-east-2.amazonaws.com/vpro-app:latest"
                sh "docker images"
                sh "docker rmi 567798517868.dkr.ecr.us-east-2.amazonaws.com/vpro-app:${env.BUILD_ID} 567798517868.dkr.ecr.us-east-2.amazonaws.com/vpro-app:latest"
                sh "docker images"
            }
            post {
                success {
                    echo 'Image Created and Pushed'
                }
            }
        }

        stage ('DEPLOY ON CLUSTER'){
            steps {
                sh 'aws eks --region us-east-2 update-kubeconfig --name demo-cluster'
                sh "cd ./kube-scripts && pwd && sed -i \"s#LATEST_TAG#${env.BUILD_ID}#g\" app-dep.yaml && kubectl apply -f ."
            }
            post {
                success {
                    echo 'Image Deployed'
                    sh 'ENDPOINT=$(kubectl get svc | grep LoadBalancer | awk \'{print $4}\') && echo "SERVICE ENDPOINT: ${ENDPOINT}"'

                }
            }
        }
    }
}
