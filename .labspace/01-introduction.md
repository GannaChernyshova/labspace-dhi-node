# Introduction

👋 Welcome to the **Docker Hardened Images** lab! This lab outlines the benefits of Docker Hardened Images and walks you through the migration process for the Node application.

## First thing to get started, please provide your Docker org name

::variableDefinition[orgname]{prompt="What is your Docker org name?"}

## Docker Hardened Images are Secure, Minimal, Production-Ready Images with near-zero CVEs and enterprise-grade SLA for rapid remediation. 

These images follow a distroless philosophy, removing unnecessary components to significantly reduce the attack surface. The result? Smaller images that pull faster, run leaner, and provide a secure-by-default foundation for production workloads:

- **Near-zero exploitable CVEs:** Continuously updated, vulnerability-scanned, and published with signed attestations to minimize patch fatigue and eliminate false positives.
- **Seamless migration:** Drop-in replacements for popular base images, with -dev variants available for multi-stage builds.
- **Up to 95% smaller attack surface:** Unlike traditional base images that include full OS stacks with shells and package managers, distroless images retain only the essentials needed to run your app.
- **Built-in supply chain security:** Each image includes signed SBOMs, VEX documents, and SLSA provenance for audit-ready pipelines.


[Docker Hardened Images](https://www.docker.com/products/hardened-images/) lists the enterprise-ready, secure container images with built-in compliance and minimal vulnerabilities.


