environment {
    PATH = "$WORKSPACE/miniconda/bin:$PATH"
  }

  stages {
    stage('setup miniconda') {
        steps {
            sh '''#!/usr/bin/env bash
            export MINIFORGE_VERSION=4.8.2-1
            wget https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh -O /tmp/miniforge-installer.sh
            chmod +x /tmp/miniforge-installer.sh
            bash /tmp/miniforge-installer.sh -b -p /home/travis/conda
            export PATH=/home/travis/conda/bin:$PATH
            conda update --yes conda  # Update CONDA without command line prompt
            source $WORKSPACE/miniconda/etc/profile.d/conda.sh
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