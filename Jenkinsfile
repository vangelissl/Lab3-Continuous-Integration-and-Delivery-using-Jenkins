pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }

    environment {
        IMAGE_TAG = "v1.0"

        DOCKER_USER = "mariastashenko"

        MAIN_IMAGE = "${DOCKER_USER}/nodemain:${IMAGE_TAG}"
        DEV_IMAGE  = "${DOCKER_USER}/nodedev:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {

                    if (env.BRANCH_NAME == 'main') {

                        sh """
                        docker build -t ${MAIN_IMAGE} .
                        """

                    } else {

                        sh """
                        docker build -t ${DEV_IMAGE} .
                        """

                    }

                }
            }
        }

        stage('Docker Login') {
            steps {

                withCredentials([usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD')]) {

                    sh '''
                    echo "$DOCKER_PASSWORD" | docker login \
                        -u "$DOCKER_USERNAME" \
                        --password-stdin
                    '''
                }

            }
        }

        stage('Push Image') {
            steps {
                script {

                    if (env.BRANCH_NAME == 'main') {

                        sh "docker push ${MAIN_IMAGE}"

                    } else {

                        sh "docker push ${DEV_IMAGE}"

                    }

                }
            }
        }

        stage('Trigger Deployment') {

            steps {

                script {

                    if (env.BRANCH_NAME == 'main') {

                        build job: 'Deploy_to_main',
                                wait: false

                    } else {

                        build job: 'Deploy_to_dev',
                                wait: false

                    }

                }

            }

        }

    }

    post {

        always {

            sh 'docker logout || true'

        }

    }

}