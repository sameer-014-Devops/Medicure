/* NOTE: Make sure add the variables at node levels

#Variable
  App_Name = medicure
  Container_Name = ${User_Name}-${App_Name}-container
  Default_Ver = 1.0.1
  Deploy_Name = ${User_Name}-${App_Name}-deploy
  KubeM_Pvt_IP =
  KubeW01_Pub_IP =
  KubeW02_Pub_IP =
  Prod_Workspace = /home/${User_Name}/workspace/Medicure_Production_Pipeline
  Build01_Pvt_IP =
  BN01_Path = /home/${User_Name}/workspace/${JOB_NAME}
  Test_Server_Path = /opt/tomcat/webapps/
  Test_Server_Pub_IP = 
  Test_Server_Pvt_IP =
  User_Name = skmirza
********************************************************************************************************************************************************************************
********************************************************************************************************************************************************************************
*/ 
pipeline {
    agent none
    environment {
        Code_Checkout = false
        Maven_Build = false
        Deploy_Test = false
        Deploy_Verify = false
        Verify_User = false
    }
    stages {
        stage ('Get_Version') {
            agent {
                label 'BN01'
            }
            steps {
                script {
                    echo "The Default Version is: ${env.Default_Ver}"
                    try {
                        timeout(time: 15, unit: 'SECONDS') {
                            // Prompt user to provide a new version number within 15 seconds
                            def userVersion = input(
                                message: 'Please Provide The Version Of The Web Application',
                                ok: 'Submit',
                                parameters: [string(defaultValue: env.Default_Ver, description: 'Provide a new version number', name: 'new_ver')]
                            )
                            // If input is provided, set it as the new version
                            env.new_ver = userVersion
                            echo "The New Version Provided is: ${env.new_ver}"
                        }
                    } catch (Exception e) {
                        // On timeout or abort, increment the default version number by 0.0.1
                        def version = env.Default_Ver.tokenize('.')
                        version[2] = (version[2] as Integer) + 1
                        env.new_ver = version.join('.')
                        echo "No Version Provided So The New Version Will: ${env.new_ver}"
                    }
                }
            }
        }
        stage('SCM_Checkout') {
            agent {
                label 'BN01'
            }
            steps {
                cleanWs()
                echo '########## Checking out the code ##########'
                git 'https://github.com/sameer-014-Devops/Medicure.git'
            }
            post {
                success {
                    script {
                        echo '########## Code Checkout is SUCCESSFUL ##########'
                        Code_Checkout = true
                    }
                }
                failure {
                    script {
                        echo '########## Code Checkout is FAILED ##########'
                    }
                }
            }
        }
        stage('Maven_Build') {
            agent {
                label 'BN01'
            }
            steps {
                echo '########## Building the code ##########'
                sh 'mvn clean package'
                echo '########## Packaging the code SUCCESSFULL ##########'
                echo '########## Deleting the Dependency Installed ##########'
                sh 'rm -rf ~/.m2/repository'
                echo '########## Dependency Deleted in BuildNode ##########'
            }
            post {
                success {
                    script {
                        echo '########## Maven Build is SUCCESSFUL ##########'
                        Maven_Build = true
                    }
                }
                failure {
                    script {
                        echo '########## Maven Build is FAILED ##########'
                    }
                }
            }
        }
        stage('Deploy_Test') {
            agent {
                label 'AC'
            }
            steps {
                echo '########## Deploying the code to Test Server ##########'
                script {
                    // Checking and removing the existing sh file in Test Server
                    def fileExists1 = sh(script: """ssh $User_Name@$Test_Server_Pvt_IP ls $Test_Server_Path/*.sh || true""", returnStdout: true).trim()
                    if (fileExists1) {
                        echo 'Existing sh file found in the Test Server. Removing the existing sh file...'
                        sh """ ssh $User_Name@$Test_Server_Pvt_IP "sh $Test_Server_Path/*.sh stop" """
                        sleep 3
                        sh """ssh $User_Name@$Test_Server_Pvt_IP rm -rf $Test_Server_Path/*.sh"""
                    } else {
                        echo 'No existing sh file found in the Test Server...'
                    }
                    // Checking and Removing the existing jar file in Test Server
                    def fileExists = sh(script: """ssh $User_Name@$Test_Server_Pvt_IP ls $Test_Server_Path/*.jar || true""", returnStatus: true)
                    if (fileExists == 0) {
                        echo 'Existing jar file found in the Test Server. Removing the existing jar file...'
                        sh """ssh $User_Name@$Test_Server_Pvt_IP rm -rf $Test_Server_Path/*.jar"""
                    } else {
                        echo 'No existing jar file found in the Test Server...'
                    }

                    echo '########## Deploying the code to Test Server ##########'
                    // Copy the jar file and sh to the test server by using SCP
                    sh """ scp $User_Name@$Build01_Pvt_IP:$BN01_Path/target/*.jar $User_Name@$Test_Server_Pvt_IP:$Test_Server_Path/ """
                    sh """ scp $User_Name@$Build01_Pvt_IP:$BN01_Path/*.sh $User_Name@$Test_Server_Pvt_IP:$Test_Server_Path/ """
                    sh """ ssh $User_Name@$Test_Server_Pvt_IP chmod +x $Test_Server_Path/*.sh """
                    // Run the jar file in the test server in using .sh file
                    sh """ ssh $User_Name@$Test_Server_Pvt_IP "sh $Test_Server_Path/*.sh start" """
                }
            }
            post {
                success {
                    script {
                        Deploy_Test = true
                        echo '########## Deploy to Test Server is SUCCESSFUL ##########'
                    }
                }
                failure {
                    script {
                        echo '########## Deploy to Test Server is FAILED ##########'
                    }
                }
            }
        }
        stage('Verify_Deploy_Test') {
            agent {
                label 'BN01'
            }
            when {
                expression { Deploy_Test == true }
            }
            steps {
                echo '*********Verifying Test Deployment*********'
                //wait for 15 seconds before verifying the deployment
                sleep 15
                script {
                    def response = sh(script: """curl -s -o /dev/null -w '%{http_code}'  http://$Test_Server_Pub_IP:8081""", returnStdout: true).trim()
                    if (response == '200') {
                        Deploy_Verify = true
                        echo '*********Test Deployment is SUCCESSFUL*********'
                        
                    } else {
                        error '*********Test Deployment is FAILED*********'
                        
                    }
                }
            }
            post {
                success {
                    script {
                        echo '########## Test Deployment Verification is SUCCESSFUL ##########'
                    }
                }
                failure {
                    script {
                        echo '########## Test Deployment Verification is FAILED ##########'
                    }
                }
            }
        }
        stage('Verification_User'){
            agent {
                label 'BN01'
            }
            when{
                expression { Deploy_Verify == true }
            }
            steps{
                echo '***********Verifying By User***********'
                
                script{
                    echo "The Application URL: http://$Test_Server_Pub_IP:8081"
                    // Prompt user input to verify the deployment by accessing the application URL, within 60 seconds timeout, and proceed based on the user input (Y/N), if not provided, proceed with 'Y' as default input, and if the input is 'N', then only abort the pipeline.
                    try {
                        timeout(time: 120, unit: 'SECONDS') {
                            def userInput = input(
                                message: 'Please Verify The Deployment By Accessing The Application URL',
                                ok: 'Submit',
                                parameters: [choice(choices: ['Y', 'N'], description: 'Do you want to proceed with the deployment verification?', name: 'user_input')]
                            )
                            if (userInput == 'Y') {
                                echo 'User Has Confirmed The Deployment Verification So Proceeding With Docker Build'
                                Verify_User = true
                            } else {
                                echo 'User Has Denied The Deployment Verification So Aborting The Pipeline'
                                Verify_User = false
                                currentBuild.result = 'ABORTED'
                                error 'Pipeline Aborted by User'
                            }
                        }
                    } catch (hudson.AbortException e) {
                        // If timeout occurs or any other exception, proceed with the pipeline
                        if (e.getMessage().contains("Timeout")) {
                            Verify_User = true
                            echo 'User Did Not Provide Any Input Within The Timeout Period, Proceeding With Default Input (Y)'
                        } else {
                            throw e
                        }
                    } catch (Exception e) {
                        // Handle other exceptions
                        Verify_User = true
                        echo 'An unexpected error occurred, proceeding with default input (Y)'
                    }
                }
            }
            post{
                success{
                    script{
                        echo '########## User Verification is SUCCESSFUL ##########'
                        echo '########## Test Server Deployment is SUCCESSFUL ##########'
                    }
                }
                failure{
                    script{
                        echo '########## User Verification is FAILED ##########'
                        echo '########## Test Server Deployment is FAILED ##########'
                    }
                }
            }
        }
        stage ('Copy_Files_To_Production_Workspace'){
            agent {
                label 'BN01'
            }
            when{
                expression { Verify_User == true }
            }
            steps{
                sh """mkdir -p $Prod_Workspace"""
                sh """cp -R Dockerfile *.yaml target $Prod_Workspace"""
                echo '**********Copied the Dockerfile, medicuredeploy.yaml, and target files to the Medicure Production workspace**********'
                cleanWs()
                deleteDir()
            }
        }
    }
    post {
        success {
            build job: 'Medicure_Production_Pipeline', parameters: [string(name: 'new_ver', value: env.new_ver)]
            echo '########## Production Pipeline Triggered ##########'
        }
        failure {
            echo '########## Testing Pipeline is FAILED ##########'
        }
    }
}
