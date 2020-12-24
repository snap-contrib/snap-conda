environment {
    PATH = "$WORKSPACE/conda/bin:$PATH"
  }

pipeline {
    agent any
    stages {
    stage('setup miniconda') {
        steps {
            sh '''#!/usr/bin/env bash
            export MINIFORGE_VERSION=4.8.2-1
            wget --quiet https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh -O /tmp/miniforge-installer.sh
            chmod +x /tmp/miniforge-installer.sh
            bash /tmp/miniforge-installer.sh -b -p $WORKSPACE/conda
            export PATH=$WORKSPACE/conda/bin:$PATH
            $WORKSPACE/conda/bin/conda update --yes conda  # Update CONDA without command line prompt
            source $WORKSPACE/conda/etc/profile.d/conda.sh
            '''
        }
    }
    stage('conda build') {
        steps {
            sh '''#!/usr/bin/env bash
            conda build .
            '''
        }
    }
  }
}

