<!-- Update this title with a descriptive name. Use sentence case. -->
# Terraform Landing Zone Code Engine Deployable Architectures

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-landing-zone-code-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-code-engine/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

This deployment architecture provisions an IBM Cloud Code Engine environment designed for scalable, serverless compute workloads. It automates the setup of Code Engine projects along with supporting services such as IBM VPC and Cloud Object Storage (COS), enabling high-performance tasks like Monte Carlo simulations, PDF conversion with Doclin, and batch data processing.

The architecture supports end-to-end deployment, from infrastructure provisioning to workload execution, providing a robust foundation for experimentation, development, or production-grade serverless computing on IBM Cloud.

This repository contains the following sample deployable architectures:
- [Landing Zone Code Engine Fleets Deployable Architecture](./solutions/fleets)
- [Sample terraform-based deployable architecture with dependencies (extension) - Serving static websites with IBM Cloud Object Storage](./solutions/tf-extension-da)

:exclamation: **Important:** These solutions are not intended to be called by other modules because they contain provider configurations and are not compatible with the `for_each`, `count`, and `depends_on` Terraform arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

The repository is also configured with the following things:
- [A GitHub Actions workflow to run the common CI pipeline for Terraform](./.github/workflows). For more information, see the common-pipeline-assets [readme file](https://github.com/terraform-ibm-modules/common-pipeline-assets/blob/main/README.md)).
- A [common-dev-assets](./common-dev-assets) Git submodule with common automation that is used for CI and development. For more information, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup)).
- An [ibm_catalog.json](ibm_catalog.json) file that is used for onboarding the sample deployable architectures to the IBM Cloud catalog.
- A [.catalog-onboard-pipeline.yaml](.catalog-onboard-pipeline.yaml) file that is used by an IBM internal pipeline to onboard deployable architectures to the IBM catalog.
- A [renovate.json](renovate.json) file that supports automatic creation of PRs to update dependencies. The Renovate pipeline runs regularly against all repos in the [terraform-ibm-modules](https://github.com/terraform-ibm-modules) org.

<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-landing-zone-code-engine

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
