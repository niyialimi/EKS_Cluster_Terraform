# Provisioning an AWS Kubernetes Cluster (EKS) with Terraform
<p align="center"><a href="https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html" target="_blank"><img align="center" src="images/what-is-eks.png"></a></p>

- [Provisioning an AWS Kubernetes Cluster (EKS) with Terraform](#Provisioning-an-aws-kubernetes-cluster-eks-with-terraform)
  - [Introduction](#introduction)
  - [Kubernetes](#kubernetes)
  - [Amazon EKS](#amazon-eks)
  - [Terraform](#terraform)
  - [Cluster](#cluster)
  - [Deploy an EKS Cluster with Terraform](#deploy-an-eks-cluster-with-terraform)

## Introduction

Manual provisioning of resources is now a thing of the past for cloud engineers as valuable time is being spent on doing value-driven work with automation. Repeatable and consistent  practices are now formidable practices in the cloud when it comes to workload scalability, and terraform stands tall in this regard.

Here is a demo of how to provision an Amazon EKS cluster with Terraform step by step. Though it may be easier and more efficient to make use of public modules, for a better understanding of each component of the EKS, I’ve decided to do the hard way by writing my own module. Let’s get started!

## Kubernetes

Kubernetes, also known as K8s, is an open-source system for container orchestration platforms. It is used in the automation of deployment, scaling, and management of containerized applications. Source: https://kubernetes.io

## Amazon EKS

Amazon EKS (Elastic Kubernetes Service) is a managed service on AWS running Kubernetes. With EKS, Kubernetes can be run without the need to install, operate, and maintain your own Kubernetes control plane or nodes. Source: https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html

## Terraform

Terraform is a free and open-source infrastructure as code tool by HashiCorp that is used to define both cloud and on-prem resources in human-readable configuration files that can be versioned, reused, and shared. Source: https://www.terraform.io/intro

## Cluster

A cluster is a collection of two or more or nodes working together to achieve a common goal. With a cluster, workloads consisting of a high number of individual tasks can be distributed among the nodes in the cluster. The combined memory and processing power of each node in the cluster can be leveraged to increase the overall performance of the tasks.

## Deploy an EKS Cluster with Terraform

Before we start provisioning an EKS Cluster,  there are a few prerequisites you need to have in mind and on hand.

### Prerequisites

Correct tools selection is really important in the CI setup, and the following tools are used for the demo in this article.

- AWS Account 
- IAM User with programmatic access and proper permissions (AmazonEKSClusterPolicy and AdministratorAccess)
- A code Editor (Visual Studio Code recommended)
- Terraform installed on the code editor 
- AWS CLI installed and configured on the code editor
- Kubernetes CLI installed and configured on the code editor

Once the prerequisites are met, we can start writing the code to create an EKS cluster.

### Step1: Terraform Initial Setup Configuration

Create an AWS provider.tf and the version.tf to interact with the AWS resources. Also create a remote_state.tf file to save the state file.

### Step 2: Networking Module

For the network infrastructure, we will be creating the following:
- AWS VPC (Virtual Private Cloud) of 10.0.0.0/16 CIDR range
- Public and Private Subnets in different availability zones. A list of availability zones available will be auto-generated.
- Internet Gateway to provide internet access for services within the public subnet in the VPC.
- An Elastic IP to be used by the NAT Gateway
- NAT Gateway in public subnets to allow services in the private subnets to connect to the internet. 
- Two Routing Tables (1 for public and 1 for Private) and associate the subnets with them. Security Groups and associate subnets with them

### Step 3: Cluster Module

EKS nodes need IAM roles to make calls to other AWS services (eks-node-group). These roles are attached with policies that allow assuming the temporary security credentials on the instance to access other AWS resources.

For the cluster infrastructure, we will be creating the following:
- IAM role and role attachments to the policy (**AmazonEKSClusterPolicy**) for the cluster.
- An EKS Cluster
- IAM role and role attachments to the policy (**AmazonEKSWorkerNodePolicy**, **AmazonEKS_CNI_Policy** and **AmazonEC2ContainerRegistryReadOnly**) for the worker nodes. 
- Security groups for the cluster and the nodes.

### Step 4: Using the modules created to provision the Cluster with all the needed resources

### Step 5: Terraform execution to provision the resources

At this stage, all the necessary files are in place and it’s time to create the cluster. To provision the cluster, cd into the root directory and run the terraform commands:
- terrafom init
- terrafom validate
- terrafom plan
- terrafom apply

### Step 6: Connecting the Cluster

The same AWS account profile that provisioned the infrastructure can be used to connect to the cluster by updating the local kubeconfig

### Step 7: Verifying the resources provisioned

Navigate to the AWS Console and verify the resources created. You can also do a quick checkup with some commands.

### Step 8: Testing - Deploy a simple Application in the cluster

Deploy a simple voting application to test that our provisioned resources work as expected. The Kubernetes specification files for the voting application in a directory then cd into that directory.

### Step 9: Cleanup

Destroy infrastructure with Terraform, ensure you're at the directory where the apply was made and then run terraform destroy.