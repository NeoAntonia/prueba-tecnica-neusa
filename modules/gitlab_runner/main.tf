# Custom data script with enhanced logging and error handling
locals {
  custom_data = base64encode(<<-CUSTOM_DATA
    #!/bin/bash

    # Set up logging
    exec 1> >(tee -a "/home/adminuser/gitlab-runner-install.log") 2>&1
    
    # Error handling function
    handle_error() {
      local exit_code=$?
      local line_number=$1
      if [ $exit_code -ne 0 ]; then
        echo "Error occurred in script at line $line_number"
        echo "Exit code: $exit_code"
        exit $exit_code
      fi
    }
    
    # Trap errors
    trap 'handle_error $LINENO' ERR
    
    echo "[$(date)] Starting GitLab Runner installation and configuration..."
    
    # Wait for cloud-init to finish
    echo "[$(date)] Waiting for cloud-init to complete..."
    cloud-init status --wait
    
    # Function to verify package installation
    verify_package() {
      if ! dpkg -l | grep -q $1; then
        echo "Error: Package $1 failed to install properly."
        return 1
      fi
      echo "Package $1 installed successfully."
    }
    
    # Update system
    echo "[$(date)] Updating system packages..."
    apt-get update && apt-get upgrade -y
    handle_error $LINENO
    
    # Install necessary tools for Docker and AKS
    echo "[$(date)] Installing prerequisite packages..."
    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      apt-transport-https \
      jq \
      unzip
    handle_error $LINENO
    
    # Install Azure CLI
    echo "[$(date)] Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash
    verify_package azure-cli
    
    # Install kubectl
    echo "[$(date)] Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    kubectl version --client
    handle_error $LINENO
    
    # Add GitLab Runner repository
    echo "[$(date)] Adding GitLab Runner repository..."
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
    handle_error $LINENO
    
    # Install GitLab Runner
    echo "[$(date)] Installing GitLab Runner..."
    apt-get install -y gitlab-runner
    verify_package gitlab-runner
    
    # Install Docker
    echo "[$(date)] Installing Docker..."
    mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    verify_package docker-ce
    
    # Configure Docker
    echo "[$(date)] Configuring Docker..."
    usermod -aG docker gitlab-runner
    usermod -aG docker adminuser
    systemctl enable docker
    systemctl start docker
    handle_error $LINENO
    
    # Register the runner
    echo "[$(date)] Registering GitLab Runner..."
    gitlab-runner register \
      --non-interactive \
      --url "${var.gitlab_url}" \
      --registration-token "${var.runner_registration_token}" \
      --description "Azure VM Runner Ubuntu 22.04" \
      --tag-list "${var.runner_tags}" \
      --executor "shell" \
      --locked="false" \
      --access-level="not_protected"
    handle_error $LINENO
    
    # Configure GitLab Runner
    echo "[$(date)] Configuring GitLab Runner..."
    cat > /etc/gitlab-runner/config.toml <<EOF
    concurrent = 4
    check_interval = 0

    [session_server]
      session_timeout = 1800

    [[runners]]
      executor = "shell"
      shell = "bash"
      environment = ["DOCKER_HOST=unix:///var/run/docker.sock"]
    EOF
    
    # Start and enable the runner service
    echo "[$(date)] Starting GitLab Runner service..."
    systemctl enable gitlab-runner
    systemctl start gitlab-runner
    handle_error $LINENO
    
    # Verify services are running
    echo "[$(date)] Verifying services..."
    systemctl is-active --quiet gitlab-runner && echo "GitLab Runner is running" || echo "GitLab Runner is not running"
    systemctl is-active --quiet docker && echo "Docker is running" || echo "Docker is not running"
    
    # Create a summary file
    echo "[$(date)] Creating installation summary..."
    cat > "/home/adminuser/installation-summary.txt" <<EOF
    Installation Summary ($(date))
    -----------------------------
    GitLab Runner Version: $(gitlab-runner --version | head -n 1)
    Docker Version: $(docker --version)
    Azure CLI Version: $(az --version | head -n 1)
    Kubectl Version: $(kubectl version --client)
    Runner Tags: ${var.runner_tags}
    Runner Executor: shell
    EOF

        echo "[$(date)] Installation completed successfully!"
      CUSTOM_DATA
  )
}

resource "azurerm_network_interface" "gitlab_runner" {
  name                = "nic-gitlab-runner"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "gitlab_runner" {
  name                = "vm-gitlab-runner"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2s"

  network_interface_ids = [
    azurerm_network_interface.gitlab_runner.id,
  ]

  admin_username                  = "adminuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = local.custom_data

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "gitlab_runner" {
  name                = "vm-gitlab-runner-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "gitlab_runner" {
  network_interface_id      = azurerm_network_interface.gitlab_runner.id
  network_security_group_id = azurerm_network_security_group.gitlab_runner.id
}

resource "azurerm_bastion_host" "gitlab_runner" {
  name                = "vnet-gitlab-runner-Bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-gitlab-runner"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
