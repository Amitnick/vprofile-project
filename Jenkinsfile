pipeline {

    agent any

    options {
        ansiColor('xterm')
    }

    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "172.31.10.108:8081"
        NEXUS_REPOSITORY = "vprofile-release"
        NEXUS_REPOGRP_ID    = "vpro-maven-group"
        NEXUS_CREDENTIAL_ID = "admin"
        NEXUSIP="172.31.1.5"
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

        stage ('CODE ANALYSIS WITH CHECKSTYLE'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('OWASP-check') {
            steps {
                dependencyCheck additionalArguments: '', odcInstallation: 'OWASP-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
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

        stage("Publish to Nexus Repository Manager") {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version} ARTVERSION";
                        // nexusArtifactUploader(
                        //     nexusVersion: NEXUS_VERSION,
                        //     protocol: NEXUS_PROTOCOL,
                        //     nexusUrl: NEXUS_URL,
                        //     groupId: NEXUS_REPOGRP_ID,
                        //     version: ARTVERSION,
                        //     repository: NEXUS_REPOSITORY,
                        //     credentialsId: NEXUS_CREDENTIAL_ID,
                        //     artifacts: [
                        //         [artifactId: pom.artifactId,
                        //         classifier: '',
                        //         file: artifactPath,
                        //         type: pom.packaging],
                        //         [artifactId: pom.artifactId,
                        //         classifier: '',
                        //         file: "pom.xml",
                        //         type: "pom"]
                        //     ]
                        // );
                        nexusArtifactUploader artifacts: [[artifactId: "${pom.artifactId}", classifier: '', file: "${artifactPath}", type: "${pom.packaging}"]], credentialsId: 'nexusServerLogin', groupId: 'QA1', nexusUrl: "${NEXUS_URL}", nexusVersion: 'nexus3', protocol: 'http', repository: 'vprofile-release', version: "${env.BUILD_ID}"
                    }
                    else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }


        stage ('Generate Report'){
            steps {
                recordIssues(tools: [checkStyle(id: 'CheckStyle-Issues', pattern: '**/checkstyle-result.xml'), owaspDependencyCheck(id: 'OWASP-issues', pattern: '**/dependency-check-report.xml')])
            }
        }

        stage ('Create & Push Image'){
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

        stage ('Deploy on Cluster'){
            steps {
                sh 'aws eks --region us-east-2 update-kubeconfig --name demo-cluster'
                sh "cd ./kube-scripts && pwd && sed -i \"s#LATEST_TAG#${env.BUILD_ID}#g\" app-dep.yaml && kubectl apply -f ."
            }
            post {
                success {
                    echo 'Image Deployed'
                }
            }
        }

    }


}
