#!/bin/bash

# CSV Data Processing Pipeline - Test Runner Script
# Description: Run the solution script and validate outputs

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPORTS_DIR="${SCRIPT_DIR}/reports"
readonly DATA_DIR="${SCRIPT_DIR}/data"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

validate_environment() {
    log_info "Validating test environment..."
    
    # Check required directories
    local required_dirs=("$DATA_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Required directory not found: $dir"
            return 1
        fi
    done
    
    # Check required files
    local required_files=(
        "$DATA_DIR/employees.csv"
        "$DATA_DIR/sales_q1.csv"
        "$DATA_DIR/sales_q2.csv"
        "$DATA_DIR/server_metrics.csv"
        "./solution.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Required file not found: $file"
            return 1
        fi
    done
    
    # Check if solution.sh is executable
    if [[ ! -x "./solution.sh" ]]; then
        log_info "Making solution.sh executable..."
        chmod +x "./solution.sh"
    fi
    
    log_success "Environment validation finished"
    return 0
}

# Run solution script
run_solution() {
    log_info "Running solution script to generate reports..."
    
    # Clean previous reports
    rm -rf "$REPORTS_DIR"
    mkdir -p "$REPORTS_DIR"
    
    # Run solution with timeout
    local start_time=$(date +%s)
    
    if timeout 600 ./solution.sh; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_success "Solution completed in ${duration} seconds"
        
        # Verify reports were generated
        local expected_reports=(
            "top_performers.txt"
            "department_analysis.txt"
            "trend_analysis.txt"
            "data_quality.txt"
        )
        
        for report in "${expected_reports[@]}"; do
            if [[ ! -f "$REPORTS_DIR/$report" ]]; then
                log_error "Expected report not generated: $report"
                return 1
            fi
        done
        
        log_success "All expected reports generated"
        return 0
    else
        log_error "Solution script failed or timed out (10 minutes)"
        return 1
    fi
}

# Main execution
main() {
    echo "==============================================="
    echo "  TEST RUNNER FOR CSV DATA PROCESSING PIPELINE"
    echo "==============================================="
    echo ""
    
    local exit_code=0
    
    if ! validate_environment; then
        log_error "Environment validation failed"
        exit 1
    fi
    
    if ! run_solution; then
        log_error "Solution execution failed"
        exit 1
    fi
    
    echo ""
    echo "==============================================="
    echo "              TEST EXECUTION COMPLETE"
    echo "==============================================="
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "All tests completed successfully!"
        echo ""
        echo "Your solution is ready for submission!"
        echo "Check the reports/ directory for generated outputs."
    else
        log_error "Some tests failed. Please review and fix issues."
    fi
    
    exit $exit_code
}

main "$@"
