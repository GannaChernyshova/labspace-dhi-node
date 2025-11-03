# Making the Switch to Docker Hardened Images

Switching to a Docker Hardened Image is straightforward. All we need to do is replace the base image `node:24.9.0-trixie-slim` with a DHI equivalent.

Docker Hardened Images come in two variants:

* Dev variant (`demonstrationorg/dhi-node:24.9.0-debian13-dev`) – includes a shell and package managers, making it suitable for building and testing.
* Runtime variant (`demonstrationorg/dhi-node:24.9.0-debian13`) – stripped down to only the essentials, providing a minimal and secure footprint for production.

This makes them perfect for use in multi-stage Dockerfiles. We can build the app in the dev image, then copy the built application into the runtime image, which will serve as the base for production.

1. Update the `Dockerfile` to use the `demonstrationorg/dhi-node:24.9.0-debian13-dev` as a `dev` satge image and `demonstrationorg/dhi-node:24.9.0-debian13` as a `runtime` image
```dockerfile
FROM demonstrationorg/dhi-node:24.9.0-debian13-dev AS dev
```
```dockerfile
FROM demonstrationorg/dhi-node:24.9.0-debian13 AS prod
```
2. Looking back at the output for the `scout quickview` the `No default non-root user found` policy was not met. To resolve this we tipically need to add a non-root user to the Dockerfile description. The good news is that the DHI comes with nonroot user built-in so no changes should be made.

3. Now Let’s rebuild and scan the new image:
```bash
docker buildx build --provenance=true --sbom=true -t demonstrationorg/demo-node-dhi:v1 .
```
```bash
docker scout quickview demonstrationorg/demo-node-dhi:v1
```
You would see the similar output:
```plaintext no-copy-button
  Target     │  demonstrationorg/demo-node-dhi:v1          │    0C     0H     0M     0L   
    digest   │  cec31e6f0a36                               │                              
  Base image │  demonstrationorg/dhi-node:24.9.0-debian13  │                              

Policy status  SUCCESS  (9/9 policies met)

  Status │                   Policy                    │           Results            
─────────┼─────────────────────────────────────────────┼──────────────────────────────
  ✓      │ AGPL v3 licenses found                      │    0 packages                
  ✓      │ Default non-root user                       │                              
  ✓      │ No AGPL v3 licenses                         │    0 packages                
  ✓      │ No embedded secrets                         │    0 deviations              
  ✓      │ No embedded secrets (Rego)                  │    0 deviations              
  ✓      │ No fixable critical or high vulnerabilities │    0C     0H     0M     0L   
  ✓      │ No high-profile vulnerabilities             │    0C     0H     0M     0L   
  ✓      │ No unapproved base images                   │    0 deviations              
  ✓      │ Supply chain attestations                   │    0 deviations    
```
Hooray! There are zero CVEs and Policy violations now!

**Let’s look at the image size and package count advantages of using distroless Hardened Images.**

Docker Scout offers a helpful command docker scout compare , that allows you to analyze and compare two images. We’ll use it to evaluate the difference in size and package footprint between `node:24.9.0-trixie-slim` and `dhi-node:24.9.0-debian13` based images.
```bash
docker scout compare local://demonstrationorg/demo-node-doi:v2 --to local://demonstrationorg/demo-node-dhi:v1
```
You would see the similar summary in the output:
```plaintext no-copy-button
## Overview
  
                      │               Analyzed Image                │              Comparison Image                
  ────────────────────┼─────────────────────────────────────────────┼──────────────────────────────────────────────
    Target            │  local://demonstrationorg/demo-node-doi:v1  │  local://demonstrationorg/demo-node-dhi:v1   
      digest          │  75eb23bc5d85                               │  e7a47068ccfa                                
      tag             │  v1                                         │  v1                                          
      platform        │ linux/arm64                                 │ linux/arm64                                  
      vulnerabilities │    0C     6H     2M    26L                  │    0C     0H     0M     8L                   
                      │           +6     +2    +18                  │                                              
      size            │ 100 MB (+41 MB)                             │ 59 MB                                        
      packages        │ 901 (+248)                                  │ 653                                          
                      │                                             │                                              
    Base image        │  node:24-trixie-slim                        │  demonstrationorg/dhi-node-smontri:24        
      tags            │ also known as                               │ also known as                                
                      │   • current-trixie-slim                     │                                              
                      │   • trixie-slim                             │                                              
      vulnerabilities │    0C     1H     1M    22L                  │    0C     0H     0M     0L      
```

As you can see, the original `node:24.9.0-trixie-slim` based image is 41 MB larger, has 248 packages more in addition high, medium and low CVEs. While the `dhi-node:24.9.0-debian13` based image is 40 % smaller and has near-zero CVEs. 

**Validate that the app works as expected**

Last but not least, after migrating to a DHI base image, we should verify that the application still functions as expected.

1. To do so, we can either start the app locally with:
```bash
docker run --rm -d --name demo-node -p 3005:3000 demonstrationorg/demo-node-dhi:v1
```
and navigate to :tabLink[This link]{href="http://localhost:3005" title="Web app"} to validate that the app is up and running.

Then stop the container:
```bash
docker stop demo-node
```

2. Or we can run the fuctinal test and build an app from the Dockerfile using Testcontainers library.

[Testcontainers](https://testcontainers.com/cloud/) allows to run the containerized application along with any required services, such as databases, effectively reproducing the local environment needed to test the application at the API or end-to-end (E2E) level.

This simple code block from the `test\app.test.js` allows to start the application under development form the Dockerfile on demand only for the testing phase:
```plaintext no-copy-button
 const builtContainer = await GenericContainer.fromDockerfile('.').build();
 container = await builtContainer
      .withExposedPorts(3000)
      .withWaitStrategy(Wait.forLogMessage(/Example app listening on port \d+/))
      .start();
```
Let’s run the tests using the npm test command:
```bash
npm test
```