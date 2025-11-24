# Image scanning

## Exploring the app

This demo repository contains a Hello World Node.js application consisting of a basic JS server and Dockerfile pointing to a Trixie (Debian 13) base image.
The app logic is implemented in the :fileLink[app.js]{path="app.js"} file. 


## Dockerfile

To follow modern best practices, we want to containerize the app and eventually deploy it to production. Before doing so, we must ensure the image is secure by using [Docker Scout](https://www.docker.com/products/docker-scout/)

Our Dockerfile takes a multi-stage build approach and is based on the `node:24-trixie-slim` image.

**Let’s build our image with SBOM and provenance metadata**
This lab already has a :fileLink[Dockerfile]{path="Dockerfile"}, so you can easily build the image.

1. Use the `docker build` command to build the image:
We'll use the buildx command (a Docker CLI plugin that extends the docker build) with the –provenance=true  and –sbom=true flags. These options attach [build attestations](https://docs.docker.com/build/metadata/attestations/) to the image, which Docker Scout uses to provide more detailed and accurate security analysis.

```bash
docker buildx build --provenance=true --sbom=true -t $$orgname$$/demo-node-doi:v1 .
```

2. Now that you have an image let's analyze it.
Use the `docker scout quickview` command to list all discovered vulnerabilities and scout policies alignment:

```bash
docker scout quickview $$orgname$$/demo-node-doi:v1
```
You will see similar output:
```plaintext no-copy-button
 Target      │  orgname/demo-node-doi:v1           │    0C     2H     2M    20L   
    digest   │  771a1b07daa3                       │                              
  Base image │  node:24-trixie-slim                │    0C     1H     2M    20L   

Policy status  FAILED  (6/10 policies met)

  Status │                              Policy                              │           Results            
─────────┼──────────────────────────────────────────────────────────────────┼──────────────────────────────
  ✓      │ AGPL v3 licenses found                                           │    0 packages                
  !      │ No default non-root user found                                   │                              
  ✓      │ No AGPL v3 licenses                                              │    0 packages                
  ✓      │ No embedded secrets                                              │    0 deviations              
  ✓      │ No embedded secrets (Rego)                                       │    0 deviations              
  !      │ Fixable critical or high vulnerabilities found                   │    0C     2H     0M     0L   
  ✓      │ No high-profile vulnerabilities                                  │    0C     0H     0M     0L   
  !      │ Unapproved base images found                                     │    1 deviation               
  ✓      │ Supply chain attestations                                        │    0 deviations              
```
As you can see, there are no CVEs at the application level, but the base image contains a number of high, medium, and low severity CVEs, so it is recommended to be updated. Additionally, the critical policies have failed:

    1. No default non-root user found
    2. Fixable critical or high vulnerabilities found
    3. Unapproved base images found
 
This is where DHI comes into play.

