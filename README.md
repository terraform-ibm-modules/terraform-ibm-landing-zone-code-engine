<!-- Update this title with a descriptive name. Use sentence case. -->
# Terraform Landing zone for serverless workloads with IBM Code Engine

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-landing-zone-code-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-code-engine/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)


This deployment architecture provisions an IBM Cloud Code Engine environment designed for scalable, serverless compute workloads. It automates the setup of Code Engine projects along with supporting services such as IBM VPC and Cloud Object Storage (COS), enabling high-performance tasks like Monte Carlo simulations, PDF conversion with Doclin, and batch data processing.

This architecture supports end-to-end deployment, from infrastructure provisioning to workload execution. Thus it provides a robust foundation for experimentation, development, or production-grade serverless computing on IBM Cloud.

This repository contains the following deployable architectures:
- [Landing zone for serverless workloads with IBM Code Engine (Experimental Standard Setup with Configurable Services)](./solutions/fully-configurable)
- [Landing zone for serverless workloads with IBM Code Engine (Quickstart - Fleets Edition)](./solutions/fleets-quickstart)


:exclamation: **Important:** These solutions are not intended to be called by other modules because they contain provider configurations and are not compatible with the `for_each`, `count`, and `depends_on` Terraform arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
