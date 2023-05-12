# Agent Pool Creation Pipeline
**Table of Contents**

- [Agent Pool Creation Pipeline](#agent-pool-creation-pipeline)
  - [About](#about)
  - [Requirements:](#requirements)
  - [Preparation:](#preparation)
  - [Pipelines](#pipelines)
  - [Future improvements:](#future-improvements)

## About

This project contains pipelines to automatically set up a self-hosted agent pool based on the images Microsoft is using for their hosted runners.

[Runner Images](https://raw.githubusercontent.com/actions/runner-images/)

The agent pool created is hosted by the following resources:
- A Virtual Machine Scale Set hosting the agent machines.
- An Azure Compute Gallery hosting the image used by the machines.

## Requirements:
- Resource Group
- Vnet+Subnet

## Preparation:
- Change default parameters
- Add pipeline
- Add PAT variable (alternative)
- Service Connection

## Pipelines
- Prebuilt agent
- Custom agent

## Future improvements:

- Automatic deployment of Resource Group
- Automatic deployment of VNet+Subnet
- Fix keyvault access (remove flag to redeploy)
- Support custom packer projects