# FIXES.md

Document every issue you find and fix in this file.

---

## For DockerFile

### Fix 1: [Layer Caching]

**What was wrong:**
Earlier, you were Copying all files before installing dependencies.

**Why it is a problem:**
Docker builds images in layers. If you change a single line of code in app.py, Docker thinks the whole copy layer is new and re-downloads every library in your requirements.txt. This makes your CI/CD pipeline slow.

**How I fixed it:**
I copy only the dependency files first. Since these change rarely, Docker "caches" the expensive install step. Your builds will now take seconds instead of minutes.

**What could go wrong if left unfixed:**
Every single line changed in code, Docker will take it as new and re downloads every library again which will make our pipeline slow.

---

### Fix 2: [Root User Security]

**What was wrong:**
Letting the application run with full administrative (root) privileges inside the container.

**Why it is a problem:**
If a hacker finds a vulnerability in your app, they can own the container as root. From there, it is much easier for them to break out of the container and attack your AWS EC2 host.

**How I fixed it:**
we created a restricted user (kain). If the app gets hacked, the attacker is stuck in a locked room with no keys to the rest of the system, since this user has limited access.

**What could go wrong if left unfixed:**
Any hacker if get access can owns the container as root user and may attack the AWS EC2 host.

---

## For Docker-compose File

### Fix 1: [Service B unable to reach Service A at localhost]

**What was wrong:**
Service B was trying to find Service A at localhost.

**Why it is a problem:**
When Service B calls localhost:5000, it is looking for the API inside itself. It will fail with a "Connection Refused" error every single time, since it is looking inside it only.

**How I fixed it:**
We used the service name service-a in the SERVICE_A_URL.

**What could go wrong if left unfixed:**
Service B will not be able to reach Service A and connection gets failed.

---

### Fix 2: [Secrets Management]

**What was wrong:**
Sensitive credentials like DB_PASSWORD were written in plain text directly inside the docker-compose file.

**Why it is a problem:**
If you push this file to GitHub, Anyone with access to the repository can see your DB credentials, which is a security threat.

**How I fixed it:**
We replaced the hardcoded value with a variable: ${SECRET_KEY}. This allows Docker to pull the actual value from the host's environment or a protected .env file that is never committed to Git.

**What could go wrong if left unfixed:**
If this isn't fixed, anyone with repository access can access the DB password and your security credentials will get compromised.

---

## For Terraform

### Fix 1: [Credentials Management]

**What was wrong:**
access_key and secret_key were hardcoded directly in the provider "aws" block.

**Why it is a problem:**
Doing so will get our AWS credentials compromised due to which any hacker will get our aws access and might misuse our aws resources, leaving you with massive bill and a compromised environment.

**How I fixed it:**
By leaving the provider block empty, Terraform automatically looks for credentials in your environment variables or local AWS CLI configuration (aws configure), which is the professional standard.

**What could go wrong if left unfixed:**
If you push that code to a public (or even private) Git repository, bots will find those keys in seconds. They will spin up expensive resources, leaving you with a massive bill and a compromised environment.

---

### Fix 2: [Excess Security Group Rules]

**What was wrong:**
You opened ports 0 to 65535 for 0.0.0.0/0 that is for every port in existence.

**Why it is a problem:**
This is a security concern. Every port is open for all now.

**How I fixed it:**
We applied the Principle of Least Privilege. We only opened the "doors" that are absolutely necessary for the app to function i.e. 5000.

**What could go wrong if left unfixed:**
Any hacker can try to attack any service running on your server, even those you didn't mean to expose.

---

### Fix 3: [Added variables.tf]

**What was wrong:**
You didn't have a separate variables file. Everything is configured as hardcoded.

**Why it is a problem:**
Hardcoding values inside main.tf makes the code difficult to reuse. If you wanted to deploy to a different region or change the instance size, you’d have to change the main.tf line again.

**How I fixed it:**
By separating the Variables from the Main.tf, your code becomes a "template." You can now change the entire behavior of the infrastructure by just updating a single variable file.

**What could go wrong if left unfixed:**
If you wanted to deploy to a different region or change the instance size, you’d have to change the main.tf line again and again for every change.

---

## For Kubernetes

