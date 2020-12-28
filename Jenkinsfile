environment {
    PATH = "$WORKSPACE/conda/bin:$PATH"
    CONDA_UPLOAD_TOKEN = credentials('terradue-conda')
  }

pipeline {
    agent {
        docker { image 'conda-build:latest' }
    }
    stages {
        stage('Test') {
            steps {
                sh '''#!/usr/bin/env bash
                set -x
                conda build --version
                conda --version

                label=dev

                if [ "$GIT_BRANCH" = "master" ]; then label=main; fi
                echo $label
                exit 1
                '''
            }
        }
        stage('Build') {
            steps {
                sh '''#!/usr/bin/env bash
                mkdir -p /home/jovyan/conda-bld/work
                cd $WORKSPACE
                mamba build .
                '''
            }
        }
        stage('Push') {            
            steps { 
                withCredentials([string(credentialsId: 'terradue-conda', variable: 'ANACONDA_API_TOKEN')]) {
                sh '''#!/usr/bin/env bash
                
                set -x 

                export PACKAGENAME=snap
                
                if $GIT_BRANCH == 'develop'

                label=dev

                if [ "$GIT_BRANCH" = "master" ]; then label=main; fi

                anaconda upload --no-progress --user Terradue --label $label /srv/conda/envs/env_conda/conda-bld/*/$PACKAGENAME-*.tar.bz2
                '''}
            }
        }
    }
}
