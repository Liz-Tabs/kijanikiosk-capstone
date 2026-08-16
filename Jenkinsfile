pipeline {
    agent any

    environment {
        APP_NAME = 'kk-payments'
        STAGING_NAMESPACE = 'kijani-staging'
        IMAGE_TAG = '1.0.0'
    }

    stages {
        stage('Build') {
            steps {
                dir('app/kk-payments') {
                    sh 'npm ci'
                    sh 'npm run lint'
                }
            }
        }

        stage('Test') {
            steps {
                dir('app/kk-payments') {
                    sh 'npm test'
                }
            }
        }

        stage('Build Container') {
            steps {
                dir('app/kk-payments') {
                    sh 'docker build -t ${APP_NAME}:${IMAGE_TAG} .'
                }
            }
        }
stage('Verify Kubernetes Access') {
    steps {
        withCredentials([
            string(
                credentialsId: 'k8s-staging-deployer-token',
                variable: 'K8S_TOKEN'
            )
        ]) {
            sh '''
                docker run --rm \
                  --network minikube \
                  -e K8S_TOKEN="$K8S_TOKEN" \
                  curlimages/curl \
                  -k -sS --fail \
                  -H "Authorization: Bearer $K8S_TOKEN" \
                  https://192.168.49.2:8443/apis/apps/v1/namespaces/kijani-staging/deployments/kk-payments \
                  >/dev/null

                echo "Kubernetes authentication and staging access verified."
            '''
        }
    }
}
        stage('Deploy to Staging') {
            steps {
                sh '''
                    minikube image load ${APP_NAME}:${IMAGE_TAG}
                    kubectl apply -f k8s/configmap-staging.yaml
                    kubectl apply -f k8s/deployment.yaml -n ${STAGING_NAMESPACE}
                    kubectl apply -f k8s/service.yaml -n ${STAGING_NAMESPACE}
                    kubectl rollout status deployment/${APP_NAME} -n ${STAGING_NAMESPACE} --timeout=120s
                '''
            }
        }

        stage('Staging Smoke Test') {
            steps {
                sh '''
                    kubectl run ${APP_NAME}-smoke \
                      -n ${STAGING_NAMESPACE} \
                      --rm -i \
                      --restart=Never \
                      --image=curlimages/curl \
                      -- curl -fsS http://${APP_NAME}/health
                '''
            }
        }

        stage('Approve Production Deployment') {
            steps {
                input(
                    message: 'Staging smoke test passed. Deploy to production?',
                    ok: 'Deploy',
                    submitter: 'liz'
                )
            }
        }

        stage('Deploy to Production') {
            steps {
                echo 'Production deployment will be implemented after the approval gate is verified.'
            }
        }
    }

    post {
        always {
            echo "Pipeline completed with status: ${currentBuild.currentResult}"
        }

        success {
            echo 'KijaniKiosk delivery pipeline completed successfully.'
        }

        failure {
            echo 'KijaniKiosk delivery pipeline failed before production deployment.'
        }
    }
}