### Fix 1: [Image tagging Strategy]

**What was wrong:**
Earlier you were using same latest image tag, which will fail if image 

**Why it is a problem:**
The latest tag is a moving target. If you deploy latest today and again tomorrow, you have no way to know which version of the code is actually running. Furthermore, you cannot "Roll Back" to a previous version if a bug is found because both the "good" and "bad" versions are named latest.

**How I fixed it:**
We now use the GitHub Commit SHA. This creates an immutable link between your code in Git and the container in your cluster, making rollbacks as simple as changing the ID.

**What could go wrong if left unfixed:**
It will become hard to troubleshoot any failed and success build. If you deploy latest today and again tomorrow, you have no way to know which version of the code is actually running.

---

### Fix 2: [Resource Management]

**What was wrong:**
Only basic requests are allocated for memory and CPU.

**Why it is a problem:**
Without limits, a memory leak in Service A could grow whic can lead to OOMKilled issue in production.

**How I fixed it:**
Added hard limits. If Service A tries to use more than 128Mi of RAM, Kubernetes will kill it before it can damage the rest of the cluster.

**What could go wrong if left unfixed:**
Without limits, a memory leak in Service A could grow until it consumes all the RAM on the entire worker node, crashing other critical services or the node itself.

---

## For GitHub Action

### Fix 1: [SSH ]

**What was wrong:**
You used ssh to manually log in and run commands like docker pull and docker restart.

**Why it is a problem:**
With SSH, if the connection drops halfway through, your server might be left in a "broken" state. If the server IP changes, your script fails entirely.

**How I fixed it:**
We use APIs. Terraform and Kubernetes are "smart" agents. You give them the configuration file, and they handle the heavy lifting. If a connection drops, they simply retry until the cluster matches your file.

**What could go wrong if left unfixed:**
With SSH, if the connection drops halfway through, your server might be left in a "broken" state. If the server IP changes, your script fails entirely.

---

### Fix 2: [Image versioning]

**What was wrong:**
You were pushing and pulling the latest tag.

**Why it is a problem:**
It doesn't tell you when the code was built or what features are inside.

**How I fixed it:**
By using the Git SHA, every single deployment has a unique "fingerprint." This allows for Instant Rollbacks. If version C3D4 failed, you just tell Kubernetes to run version A1B2 from ten minutes ago.

**What could go wrong if left unfixed:**
If a deployment fails, you can't easily "go back" because you've already overwritten the latest image with the broken one.

---

### Fix 3: [Secrets Handling]

**What was wrong:**
You had credentials stored in plain text or were passing them through insecure SSH sessions.

**Why it is a problem:**
In Git history, these credentials are visible to everyone.

**How I fixed it:**
We used GitHub Secrets, as they are encrypted and never shown in logs. By injecting them only during the "Run" phase, we keep your AWS and Docker Hub accounts locked tight.

**What could go wrong if left unfixed:**
Once credentials are in your Git history, they are effectively public property and anyone having access can use it.

---


## Self-initiated Improvements

### Improvement 1:
For DockerFiles, I have switche to Multi-staged dockerfiles. We use a Builder stage to compile and install things, then we copy only the final binaries into a Slim runner stage. The final image is 70% smaller and much more secure. This makes the image size small and build time fast.

### Improvement 2:
For Docker-compose, i have added a healthcheck to Service A that pings the /health endpoint. We then told Service B to wait until Service A is specifically healthy, ensuring Service B only starts polling when the API is truly ready to respond.

### Improvement 3:
For Terraform, I have added backend s3 configuration for state locking. Without locking, two people running Terraform at once will corrupt the state file. We used the 2026 standard for S3 Native State Locking, which provides a "shared source of truth" and prevents simultaneous edits without needing a separate DynamoDB table.

### Improvement 4:
For Kubernetes manifests, i have added livenessProbe and readinessProbe hitting the /health endpoint. The Readiness Probe will keep checking if the app is ready to serve live traffic while The Liveness Probe will keep checking if the app is ready or live or it needs to restart.

### Improvement 5:
For GitHub Action workspace, we have included the GitHub Secrets to enhance security. By injecting them only during the "Run" phase, we keep your AWS and Docker Hub accounts locked tight.


---