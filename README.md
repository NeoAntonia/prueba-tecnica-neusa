Terraform Azure Infrastructure

This Terraform project provisions an Azure infrastructure that includes networking, API management, an AKS cluster, storage, databases, and GitLab runner services
I implemented this solution many times mainly to hosted artificial inteliggence based applications on my previous clients.
I also implent two different enviroments, dev and production separated by terraform tfvars files. See attached pictures of the terraform plan run by me.

🚀 Features

Creates an Azure Resource Group

Deploys an Azure Virtual Network with subnets

Configures Azure Kubernetes Service (AKS)

Sets up API Management

Deploys Storage Accounts

Provisions Database Services

Installs GitLab Runner

Supports additional optional modules like Application Gateway, Service Bus, Front Door, and OpenAI (commented out by default)
