pipeline {

    agent any

    tools {
        nodejs 'node'
    }

    environment {

        IMAGE_TAG = "v1.0"

        DOCKER_USERNAME = "mariastashenko"

        MAIN_IMAGE = "${DOCKER_USERNAME}/nodemain:${IMAGE_TAG}"
        DEV_IMAGE  = "${DOCKER_USERNAME}/nodedev:${IMAGE_TAG}"

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
                            docker build \
                            -t ${MAIN_IMAGE} .
                        """


                    } else if (env.BRANCH_NAME == 'dev') {


                        sh """
                            docker build \
                            -t ${DEV_IMAGE} .
                        """


                    } else {

                        error "Unsupported branch ${env.BRANCH_NAME}"

                    }

                }

            }

        }



        stage('Docker Login') {

            steps {


                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {


                    sh '''
                        echo "$PASSWORD" | docker login \
                        -u "$USERNAME" \
                        --password-stdin
                    '''


                }


            }

        }



        stage('Push Docker Image') {


            steps {


                script {


                    if (env.BRANCH_NAME == 'main') {


                        sh """
                            docker push ${MAIN_IMAGE}
                        """


                    } else if (env.BRANCH_NAME == 'dev') {


                        sh """
                            docker push ${DEV_IMAGE}
                        """


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


                    } else if (env.BRANCH_NAME == 'dev') {


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


        success {


            echo "CICD pipeline completed successfully for ${env.BRANCH_NAME}"


        }


        failure {


            echo "CICD pipeline failed for ${env.BRANCH_NAME}"


        }


    }

}