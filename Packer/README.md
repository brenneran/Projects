# Packer creation AMI of AWS

## Overview

This repository contains Packer configurations written in HashiCorp Configuration Language (HCL) for building custom machine images.

## Prerequisites

Before you begin, ensure you have the following tools installed:

- [Packer](https://www.packer.io/downloads)

## Packer documentation

You can find [the documentation here](https://developer.hashicorp.com/packer/docs)

## Getting Started

```bash
git clone git@github.com:brenneran/Projects.git
cd your-repo
```

## Packer validation

```bash
packer validate template.pkr.hcl
```

## Packer build

```bash
packer build template.pkr.hcl
```


