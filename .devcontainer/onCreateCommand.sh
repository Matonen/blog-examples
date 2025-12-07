#!/bin/sh
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

log_info() {
    printf "${CYAN}ℹ️  %s${NC}\n" "$1"
}

log_success() {
    printf "${GREEN}✅ %s${NC}\n" "$1"
}

log_error() {
    printf "${RED}❌ %s${NC}\n" "$1"
}

log_step() {
    printf "${BLUE}🔧 %s${NC}\n" "$1"
}

log_header() {
    printf "\n${PURPLE}🚀 %s${NC}\n" "$1"
    printf "${PURPLE}════════════════════════════════════════${NC}\n\n"
}

# Main execution
log_header "DevContainer Setup"

log_step "Installing SQL Command-line utilities..."
log_info "Adding Microsoft package signing key..."
if curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null; then
    log_success "Microsoft signing key added"
else
    log_error "Failed to add Microsoft signing key"
    exit 1
fi

log_info "Adding Microsoft package repository..."
if sudo wget -qO /etc/apt/sources.list.d/microsoft-prod.list https://packages.microsoft.com/config/ubuntu/22.04/prod.list; then
    log_success "Microsoft repository added"
else
    log_error "Failed to add Microsoft repository"
    exit 1
fi

log_info "Updating package lists..."
if sudo apt-get update -qq; then
    log_success "Package lists updated"
else
    log_error "Failed to update package lists"
    exit 1
fi

log_info "Installing sqlcmd..."
if sudo apt-get install -y sqlcmd -qq; then
    log_success "sqlcmd installed successfully"
else
    log_error "Failed to install sqlcmd"
    exit 1
fi

log_step "Installing k3d..."
log_info "Downloading and installing k3d from official script..."
if curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; then
    log_success "k3d installed successfully"
else
    log_error "Failed to install k3d"
    exit 1
fi

log_step "Installing k9s..."
log_info "Downloading and installing k9s from official script..."
if curl -sS https://webi.sh/k9s | sh; then
    log_success "k9s installed successfully"
    log_info "Sourcing k9s PATH configuration..."
    if [ -f ~/.config/envman/PATH.env ]; then
        . ~/.config/envman/PATH.env
        log_success "k9s PATH configured"
    fi
else
    log_error "Failed to install k9s"
    exit 1
fi

log_step "Installing kubectl..."
log_info "Detecting system architecture..."
ARCH=$(uname -m)
case ${ARCH} in
    x86_64)
        KUBECTL_ARCH="amd64"
        ;;
    aarch64|arm64)
        KUBECTL_ARCH="arm64"
        ;;
    *)
        log_error "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac
log_info "Architecture detected: ${ARCH} (using ${KUBECTL_ARCH})"
log_info "Downloading and installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
if curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" && \
   chmod +x kubectl && \
   sudo mv kubectl /usr/local/bin/kubectl; then
    log_success "kubectl installed successfully (${KUBECTL_VERSION} - ${KUBECTL_ARCH})"
else
    log_error "Failed to install kubectl"
    exit 1
fi

log_step "Installing Trivy..."
log_info "Downloading and installing Trivy v0.67.2..."
if curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.67.2; then
    log_success "Trivy installed successfully"
else
    log_error "Failed to install Trivy"
    exit 1
fi

log_step "Installing Azure Quick Review CLI (azqr)..."
log_info "Downloading azqr binary..."
AZQR_URL="https://github.com/Azure/azqr/releases/latest/download/azqr-ubuntu-latest-amd64"
if curl -sL "$AZQR_URL" -o /tmp/azqr && \
   chmod +x /tmp/azqr && \
   sudo mv /tmp/azqr /usr/local/bin/azqr; then
    log_success "azqr installed successfully"
else
    log_error "Failed to install azqr"
    exit 1
fi

log_step "Installing Azure Developer CLI (azd)..."
log_info "Downloading and installing azd from official script..."
if curl -fsSL https://aka.ms/install-azd.sh | bash; then
    log_success "azd installed successfully"
else
    log_error "Failed to install azd"
    exit 1
fi

log_step "Setting up k3s cluster..."
log_info "Checking for existing k3s cluster..."
if k3d cluster list | grep -q "k3s-default"; then
    log_info "Deleting existing k3s cluster..."
    if k3d cluster delete; then
        log_success "Existing cluster deleted"
    else
        log_error "Failed to delete existing cluster"
        exit 1
    fi
else
    log_info "No existing cluster found"
fi

log_info "Creating new k3s cluster with port mappings..."
if k3d cluster create \
    -p '8080:8080@loadbalancer'; then
    log_success "k3s cluster created successfully"
else
    log_error "Failed to create k3s cluster"
    exit 1
fi

log_step "Installing Python packages..."
if [ -f .devcontainer/requirements.txt ]; then
    log_info "Installing packages from requirements.txt..."
    if pip install -r .devcontainer/requirements.txt --quiet; then
        log_success "Python packages installed successfully"
    else
        log_error "Failed to install Python packages"
        exit 1
    fi
else
    log_error "requirements.txt not found"
    exit 1
fi

log_step "Installing Node.js packages..."
log_info "Installing @openai/codex globally..."
if npm i -g @openai/codex; then
    log_success "Node.js packages installed successfully"
else
    log_error "Failed to install Node.js packages"
    exit 1
fi

log_header "Setup Complete! 🎉"
log_success "All tools installed successfully!"
log_info "Your development environment is ready to use."
printf "${CYAN}📚 Available tools:${NC}\n"
printf "  • ${GREEN}sqlcmd${NC} - SQL Server command-line tool\n"
printf "  • ${GREEN}kubectl${NC} - Kubernetes command-line tool\n"
printf "  • ${GREEN}k3d${NC} - Kubernetes in Docker\n"
printf "  • ${GREEN}k9s${NC} - Kubernetes CLI UI\n"
printf "  • ${GREEN}trivy${NC} - Security scanner\n"
printf "  • ${GREEN}azqr${NC} - Azure Quick Review CLI\n"
printf "  • ${GREEN}azd${NC} - Azure Developer CLI\n"
printf "  • ${GREEN}k3s cluster${NC} - Kubernetes cluster (port: 8080)\n"
printf "${CYAN}📦 Installed packages:${NC}\n"
printf "  • ${GREEN}fabric-cicd${NC} (Python)\n"
printf "  • ${GREEN}@openai/codex${NC} (npm)\n"
printf "\n"