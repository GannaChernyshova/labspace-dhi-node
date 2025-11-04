# Image scanning

## Exploring the app

This demo repository contains a Hello World Node.js application consisting of a basic ExpressJS server and Dockerfile pointing to a Trixie (Debian 13) base image.
The app logic is implemented in the :fileLink[app.js]{path="app.js"} file. 


## Dockerfile

To follow modern best practices, we want to containerize the app and eventually deploy it to production. Before doing so, we must ensure the image is secure by using [Docker Scout](https://www.docker.com/products/docker-scout/)

Our Dockerfile takes a multi-stage build approach and is based on the `node:24.9.0-trixie-slim` image.

**Let’s build our image with SBOM and provenance metadata**
This lab already has a :fileLink[Dockerfile]{path="Dockerfile"}, so you can easily build the image.

1. Use the `docker build` command to build the image:
We'll use the buildx command (a Docker CLI plugin that extends the docker build) with the –provenance=true  and –sbom=true flags. These options attach [build attestations](https://docs.docker.com/build/metadata/attestations/) to the image, which Docker Scout uses to provide more detailed and accurate security analysis.

```bash
docker buildx build --provenance=true --sbom=true -t $$orgname$$/demo-node-doi:v1 .
```

2. Now that you have an image let's analyze it.
Use the `docker scout cves` command to list all discovered vulnerabilities:

```bash
docker scout cves $$orgname$$/demo-node-doi:v1
```

After a moment, you will see details about each of the vulnerabilities discovered in the image with a similar summary.

```plaintext no-copy-button
34 vulnerabilities found in 17 packages
  CRITICAL  0   
  HIGH      6   
  MEDIUM    2   
  LOW       26 
```

A couple of things to note about this:

- If you scroll up or search the `pkg:npm/express@4.17.1` - this part of the report is related to the NPM package named `express`, which has version 4.17.1. You should see that the greatest fix version is `4.20.0`
- Another source of HIGH CVEs is a `path-to-regexp 0.1.7`. The `express` package uses it internally and the `path-to-regexp` library is updated to a fixed version in express version `4.21.2`.

3. A next step for a typical developer is to clean up the package.json dependencies by upgrading the version of each dependency to solve for those vulnerabilities.

Update `express` to the recommended (or latest) version by running the following command:

```bash
npm install express@4.21.2
```

4. Build your image again by running the following command:
```bash
docker buildx build --provenance=true --sbom=true -t $$orgname$$/demo-node-doi:v2 .
```

5. And run one more analysis on the image.
You can now analyze the image with the `docker scout quickview` command:

```bash
docker scout quickview $$orgname$$/demo-node-doi:v2
```
You will see similar output:
```plaintext no-copy-button
Target     │  $$orgname$$/demo-node-doi:v2       │    0C     1H     1M    22L   
  digest   │  48bd36fe1f0b                       │                              
Base image │  node:24.9.0-trixie-slim            │    0C     1H     1M    22L   

Policy status  FAILED  (6/9 policies met)

  Status │                     Policy                     │           Results            
─────────┼────────────────────────────────────────────────┼──────────────────────────────
  ✓      │ AGPL v3 licenses found                         │    0 packages                
  !      │ No default non-root user found                 │                              
  ✓      │ No AGPL v3 licenses                            │    0 packages                
  ✓      │ No embedded secrets                            │    0 deviations              
  ✓      │ No embedded secrets (Rego)                     │    0 deviations              
  !      │ Fixable critical or high vulnerabilities found │    0C     1H     0M     0L   
  ✓      │ No high-profile vulnerabilities                │    0C     0H     0M     0L   
  !      │ Unapproved base images found                   │    1 deviation               
  ✓      │ Supply chain attestations                      │    0 deviations        
      
```

Hooray! No more critical or high CVEs on the application level!
But there are still a few on the base image level. And the critical policies have failed:

    1. No default non-root user found
    2. Fixable critical or high vulnerabilities found
    3. Unapproved base images found
 This is where DHI comes into play.

