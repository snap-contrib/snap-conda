# SNAP as a conda package

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

A package manager is a tool that automates the process of installing, updating, and removing packages. Conda, with its "conda install", "conda update", and "conda remove" sub-commands, falls squarely under this definition. 

Conda is a general-purpose package management system, designed to build and manage software of any type from any language. As such, it also works well with Python packages.

Conda is a language-agnostic cross-platform environment manager that installs any package within conda environments.

This repository provides a conda recipe for packaging SNAP as a conda package.

The goal of SNAP as a conda package is to ease the unattended installation of SNAP and snappy in headless environments such as Linux consoles or docker images. 

This goal is achieved by creating conda packages installing SNAP and snappy, published on a public conda channel.

## Building this recipe

This recipe is built with conda (or mamba) with:

```console
conda build .
```

## Installing SNAP as a conda package

To install SNAP as a conda package on Linux, use conda (or mamba): 

```console
conda install -c terradue -c conda-forge snap=8.0.0
```

## Limitations

SNAP as a conda package can be installed on Linux. For Mac or Windows, we suggest looking at the proposed startegies:

 - https://github.com/snap-contrib/cwl-snap-graph-runner to use CWL and Docker to process GPT graphs
 - https://github.com/snap-contrib/vscode-remote-snap to use Visual Studio Code remote containers to develop SNAP and Snappy based Python applications


