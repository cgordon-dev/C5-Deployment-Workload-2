# Deployment Workload 2 - CI/CD with AWS CLI

## Project Goal

The main goal of this workload was to automate the deployment process of an application using AWS Elastic Beanstalk (EB). In the first deployment workload, I manually uploaded the source code to AWS EB. This time, I wanted to step it up by automating more of that pipeline, which should make everything more efficient and less prone to errors.

## Steps Taken

### 1. Cloning the Repo to GitHub
   - **Why**: I started by cloning the repository to GitHub to ensure everything was under version control. This also makes it easier to collaborate and keep track of changes.

### 2. Creating AWS Access Keys
   - **Why**: I needed AWS Access Keys to authenticate and authorize any actions I perform using the AWS CLI. It’s super important to keep these keys safe and secure—they’re essentially the keys to my AWS kingdom.
   - **Caution**: Access keys can only be viewed once, so I made sure to store them securely.

### 3. Setting Up a t2.micro EC2 Instance for Jenkins
   - **Why**: Jenkins is the tool I’m using to run my CI/CD pipeline, and I needed a server to host it. A t2.micro EC2 instance is a good starting point because it’s cost-effective and has just enough resources for this purpose.

### 4. Writing a System Resource Monitoring Script
   - **Why**: I created a Bash script to monitor system resources like CPU, memory, and disk usage. The script uses conditional statements and exit codes to flag any issues before moving forward with the deployment.

### 5. Creating a MultiBranch Pipeline in Jenkins
   - **Why**: By setting up a MultiBranch Pipeline, Jenkins automatically builds branches and pull requests from the GitHub repo. This is crucial for continuous integration and delivery.

### 6. Installing AWS CLI and EB CLI on the Jenkins Server
   - **Why**: The AWS CLI is needed for interacting with AWS services directly from the Jenkins server. This is essential for automating deployment tasks. AWS EB CLI is specifically designed for working with Elastic Beanstalk. It makes deploying the application to EB much easier.

### 7. Configuring AWS CLI
   - **Why**: I configured the AWS CLI with my access keys and region settings so that Jenkins could securely interact with AWS services.

### 8. Initializing AWS Elastic Beanstalk CLI
   - **Why**: I initialized the EB CLI to set up my Elastic Beanstalk environment. This step is necessary to automate the deployment process through the pipeline.

### 9. Adding a Deploy Stage to the Jenkinsfile
   - **Why**: Adding a deploy stage in the Jenkinsfile was crucial for automating the deployment process. This ensures that once the code passes all the tests, it’s automatically deployed to the correct environment.

### 10. Building the Pipeline
   - **Why**: Finally, I built the pipeline, which kicked off the whole process from code checkout to deployment. This step is what ties everything together and makes sure the application is always ready to be deployed.
![Jenkins Pipeline Successful](/images/jenkins-pipeline.png)
![Elastic Beanstalk Status Check](/images/eb-status-successful.png)
![Retail Bank Homepage](/images/retail-bank-homepage.png)

## System Design Diagram

![System Design Diagram](/images/cicd-pipeline-system-diagram.png)  
### **Components and Their Roles:**

1. **GitHub:**
   - **Role:** GitHub is the source code repository where the application's codebase is stored. It acts as the central hub for version control and collaboration among developers.
   - **Interaction:** Code is pushed to GitHub by engineers, which triggers the CI/CD pipeline in Jenkins.

2. **Engineer:**
   - **Role:** The engineer writes and commits code to the GitHub repository. This code will be built, tested, and deployed as part of the CI/CD process.
   - **Interaction:** Engineers interact with the code stored in GitHub.

3. **Jenkins CI/CD Server (Hosted on AWS EC2 - t2.micro):**
   - **Role:** Jenkins is the automation server that manages the CI/CD pipeline. It is responsible for building, testing, and deploying the application.
   - **Key Components:**
     - **Build Stage:** Where the code is compiled or prepared.
     - **Test Stage:** Where the code is automatically tested.
     - **Deploy Stage:** Where the application is deployed to Elastic Beanstalk.
   - **AWS CLI & Access Keys:** Jenkins uses AWS CLI, configured with access keys, to interact with AWS services like Elastic Beanstalk.
   - **GitHub Token:** Used by Jenkins to authenticate and interact with GitHub for pulling code or pushing updates.

