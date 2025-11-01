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
log_header "Post-Create Setup"

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

log_header "Post-Create Setup Complete! 🎉"
log_success "Python packages installed successfully!"
printf "${CYAN}📦 Installed packages:${NC}\n"
printf "  • ${GREEN}fabric-cicd${NC}\n"
printf "\n"
