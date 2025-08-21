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

log_step "Installing Fabric CI-CD tools..."
if pip install fabric-cicd --quiet; then
    log_success "fabric-cicd installed successfully"
else
    log_error "Failed to install fabric-cicd"
    exit 1
fi

log_header "Setup Complete! 🎉"
log_success "All tools installed successfully!"
log_info "Your development environment is ready to use."
printf "${CYAN}📚 Available tools:${NC}\n"
printf "  • ${GREEN}sqlcmd${NC} - SQL Server command-line tool\n"
printf "  • ${GREEN}fabric-cicd${NC} - Fabric CI/CD utilities\n"
printf "\n"