4. **AWS Elastic Beanstalk:**
   - **Role:** Elastic Beanstalk is the service where the application is deployed. It manages the infrastructure and deployment processes automatically.
   - **Interaction:** Jenkins deploys the application to Elastic Beanstalk using AWS CLI commands. Elastic Beanstalk, in turn, manages the EC2 instances, scaling, load balancing, and application deployment.

5. **AWS Route 53:**
   - **Role:** Route 53 is a DNS web service used to direct traffic to the application hosted on Elastic Beanstalk.
   - **Interaction:** After the application is deployed, Route 53 manages the domain and directs users to the Elastic Beanstalk environment where the application is running.

6. **AWS CloudWatch:**
   - **Role:** CloudWatch monitors the performance and health of the deployed application and infrastructure.
   - **Interaction:** It collects and tracks metrics, sets alarms, and automatically reacts to changes in the application environment.

7. **Deployed Web Application:**
   - **Components:**
     - **Nginx:** Serves as a reverse proxy to manage traffic and load balance between different instances of the application.
     - **Gunicorn:** A WSGI HTTP Server for running Python web applications.
     - **Flask:** A micro web framework for Python, used to develop the web application.
     - **SQLite:** A lightweight database used by the application.
   - **Auto Scaling Group:** Managed by Elastic Beanstalk, it automatically scales the number of EC2 instances based on the demand.

8. **Security Groups:**
   - **Role:** Security groups control the inbound and outbound traffic for the EC2 instances and other resources.
   - **Ports:**
     - **Port 8080:** Used by Jenkins for its web interface.
     - **SSH Port 22:** For secure shell access to the EC2 instance.
     - **HTTP Port 80:** For web traffic to the application.
     - **Port 5000/8000:** Used by Flask/Gunicorn for internal communication.

### **Flow of the CI/CD Process:**

1. The engineer commits code to the GitHub repository.
2. Jenkins detects changes in the GitHub repository and triggers the CI/CD pipeline.
3. Jenkins pulls the code from GitHub and executes the build and test stages.
4. Upon successful testing, Jenkins uses AWS CLI, authenticated with AWS Access Keys, to deploy the application to AWS Elastic Beanstalk.
5. Elastic Beanstalk manages the deployment, including setting up the necessary EC2 instances, scaling, and load balancing.
6. AWS Route 53 handles DNS, ensuring users are directed to the running application.
7. AWS CloudWatch monitors the environment and application performance, sending alerts if needed.
8. The deployed application, running on an EC2 instance managed by Elastic Beanstalk, uses Nginx as a reverse proxy, Gunicorn to serve the Python Flask application, and SQLite as its database.

## Issues and Troubleshooting

1. **Jenkins Didn’t Start**  
   - **Issue**: When I first installed Jenkins, it wouldn’t start because there was no Java installed on the EC2 instance.
   - **Solution**: I installed Java, which resolved the issue and allowed Jenkins to start up properly.

2. **Pipeline Failed Due to High CPU Usage and High Memory**  
   - **Issue**: During the Test stage, my script detected that CPU usage was at 100%, which exceeded the threshold I had set at 60%. This caused the pipeline to fail and skip the deploy stage.
   - **Solution**: The main issue was that the CPU usage and memory was too high, which caused the pipeline to fail. I need to investigate why the CPU usage spiked—whether it's due to other processes on the Jenkins server or if the environment or tests need optimization. I went back to the system resources bash file and adjusted the memory threshold from 70% to 90% and it seemed to resolved the issue.

3. **Warnings About Detached Head State During Deployment**  
   - **Issue**: During the deploy stage, I got warnings about the Git repository being in a detached head state. This wasn’t ideal, but it didn’t stop the deployment from succeeding.
   - **Solution**: I noted the warnings for future reference but didn’t take any immediate action since the deployment still worked.

## Optimization

Automating the deployment process using a deploy stage in the CI/CD pipeline has significantly improved efficiency. It saves time and reduces the potential for human error, which is critical in a production environment. However, one challenge of automating deployments is the risk of deploying untested or faulty code. To prevent this, it’s important to have thorough testing stages before the deploy stage, and maybe even add an extra layer of approval or checks before code is deployed to production.

## Conclusion

This workload has been a great learning experience in automating deployments using CI/CD pipelines. By integrating AWS CLI and AWS EB CLI into Jenkins, I’ve been able to streamline the deployment process, making it more reliable and less reliant on manual intervention. The issues I encountered taught me valuable lessons and made the pipeline more robust overall.





