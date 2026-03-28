# CI/CD Pipeline -- Step-by-Step Documentation

---

## 1. Created a Custom Docker Network

All CI/CD containers (Jenkins, SonarQube, Java builders) are placed on a shared bridge network called `cicd-network`. This allows containers to discover each other by name -- for example, Jenkins reaches SonarQube at `http://sonarqube:9000` instead of needing an IP address.

```bash
docker network create cicd-network
```

**Attach:** Screenshot of `docker network ls` showing `cicd-network`.

---

## 2. Started Jenkins in Docker

Jenkins is the pipeline orchestrator. It runs as a container with the Docker socket mounted so it can build images on the host.

```bash
docker run -d --name jenkins --network cicd-network \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

**Worth noting:** The `-v /var/run/docker.sock` mount is what gives Jenkins the ability to run `docker build` and `docker push` commands from inside its own container.

After startup, the initial admin password is retrieved with:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Four plugins were installed: **Pipeline**, **SonarQube Scanner**, **Docker Pipeline**, and **Kubernetes Continuous Deploy**.

**Attach:** Screenshot of the Jenkins dashboard at `http://localhost:8080` and the installed plugins page.

---

## 3. Started SonarQube in Docker

SonarQube provides static code analysis. It runs on the same network so Jenkins can reach it.

```bash
docker run -d --name sonarqube --network cicd-network -p 9000:9000 sonarqube
```

After logging in (`admin`/`admin`), a security token was generated under **My Account > Security > Generate Token**. This token is stored as a Jenkins credential so the pipeline can authenticate.

**Attach:** Screenshot of the SonarQube dashboard at `http://localhost:9000` and the token generation page.

---

## 4. Created Three Java Environment Containers

Three containers simulate different Java environments used by different pipeline stages:

| Container | Image | Pipeline Stage |
|---|---|---|
| `java17-builder` | `openjdk:17` | Build (compile) |
| `java11-tester` | `openjdk:11` | Test (JUnit) |
| `java8-analyzer` | `openjdk:8` | SonarQube analysis |

```bash
docker run -dit --name java17-builder --network cicd-network openjdk:17
docker run -dit --name java11-tester  --network cicd-network openjdk:11
docker run -dit --name java8-analyzer --network cicd-network openjdk:8
```

**Attach:** Screenshot of `docker ps` showing all five running containers.

---

## 5. Set Up Kubernetes with Minikube

Minikube provides a local single-node Kubernetes cluster for deployment.

```bash
minikube start
kubectl get nodes
```

**Attach:** Screenshot of `kubectl get nodes` showing minikube in `Ready` status.

---

## 6. Built the Java Application

A minimal Maven-based HTTP server was created. The application has a `greet()` method that returns a greeting string, and a `main()` method that starts an HTTP server on port 8080. It uses only JDK built-in classes (`com.sun.net.httpserver`), so no external runtime dependencies are needed.

Five JUnit 5 tests cover the `greet()` logic -- normal input, null, empty string, blank string, and class instantiation.

**Worth noting:** The `pom.xml` includes four key plugins -- `maven-compiler-plugin` (Java 17), `maven-surefire-plugin` (test runner), `maven-jar-plugin` (with main class manifest), and `sonar-maven-plugin` (code analysis).

**Attach:** `src/main/java/com/example/App.java`, `src/test/java/com/example/AppTest.java`, and `pom.xml`.

---

## 7. Created the Dockerfile (Multi-Stage Build)

The Dockerfile uses two stages to keep the final image small (~180MB):

1. **Build stage** -- uses `maven:3.9-eclipse-temurin-17` to compile and package the JAR
2. **Runtime stage** -- uses `eclipse-temurin:17-jre-alpine` to run it

**Worth noting:** The build tools (~800MB) are discarded after the first stage. Only the JAR is copied into the lightweight Alpine-based runtime image.

**Attach:** `Dockerfile`.

---

## 8. Created the Kubernetes Deployment Manifest

`deployment.yaml` defines two resources:

- A **Deployment** with 2 replicas of the Java app
- A **Service** of type `NodePort` that routes external traffic on port 30080 to the container's port 8080

**Worth noting:** `NodePort` was chosen so the app is accessible from outside the cluster without needing a load balancer, which suits a local Minikube environment.

**Attach:** `deployment.yaml` and screenshot of `kubectl get pods` showing 2 running pods.

---

## 9. Created the Jenkinsfile (Pipeline Definition)

The Jenkinsfile defines seven stages that run sequentially:

1. **Checkout Code** -- clones the repo from GitHub
2. **Build with Java 17** -- runs `mvn clean compile` inside `java17-builder`
3. **Test with Java 11** -- runs `mvn test` inside `java11-tester`
4. **SonarQube Analysis with Java 8** -- runs `mvn sonar:sonar` inside `java8-analyzer`
5. **Build Docker Image** -- builds and tags the image using the Dockerfile
6. **Push to Docker Hub** -- authenticates and pushes the image
7. **Deploy to Kubernetes** -- applies `deployment.yaml` and waits for rollout

**Worth noting:** Each Java stage uses `docker exec` to run Maven commands inside the respective container, simulating real-world environments where build, test, and analysis happen on different JDK versions. The `withCredentials` and `withSonarQubeEnv` blocks ensure secrets are never exposed in logs.

**Attach:** `Jenkinsfile` and screenshot of the Jenkins pipeline stage view showing all 7 stages.

---

## 10. Ran the Pipeline in Jenkins

A new Pipeline job was created in Jenkins:

1. **New Item** > named it > selected **Pipeline**
2. Set definition to **Pipeline script from SCM**
3. Entered the GitHub repository URL and branch `main`
4. Script path set to `Jenkinsfile`
5. Clicked **Save** then **Build Now**

**Attach:** Screenshot of the successful pipeline build (stage view with all stages green) and the console output.

---

## Summary of Files to Attach Per Step

| Step | Files / Screenshots |
|---|---|
| 1. Docker Network | `docker network ls` screenshot |
| 2. Jenkins | Jenkins dashboard screenshot, plugins page |
| 3. SonarQube | SonarQube dashboard screenshot, token page |
| 4. Java Containers | `docker ps` screenshot showing all containers |
| 5. Kubernetes | `kubectl get nodes` screenshot |
| 6. Java App | `App.java`, `AppTest.java`, `pom.xml` |
| 7. Dockerfile | `Dockerfile` |
| 8. K8s Manifest | `deployment.yaml`, `kubectl get pods` screenshot |
| 9. Jenkinsfile | `Jenkinsfile` |
| 10. Pipeline Run | Jenkins stage view screenshot, console output |
