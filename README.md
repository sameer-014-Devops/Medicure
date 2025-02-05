# ********* Medicure - Web Application *********

Medicure is a super specialty hospital based in New York, USA and provide world class treatment and surgery including Heart, Liver, Kidney transplants and first robotic surgery center. The chain is owned and managed by Global Health Limited.

The Medicure would centrally like to manage all the doctor’s and patient’s data across the Medicure hospitals in various cities. They have developed an microservice, which offers these services. In order to reduce unnecessary maintenance cost and manual labor, they would like to automate their application build and deployment process using DevOps. They are fine to use any one of the (AWS, Azure, GCP) cloud platform as their primary cloud service provider.

They are facing following problems, because of various technologies involved in the project:

    • Building Complex Monolithic Application is difficult.
    • Manual efforts to test various components/modules of the project
    • Incremental builds are difficult to manage, test and deploy.
    • It was not possible to scale up individual modules independently.
    • Creation of infrastructure and configure it manually is very time consuming
    • Continuous manual monitoring the application is quite challenging.

To implement Continuous Integration & Continuous Deployment using following tools:

    • Git - For version control for tracking changes in the code files
    • Maven - For Continuous Build 
    • Jenkins - For continuous integration and continuous deployment
    • Docker - For deploying containerized applications
    • Ansible - Configuration management tools
    • Terraform - For creation of infrastructure
    • Prometheus and Grafana - For Automated Monitoring and Report Visualization
    • Kubernetes - For Deployment

Solution: 

    • Using Terraform :-
              • Creating New VPC
              • Creating 2 Subnets
              • Creating 5 Security Groups
              • Creating 2 Route Tables
              • Creating 2 Route Tables Associations
              • Creating 4 Elastic Ips
              • Creating 7 Instances
              • Associating Elastic Ips with instance
  
    • Using Ansible :-
              • Configuration of Jenkins Master
              • Configuration of Build Server
              • Configuration of Ansible Controller
              • Configuration of Test-Server (Tomcat)
              • Configuration of Production-Server (Kubernetes)
  
    • Using Jenkins :-
              • Creating a testing pipeline for build, deploy to test server, for testing the web applications
              • Creating a production pipeline for build, deploy to production server deployment to main server
  
    • Using Docker :-
              • Creating and build a Docker image
              • Publishing created Docker image to Docker Repository
  
    • Using Kubernetes :-
              • Pulling Docker image to Production server
              • Creating Minimum 4 replicas
  
    • Using Prometheus & Grafana :- 
              • Monitoring Production-server
            
NOTE: 

    • Before Config Server make sure to make connection between ansible-master/controller to all other nodes... 
    • Enter your aws access_key & secret_key while applying terraform 
    • Make sure to add hosts names in ansible hosts and *.yaml file
