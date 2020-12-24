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
                cd $WORKSPACE
                mamba build .'''
            }
        }
    }
}
