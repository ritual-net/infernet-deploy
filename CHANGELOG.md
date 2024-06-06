# Changelog

All notable changes to this project will be documented in this file.

- ##### The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
- ##### This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - UNRELEASED

### Added
- Support for multi-region, multi-zone deployments in GCP.
- Support for multi-zone deployments in AWS. Since multi-region deployments require
separate provider blocks, we don't allow multiple regions to avoid increased repo complexity.
- Support for GPUs on GCP (via the terraform `accelerator` block) and AWS. Includes driver installation script
and a gpu-specific `docker-compose.yaml` file to expose GPUs to the node container for diagnostics.
- Terraform formatter in pipeline and README.

### Changed
- Format of node specification in `.tfvars`. Nodes are now specified via a map (see `variables.tf`) where keys correspond to node IDs.
- Format of router specification in `.tfvars`. Router is now specified via a map (see `variables.tf`).
- Naming conventions for configuration `.json` files. One file per deployed node, names (without `.json` postfix) matching the node IDs (keys of `nodes` from `variables.tf`), are now the only requirements.

### Fixed
- All created resources are now parametrized by cluster name, so no conflicts arise from successive deployments within the same project.
- Omissions in Makefile.

## [0.1.0] - 2024-01-18

### Added
- Initial release of Infernet Deploy.
