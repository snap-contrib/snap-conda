environment {
    PATH = "$WORKSPACE/conda/bin:$PATH"
  }

pipeline {
    agent {
        docker { image 'conda-build:latest' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'conda --version'
            }
        }
        stage('Build') {
            steps {
                sh '''#!/usr/bin/env bash
                set -x
                mkdir -p /home/jovyan/conda-bld/work
                cd $WORKSPACE
                mamba build .
                '''
            }
        }
        stage('Push') {
            steps {
                sh '''#!/usr/bin/env bash
                export PACKAGENAME=snap
                export ANACONDA_API_TOKEN=$CONDA_UPLOAD_TOKEN
                anaconda upload --user eoepca /srv/conda/envs/env_conda/conda-bld/*/$PACKAGENAME-*.tar.bz2
                '''
            }
        }
    }
}
