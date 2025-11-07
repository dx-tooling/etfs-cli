#!/usr/bin/env bash
set -euo pipefail

# Colors for output (with fallback for terminals that don't support them)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Remote repository configuration
readonly REPO_OWNER="dx-tooling"
readonly REPO_NAME="etfs-cli"
readonly REPO_BRANCH="main"
readonly BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/refs/heads/${REPO_BRANCH}/mise-tasks/etfs"

# Error handling
error() {
    echo -e "${RED}Error:${NC} $*" >&2
    exit 1
}

info() {
    echo -e "${BLUE}Info:${NC} $*"
}

success() {
    echo -e "${GREEN}Success:${NC} $*"
}

warning() {
    echo -e "${YELLOW}Warning:${NC} $*"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Download a file from URL to destination
download_file() {
    local url="$1"
    local dest="$2"
    
    # Try curl first, then wget
    if command_exists curl; then
        if ! curl -fsSL --fail "${url}" -o "${dest}"; then
            error "Failed to download task file from: ${url}"
        fi
    elif command_exists wget; then
        if ! wget -q --tries=3 --timeout=10 "${url}" -O "${dest}"; then
            error "Failed to download task file from: ${url}"
        fi
    else
        error "Neither curl nor wget is available. Please install one of them to continue."
    fi
}

# Detect package manager and provide installation instructions
detect_install_method() {
    if command_exists brew; then
        echo "https://mise.jdx.dev/installing-mise.html#homebrew"
    elif command_exists apt-get || command_exists apt; then
        echo "https://mise.jdx.dev/installing-mise.html#apt"
    else
        echo "https://mise.jdx.dev/installing-mise.html#https-mise-run"
    fi
}

# Verify mise is installed
verify_mise() {
    if ! command_exists mise; then
        local install_url
        install_url=$(detect_install_method)
        
        error "mise is not installed on your system.\n" \
              "Please install mise by following the instructions at:\n" \
              "  ${install_url}\n" \
              "After installation, please run this script again."
    fi
    
    info "mise is installed: $(command -v mise)"
}

# Determine mise config directory
get_mise_config_dir() {
    if [[ -n "${MISE_CONFIG_DIR:-}" ]]; then
        echo "${MISE_CONFIG_DIR}"
    else
        local xdg_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
        echo "${xdg_config_home}/mise"
    fi
}

# Install the task files
install_task() {
    local mise_config_dir
    mise_config_dir=$(get_mise_config_dir)
    local tasks_dir="${mise_config_dir}/tasks/etfs"
    
    # Create tasks/etfs directory if it doesn't exist
    if [[ ! -d "${tasks_dir}" ]]; then
        info "Creating mise tasks directory: ${tasks_dir}"
        mkdir -p "${tasks_dir}" || error "Failed to create directory: ${tasks_dir}"
    fi
    
    # List of task files to install
    local task_files=("_default" "self-update.sh")
    
    # Download each task file from remote repository
    for task_file in "${task_files[@]}"; do
        local url="${BASE_URL}/${task_file}"
        local target_file="${tasks_dir}/${task_file}"
        
        info "Downloading etfs task file: ${task_file}"
        download_file "${url}" "${target_file}"
        
        # Make it executable
        chmod +x "${target_file}" || error "Failed to make task file executable: ${target_file}"
        
        # Verify the download was successful
        if [[ ! -f "${target_file}" ]] || [[ ! -x "${target_file}" ]]; then
            error "Installation verification failed: ${target_file}"
        fi
        
        # Verify the file has content
        if [[ ! -s "${target_file}" ]]; then
            error "Downloaded task file is empty: ${target_file}"
        fi
    done
    
    success "All task files installed successfully"
}

# Main installation function
main() {
    echo "Installing ETFS CLI task for mise..."
    echo ""
    
    verify_mise
    install_task
    
    echo ""
    success "Installation complete!"
    echo ""
    info "You can now run the ETFS CLI using:"
    echo "  ${GREEN}mise run etfs${NC}"
    echo "  ${GREEN}mise run etfs:self-update${NC}"
}

# Run main function
main "$@"
