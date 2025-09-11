#!/bin/bash

# Test Runner Script for CSV Data Processing Pipeline

set -euo pipefail

# Config
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPORTS_DIR="${SCRIPT_DIR}/reports"
readonly TESTS_DIR="${SCRIPT_DIR}/tests"
readonly DATA_DIR="${SCRIPT_DIR}/data"
readonly TEST_RESULTS_DIR="${SCRIPT_DIR}/test_results"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

# Cleanup
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -f /tmp/combined_sales*.csv /tmp/emp_dept.csv 2>/dev/null || true
}

trap cleanup EXIT

validate_environment() {
    log_info "Validating test environment..."
    
    # check required directories
    local required_dirs=("$DATA_DIR" "$TESTS_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Required directory not found: $dir"
            return 1
        fi
    done
    
    # check required files
    local required_files=(
        "$DATA_DIR/employees.csv"
        "$DATA_DIR/sales_q1.csv"
        "$DATA_DIR/sales_q2.csv"
        "$DATA_DIR/server_metrics.csv"
        "$TESTS_DIR/test_outputs.py"
        "./solution.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Required file not found: $file"
            return 1
        fi
    done
    
    # check if solution.sh is executable
    if [[ ! -x "./solution.sh" ]]; then
        log_warning "Making solution.sh executable..."
        chmod +x "./solution.sh"
    fi
    
    # check python and pytest availability
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 not found. Please install Python3."
        return 1
    fi
    
    if ! python3 -c "import pytest" 2>/dev/null; then
        log_warning "pytest not found. Installing..."
        pip3 install pytest pandas || {
            log_error "Failed to install pytest. Please install manually."
            return 1
        }
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
        
        log_success "success! All expected reports generated"
        return 0
    else
        log_error "Solution script failed or timed out (10 minutes)"
        return 1
    fi
}

# test runs
run_tests() {
    log_info "Running comprehensive test suite..."
    
    mkdir -p "$TEST_RESULTS_DIR"
    
    local test_output_file="${TEST_RESULTS_DIR}/test_results.txt"
    local test_xml_file="${TEST_RESULTS_DIR}/test_results.xml"
    
    log_info "Executing pytest with verbose output..."
    
    # capture output
    if python3 -m pytest "$TESTS_DIR/test_outputs.py" \
        -v \
        --tb=short \
        --junit-xml="$test_xml_file" \
        --capture=no \
        2>&1 | tee "$test_output_file"; then
        
        log_success "All tests passed successfully!"
        
        # Generate test summary
        generate_test_summary "$test_output_file"
        
        return 0
    else
        log_error "Some tests failed. Check test results for details."
        
        # Generate failure summary
        generate_failure_summary "$test_output_file"
        
        return 1
    fi
}

generate_test_summary() {
    local test_output_file="$1"
    local summary_file="${TEST_RESULTS_DIR}/test_summary.txt"
    
    log_info "Generating test summary..."
    
    {
        echo "==============================================="
        echo "           TEST EXECUTION SUMMARY"
        echo "==============================================="
        echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # Extract test results
        local total_tests=$(grep -c "PASSED\|FAILED\|SKIPPED" "$test_output_file" || echo "0")
        local passed_tests=$(grep -c "PASSED" "$test_output_file" || echo "0")
        local failed_tests=$(grep -c "FAILED" "$test_output_file" || echo "0")
        local skipped_tests=$(grep -c "SKIPPED" "$test_output_file" || echo "0")
        
        echo "Test Results:"
        echo "  Total Tests:   $total_tests"
        echo "  Passed:        $passed_tests"
        echo "  Failed:        $failed_tests"
        echo "  Skipped:       $skipped_tests"
        echo ""
        
        if [[ $failed_tests -eq 0 ]]; then
            echo "✅ ALL TESTS PASSED - Solution is working correctly!"
        else
            echo "❌ SOME TESTS FAILED - Review failed tests below"
        fi
        
        echo ""
        echo "Test Coverage Areas:"
        echo "Revenue calculations and ranking"
        echo "Department salary analysis"
        echo "Missing data detection"
        echo "Duplicate record identification"
        echo "Monthly trend analysis"
        echo "Output format consistency"
        echo "Server performance outliers"
        echo "Regional performance comparison"
        echo "Data validation comprehensive"
        echo "Summary statistics accuracy"
        
        echo ""
        echo "Generated Reports:"
        if [[ -d "$REPORTS_DIR" ]]; then
            ls -la "$REPORTS_DIR"/*.txt 2>/dev/null | while read -r line; do
                echo "  $line"
            done
        fi
        
        echo ""
        echo "Performance Metrics:"
        if [[ -f "$test_output_file" ]]; then
            local test_duration=$(grep "seconds" "$test_output_file" | tail -1 || echo "Duration not available")
            echo "  Test Execution: $test_duration"
        fi
        
        # check soln performance
        if [[ -f "$REPORTS_DIR/top_performers.txt" ]]; then
            local report_size=$(du -sh "$REPORTS_DIR" | cut -f1)
            echo "  Reports Size: $report_size"
        fi
        
    } > "$summary_file"
    
    log_success "Test summary generated: $summary_file"
    
    # display summary to console
    echo ""
    cat "$summary_file"
}

# generate failure summary
generate_failure_summary() {
    local test_output_file="$1"
    local failure_file="${TEST_RESULTS_DIR}/test_failures.txt"
    
    log_info "Generating failure summary..."
    
    {
        echo "==============================================="
        echo "           TEST FAILURE ANALYSIS"
        echo "==============================================="
        echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        echo "Failed Tests:"
        grep "FAILED" "$test_output_file" || echo "No specific failures found"
        
        echo ""
        echo "Error Details:"
        grep -A 5 -B 2 "AssertionError\|Error\|Exception" "$test_output_file" || echo "No detailed errors found"
        
        echo ""
        echo "Troubleshooting Tips:"
        echo "1. Check that solution.sh generates all required reports"
        echo "2. Verify report format matches expected structure"
        echo "3. Ensure calculations are mathematically correct"
        echo "4. Check edge case handling for invalid data"
        echo "5. Validate output consistency across all reports"
        
    } > "$failure_file"
    
    log_error "Test failures documented: $failure_file"
    
    # display failure summary to console
    echo ""
    cat "$failure_file"
}

validate_performance() {
    log_info "Validating solution performance..."
    
    # check execution time if under 10 minutes
    local solution_log="/tmp/solution_performance.log"
    
    if [[ -f "$solution_log" ]]; then
        local execution_time=$(grep "Processing completed" "$solution_log" | tail -1 || echo "")
        if [[ -n "$execution_time" ]]; then
            log_info "Solution execution time: $execution_time"
        fi
    fi
    
    # check memory usage if reports are reasonable size
    if [[ -d "$REPORTS_DIR" ]]; then
        local total_size=$(du -sb "$REPORTS_DIR" | cut -f1)
        local size_mb=$((total_size / 1024 / 1024))
        
        if [[ $size_mb -gt 10 ]]; then
            log_warning "Reports are quite large: ${size_mb}MB"
        else
            log_success "Report size is reasonable: ${size_mb}MB"
        fi
    fi
    
    # check for deterministic output
    log_info "Checking output determinism..."
    
    # run solution twice and compare (simplified check)
    local first_run_hash=""
    local second_run_hash=""
    
    if [[ -f "$REPORTS_DIR/top_performers.txt" ]]; then
        first_run_hash=$(md5sum "$REPORTS_DIR/top_performers.txt" | cut -d' ' -f1)
        
        # run solution again
        ./solution.sh > /dev/null 2>&1
        
        second_run_hash=$(md5sum "$REPORTS_DIR/top_performers.txt" | cut -d' ' -f1)
        
        if [[ "$first_run_hash" == "$second_run_hash" ]]; then
            log_success "Output is deterministic"
        else
            log_warning "Output may not be deterministic (timestamps could cause differences)"
        fi
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
    
    if ! run_tests; then
        log_error "Test execution failed"
        exit_code=1
    fi
    
    validate_performance
    
    echo ""
    echo "==============================================="
    echo "              TEST EXECUTION COMPLETE"
    echo "==============================================="
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "All tests completed successfully! 🎉"
        echo ""
        echo "Your solution is ready for submission!"
        echo "Check the reports/ directory for generated outputs."
        echo "Check the test_results/ directory for detailed test results."
    else
        log_error "Some tests failed. Please review and fix issues."
        echo ""
        echo "Check test_results/test_failures.txt for detailed failure analysis."
    fi
    
    exit $exit_code
}

main "$@"
