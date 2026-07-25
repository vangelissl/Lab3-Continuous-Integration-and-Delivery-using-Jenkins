pipeline {
    agent any

    tools {
        nodejs 'node'
    }

    environment {
        MAIN_IMAGE = "nodemain:v1.0"
        DEV_IMAGE = "nodedev:v1.0"

        MAIN_CONTAINER = "nodemain-container"
        DEV_CONTAINER = "nodedev-container"
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

                        sh '''
                            docker build -t ${MAIN_IMAGE} .
                        '''

                    } 
                    else if (env.BRANCH_NAME == 'dev') {

                        sh '''
                            docker build -t ${DEV_IMAGE} .
                        '''

                    }
                    else {
                        error "Unsupported branch: ${env.BRANCH_NAME}"
                    }
                }
            }
        }


        stage('Deploy') {
            steps {
                script {

                    if (env.BRANCH_NAME == 'main') {

                        sh '''
                            echo "Deploying main environment..."

                            docker stop ${MAIN_CONTAINER} || true
                            docker rm ${MAIN_CONTAINER} || true

                            docker run -d \
                                --name ${MAIN_CONTAINER} \
                                --expose 3000 \
                                -p 3000:3000 \
                                ${MAIN_IMAGE}
                        '''

                    }


                    else if (env.BRANCH_NAME == 'dev') {

                        sh '''
                            echo "Deploying dev environment..."

                            docker stop ${DEV_CONTAINER} || true
                            docker rm ${DEV_CONTAINER} || true

                            docker run -d \
                                --name ${DEV_CONTAINER} \
                                --expose 3001 \
                                -p 3001:3000 \
                                ${DEV_IMAGE}
                        '''
                    }

                }
            }
        }
    }


    post {

        success {
            echo "Pipeline completed successfully for ${env.BRANCH_NAME}"
        }

        failure {
            echo "Pipeline failed for ${env.BRANCH_NAME}"
        }
    }
}