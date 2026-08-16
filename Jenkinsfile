pipeline {
    agent any

    environment {
        APP_NAME = 'kk-payments'
        STAGING_NAMESPACE = 'kijani-staging'
        IMAGE_TAG = '1.0.0'
        MINIKUBE_IP = '192.168.49.2'
        KUBECTL_IMAGE = 'alpine/kubectl:1.36.3'
    }

    stages {

        stage('Build and Lint') {
            steps {
                sh '''
                    docker run --rm \
                      --volumes-from jenkins \
                      -w "$WORKSPACE/app/kk-payments" \
                      node:20-alpine \
                      sh -c "npm ci && npm run lint"
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker run --rm \
                      --volumes-from jenkins \
                      -w "$WORKSPACE/app/kk-payments" \
                      node:20-alpine \
                      npm test
                '''
            }
        }

        stage('Build Container') {
            steps {
                dir('app/kk-payments') {
                    sh '''
                        docker build \
                          -t ${APP_NAME}:${IMAGE_TAG} \
                          .
                    '''
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
                          "https://${MINIKUBE_IP}:8443/apis/apps/v1/namespaces/${STAGING_NAMESPACE}/deployments/${APP_NAME}" \
                          >/dev/null

                        echo "Kubernetes authentication and staging access verified."
                    '''
                }
            }
        }

        stage('Load Image into Minikube') {
            steps {
                sh '''
                    echo "Loading ${APP_NAME}:${IMAGE_TAG} into Minikube..."

                    docker save ${APP_NAME}:${IMAGE_TAG} | \
                      docker exec -i minikube docker load

                    echo "Image loaded into Minikube."
                '''
            }
        }

        stage('Deploy to Staging') {
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
                          -v "$PWD/k8s:/k8s:ro" \
                          ${KUBECTL_IMAGE} \
                          --server=https://${MINIKUBE_IP}:8443 \
                          --token="$K8S_TOKEN" \
                          --insecure-skip-tls-verify=true \
                          apply -f /k8s/configmap-staging.yaml

                        docker run --rm \
                          --network minikube \
                          -e K8S_TOKEN="$K8S_TOKEN" \
                          -v "$PWD/k8s:/k8s:ro" \
                          ${KUBECTL_IMAGE} \
                          --server=https://${MINIKUBE_IP}:8443 \
                          --token="$K8S_TOKEN" \
                          --insecure-skip-tls-verify=true \
                          apply -f /k8s/deployment.yaml \
                          -n ${STAGING_NAMESPACE}

                        docker run --rm \
                          --network minikube \
                          -e K8S_TOKEN="$K8S_TOKEN" \
                          -v "$PWD/k8s:/k8s:ro" \
                          ${KUBECTL_IMAGE} \
                          --server=https://${MINIKUBE_IP}:8443 \
                          --token="$K8S_TOKEN" \
                          --insecure-skip-tls-verify=true \
                          apply -f /k8s/service.yaml \
                          -n ${STAGING_NAMESPACE}

                        docker run --rm \
                          --network minikube \
                          -e K8S_TOKEN="$K8S_TOKEN" \
                          ${KUBECTL_IMAGE} \
                          --server=https://${MINIKUBE_IP}:8443 \
                          --token="$K8S_TOKEN" \
                          --insecure-skip-tls-verify=true \
                          rollout status \
                          deployment/${APP_NAME} \
                          -n ${STAGING_NAMESPACE} \
                          --timeout=120s
                    '''
                }
            }
        }

        stage('Staging Smoke Test') {
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
                          ${KUBECTL_IMAGE} \
                          --server=https://${MINIKUBE_IP}:8443 \
                          --token="$K8S_TOKEN" \
                          --insecure-skip-tls-verify=true \
                          run ${APP_NAME}-smoke \
                          -n ${STAGING_NAMESPACE} \
                          --rm \
                          -i \
                          --restart=Never \
                          --image=curlimages/curl \
                          -- \
                          curl -fsS http://${APP_NAME}/health
                    '''
                }
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
