pipeline {

    agent any

    tools {
        maven 'Maven3'
    }

    environment {

        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')

        DOCKER_IMAGE = "gurugowdamn/ott-platform"

        IMAGE_TAG = "${BUILD_NUMBER}"

        CONTAINER_NAME = "ott-platform-app"

    }


    options {

        timestamps()

        buildDiscarder(
            logRotator(
                numToKeepStr: '10'
            )
        )
    }


    stages {


        stage('Checkout') {

            steps {

                echo "Checking out source code"

                checkout scm

            }
        }



        stage('Build') {

            steps {

                echo "Building application"

                sh 'mvn clean compile'

            }
        }



        stage('Test') {

            steps {

                echo "Running unit tests"

                sh 'mvn test'

            }

            post {

                always {

                    junit allowEmptyResults: true,
                          testResults: '**/target/surefire-reports/*.xml'

                }

            }

        }



        stage('Package') {

            steps {

                echo "Creating Spring Boot Jar"

                sh 'mvn package -DskipTests'

            }


            post {

                success {

                    archiveArtifacts(
                        artifacts: 'target/*.jar',
                        fingerprint: true
                    )

                }

            }

        }



        stage('Docker Build') {

            steps {

                echo "Building Docker image"

                sh """
                docker build \
                -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                -t ${DOCKER_IMAGE}:latest .
                """

            }

        }



        stage('Docker Login & Push') {

            steps {

                echo "Logging into Docker Hub"


                sh """

                echo \$DOCKERHUB_CREDENTIALS_PSW | \
                docker login \
                -u \$DOCKERHUB_CREDENTIALS_USR \
                --password-stdin


                docker push ${DOCKER_IMAGE}:${IMAGE_TAG}

                docker push ${DOCKER_IMAGE}:latest

                """

            }

        }



        stage('Deploy OTT Application') {

            steps {

                echo "Deploying container"


                sh """

                docker stop ${CONTAINER_NAME} || true

                docker rm ${CONTAINER_NAME} || true


                docker run -d \
                --name ${CONTAINER_NAME} \
                --network ott-network \
                -p 8081:8081 \
                -e SPRING_PROFILES_ACTIVE=local \
                ${DOCKER_IMAGE}:latest

                """

            }

        }



        stage('Verify Deployment') {

            steps {

                echo "Checking application health"


                sh """

                sleep 20


                curl -f http://localhost:8081/api/ping

                """

            }

        }


    }



    post {


        success {

            echo "OTT Platform Deployment Successful"

        }


        failure {

            echo "OTT Platform Deployment Failed"

        }


        always {

            sh '''

            docker logout || true

            '''

        }

    }

}
