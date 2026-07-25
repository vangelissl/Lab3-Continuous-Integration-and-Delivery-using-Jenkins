@Library('cicd-library') _

pipeline {

    agent none

    environment {

        IMAGE_TAG = "v1.0"

        DOCKER_USER = "mariastashenko"

        MAIN_IMAGE = "${DOCKER_USER}/nodemain:${IMAGE_TAG}"
        DEV_IMAGE  = "${DOCKER_USER}/nodedev:${IMAGE_TAG}"

    }


    stages {


        stage('Checkout') {

            agent any

            steps {

                checkout scm

            }

        }


        stage('Build') {

            agent {

                docker {
                    image 'node:20'
                    reuseNode true
                }

            }

            steps {

                sh 'npm install'

            }

        }


        stage('Test') {

            agent {

                docker {
                    image 'node:20'
                    reuseNode true
                }

            }

            steps {

                sh 'npm test'

            }

        }


        stage('Hadolint') {

            agent any

            steps {

                sh 'hadolint Dockerfile'

            }

        }


        stage('Build Docker Image') {

            agent any

            steps {

                script {

                    if (env.BRANCH_NAME == 'main') {

                        dockerBuild(MAIN_IMAGE)

                    }

                    else if (env.BRANCH_NAME == 'dev') {

                        dockerBuild(DEV_IMAGE)

                    }

                    else {

                        error "Unsupported branch ${env.BRANCH_NAME}"

                    }

                }

            }

        }


        stage('Trivy Scan') {

            agent any

            steps {

                script {

                    if (env.BRANCH_NAME == 'main') {

                        sh """
                        trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 0 \
                        ${MAIN_IMAGE}
                        """

                    }

                    else if (env.BRANCH_NAME == 'dev') {

                        sh """
                        trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 0 \
                        ${DEV_IMAGE}
                        """

                    }

                }

            }

        }



        stage('Push Docker Image') {

            agent any

            steps {

                script {

                    if (env.BRANCH_NAME == 'main') {

                        dockerPush(MAIN_IMAGE)

                    }

                    else if (env.BRANCH_NAME == 'dev') {

                        dockerPush(DEV_IMAGE)

                    }

                }

            }

        }



        stage('Trigger Deployment') {

            agent any

            steps {

                script {

                    if (env.BRANCH_NAME == 'main') {

                        build(
                            job: 'Deploy_to_main',
                            wait: false
                        )

                    }

                    else if (env.BRANCH_NAME == 'dev') {

                        build(
                            job: 'Deploy_to_dev',
                            wait: false
                        )

                    }

                }

            }

        }


    }


    post {

        success {

            echo "CICD completed successfully for ${env.BRANCH_NAME}"

        }


        failure {

            echo "CICD failed for ${env.BRANCH_NAME}"

        }

    }

}