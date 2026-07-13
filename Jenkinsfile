pipeline {

    agent any


    tools {


        maven 'Maven3'

    }


    environment {

        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')

        DOCKER_IMAGE = "gurugowdamn/ott-platform"

        IMAGE_TAG = "${BUILD_NUMBER}"

        CONTAINER_NAME = "ott-platform-app"

        NETWORK_NAME = "ott-network"

    }


    options {

        timestamps()

        buildDiscarder(logRotator(
            numToKeepStr: '10'
        ))

    }


    stages {


        stage('Checkout') {

            steps {

                echo 'Checking out source code'

                checkout scm

            }

        }



        stage('Build') {

            steps {

                echo 'Building Spring Boot application'

                sh '''

                mvn clean package -DskipTests

                '''

            }

        }



        stage('Test') {

            steps {

                echo 'Running Unit Tests'

                sh '''

                mvn test

                '''

            }

            post {

                always {

                    junit '**/target/surefire-reports/*.xml'

                }

            }

        }



        stage('Docker Build') {

            steps {

                echo 'Building Docker Image'

                sh '''

                docker build \
                -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                -t ${DOCKER_IMAGE}:latest .

                '''

            }

        }



        stage('Docker Login & Push') {

            steps {

                echo 'Pushing Image to Docker Hub'


                sh '''

                echo $DOCKERHUB_CREDENTIALS_PSW | \
                docker login \
                -u $DOCKERHUB_CREDENTIALS_USR \
                --password-stdin


                docker push ${DOCKER_IMAGE}:${IMAGE_TAG}


                docker push ${DOCKER_IMAGE}:latest


                '''

            }

        }



        stage('Deploy OTT Application') {

            steps {


                echo 'Deploying new container'


                sh '''

                docker stop ${CONTAINER_NAME} || true


                docker rm ${CONTAINER_NAME} || true



                docker run -d \
                --name ${CONTAINER_NAME} \
                --network ${NETWORK_NAME} \
                -p 8081:8081 \
                -e SPRING_PROFILES_ACTIVE=local \
                ${DOCKER_IMAGE}:latest


                '''

            }

        }



        stage('Verify Deployment') {

            steps {

                echo 'Checking application health'


                sh '''

                sleep 20


                curl -f http://localhost:8081/api/ping


                '''

            }

        }


    }


    post {


        success {

            echo 'OTT Platform Deployment Successful'

        }


        failure {

            echo 'OTT Platform Deployment Failed'

        }


        always {

            sh '''

            docker logout || true

            '''

        }

    }


}
