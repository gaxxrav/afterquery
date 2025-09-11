#!/bin/bash

# CSV Data Processing Pipeline - Solution Script
# Description: Process employee, sales, and server data to generate executive reports

set -euo pipefail

# Config
readonly DATA_DIR="data"
readonly REPORTS_DIR="reports"
readonly EMPLOYEES_FILE="${DATA_DIR}/employees.csv"
readonly SALES_Q1_FILE="${DATA_DIR}/sales_q1.csv"
readonly SALES_Q2_FILE="${DATA_DIR}/sales_q2.csv"
readonly SERVER_METRICS_FILE="${DATA_DIR}/server_metrics.csv"

mkdir -p "${REPORTS_DIR}"

log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

validate_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    if [[ ! -s "$file" ]]; then
        log_error "File is empty: $file"
        return 1
    fi
    return 0
}

validate_input_files() {
    log_info "Validating input files..."
    local files=("$EMPLOYEES_FILE" "$SALES_Q1_FILE" "$SALES_Q2_FILE" "$SERVER_METRICS_FILE")
    
    for file in "${files[@]}"; do
        if ! validate_file "$file"; then
            exit 1
        fi
    done
    log_info "All input files validated successfully"
}

# clean and normalize data
clean_csv_data() {
    local input_file="$1"
    local output_file="$2"
    
    sed 's/\r$//' "$input_file" | \
    awk -F',' 'BEGIN{OFS=","} {
        # Handle quoted fields and normalize empty fields
        for(i=1; i<=NF; i++) {
            gsub(/^"/, "", $i)
            gsub(/"$/, "", $i)
            if($i == "" || $i ~ /^[[:space:]]*$/) {
                $i = "NULL"
            }
        }
        print
    }' > "$output_file"
}

generate_top_performers_report() {
    log_info "Generating Top Performers Report..."
    
    local output_file="${REPORTS_DIR}/top_performers.txt"
    
    {
        echo "==============================================="
        echo "           TOP PERFORMERS REPORT"
        echo "==============================================="
        echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # Combine Q1 and Q2 sales data, exclude invalid records
        local combined_sales="/tmp/combined_sales.csv"
        {
            head -1 "$SALES_Q1_FILE"
            tail -n +2 "$SALES_Q1_FILE" | grep -v '^[[:space:]]*$'
            tail -n +2 "$SALES_Q2_FILE" | grep -v '^[[:space:]]*$'
        } > "$combined_sales"
        
        echo "TOP 5 SALES REPS BY TOTAL REVENUE:"
        echo "=================================="
        awk -F',' 'NR>1 && $2 != "" && $2 != "NULL" && $3 ~ /^[0-9]+(\.[0-9]+)?$/ && $3 > 0 {
            revenue[$2] += $3
            deals[$2]++
        } END {
            for(emp in revenue) {
                print revenue[emp], emp, deals[emp]
            }
        }' "$combined_sales" | \
        sort -nr | \
        head -5 | \
        awk '{
            printf "%-12s: $%'"'"'12.2f (%d deals)\n", $2, $1, $3
        }'
        
        echo ""
        
        echo "TOP 5 SALES REPS BY NUMBER OF DEALS:"
        echo "===================================="
        awk -F',' 'NR>1 && $2 != "" && $2 != "NULL" && $3 ~ /^[0-9]+(\.[0-9]+)?$/ && $3 > 0 {
            deals[$2]++
            revenue[$2] += $3
        } END {
            for(emp in deals) {
                print deals[emp], emp, revenue[emp]
            }
        }' "$combined_sales" | \
        sort -nr | \
        head -5 | \
        awk '{
            printf "%-12s: %d deals ($%'"'"'12.2f total)\n", $2, $1, $3
        }'
        
        echo ""
        
        echo "PERFORMANCE METRICS (TOP 10 REPS):"
        echo "=================================="
        printf "%-12s %-15s %-12s %-15s\n" "Employee ID" "Total Revenue" "Deal Count" "Avg Deal Size"
        printf "%-12s %-15s %-12s %-15s\n" "----------" "-------------" "----------" "-------------"
        
        awk -F',' 'NR>1 && $2 != "" && $2 != "NULL" && $3 ~ /^[0-9]+(\.[0-9]+)?$/ && $3 > 0 {
            revenue[$2] += $3
            deals[$2]++
        } END {
            for(emp in revenue) {
                avg = revenue[emp] / deals[emp]
                printf "%-12s $%13.2f %12d $%13.2f\n", emp, revenue[emp], deals[emp], avg
            }
        }' "$combined_sales" | \
        sort -k2 -nr | \
        head -10
        
        rm -f "$combined_sales"
        
    } > "$output_file"
    
    log_info "Top Performers Report generated: $output_file"
}

generate_department_analysis_report() {
    log_info "Generating Department Analysis Report..."
    
    local output_file="${REPORTS_DIR}/department_analysis.txt"
    
    {
        echo "==============================================="
        echo "         DEPARTMENT ANALYSIS REPORT"
        echo "==============================================="
        echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        echo "AVERAGE SALARY BY DEPARTMENT:"
        echo "============================="
        awk -F',' 'NR>1 && $3 != "" && $3 != "NULL" && $4 ~ /^[0-9]+(\.[0-9]+)?$/ && $4 > 0 {
            dept_salary[$3] += $4
            dept_count[$3]++
        } END {
            for(dept in dept_salary) {
                avg = dept_salary[dept] / dept_count[dept]
                printf "%-15s: $%10.2f\n", dept, avg
            }
        }' "$EMPLOYEES_FILE" | sort -k2 -nr
        
        echo ""
        
        echo "EMPLOYEE COUNT PER DEPARTMENT:"
        echo "=============================="
        awk -F',' 'NR>1 && $3 != "" && $3 != "NULL" {
            dept_count[$3]++
        } END {
            for(dept in dept_count) {
                printf "%-15s: %3d employees\n", dept, dept_count[dept]
            }
        }' "$EMPLOYEES_FILE" | sort -k2 -nr
        
        echo ""
        
        echo "DEPARTMENT REVENUE CONTRIBUTION:"
        echo "==============================="
        
        # create temp files for joining
        local emp_dept="/tmp/emp_dept.csv"
        local combined_sales="/tmp/combined_sales_dept.csv"
        
        # employee department mapping extraction
        awk -F',' 'NR>1 && $1 != "" && $3 != "" {print $1","$3}' "$EMPLOYEES_FILE" > "$emp_dept"
        
        # Combine sales data
        {
            tail -n +2 "$SALES_Q1_FILE" | grep -v '^[[:space:]]*$'
            tail -n +2 "$SALES_Q2_FILE" | grep -v '^[[:space:]]*$'
        } > "$combined_sales"
        
        # Join sales with employee depts and calc revenue by dept
        join -t',' -1 2 -2 1 <(sort -t',' -k2 "$combined_sales") <(sort -t',' -k1 "$emp_dept") | \
        awk -F',' '$2 ~ /^[0-9]+(\.[0-9]+)?$/ && $2 > 0 {
            dept_revenue[$NF] += $2
        } END {
            total = 0
            for(dept in dept_revenue) total += dept_revenue[dept]
            for(dept in dept_revenue) {
                pct = (dept_revenue[dept] / total) * 100
                printf "%-15s: $%12.2f (%5.1f%%)\n", dept, dept_revenue[dept], pct
            }
        }' | sort -k2 -nr
        
        echo ""
        
        echo "SALARY DISTRIBUTION STATISTICS:"
        echo "==============================="
        awk -F',' 'NR>1 && $4 ~ /^[0-9]+(\.[0-9]+)?$/ && $4 > 0 {
            salaries[NR] = $4
            sum += $4
            count++
        } END {
            # Sort salaries for median calculation
            n = asort(salaries)
            
            # Calculate statistics
            mean = sum / count
            median = (n % 2) ? salaries[(n+1)/2] : (salaries[n/2] + salaries[n/2+1]) / 2
            min_sal = salaries[1]
            max_sal = salaries[n]
            
            # Calculate standard deviation
            sum_sq_diff = 0
            for(i in salaries) {
                diff = salaries[i] - mean
                sum_sq_diff += diff * diff
            }
            std_dev = sqrt(sum_sq_diff / count)
            
            printf "Total Employees: %d\n", count
            printf "Mean Salary:     $%10.2f\n", mean
            printf "Median Salary:   $%10.2f\n", median
            printf "Min Salary:      $%10.2f\n", min_sal
            printf "Max Salary:      $%10.2f\n", max_sal
            printf "Std Deviation:   $%10.2f\n", std_dev
        }' "$EMPLOYEES_FILE"
        
        rm -f "$emp_dept" "$combined_sales"
        
    } > "$output_file"
    
    log_info "Department Analysis Report generated: $output_file"
}

generate_trend_analysis_report() {
    log_info "Generating Trend Analysis Report..."
    
    local output_file="${REPORTS_DIR}/trend_analysis.txt"
    
    {
        echo "==============================================="
        echo "           TREND ANALYSIS REPORT"
        echo "==============================================="
        echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        echo "MONTHLY SALES TRENDS:"
        echo "===================="
        
        local combined_sales="/tmp/combined_sales_trend.csv"
        {
            tail -n +2 "$SALES_Q1_FILE" | grep -v '^[[:space:]]*$'
            tail -n +2 "$SALES_Q2_FILE" | grep -v '^[[:space:]]*$'
        } > "$combined_sales"
        
        # calculate monthly totals
        awk -F',' '$4 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ && $3 ~ /^[0-9]+(\.[0-9]+)?$/ && $3 > 0 {
            month = substr($4, 1, 7)  # Extract YYYY-MM
            monthly_sales[month] += $3
            monthly_deals[month]++
        } END {
            for(month in monthly_sales) {
                print month, monthly_sales[month], monthly_deals[month]
            }
        }' "$combined_sales" | sort | \
        awk '{
            printf "%-8s: $%12.2f (%d deals)\n", $1, $2, $3
            if(prev_revenue > 0) {
                growth = (($2 - prev_revenue) / prev_revenue) * 100
                printf "          Growth: %+6.1f%%\n", growth
            }
            prev_revenue = $2
        }'
        
        echo ""
        
        echo "REGIONAL PERFORMANCE COMPARISON:"
        echo "==============================="
        awk -F',' '$3 ~ /^[0-9]+(\.[0-9]+)?$/ && $3 > 0 && $5 != "" {
            region_revenue[$5] += $3
            region_deals[$5]++
        } END {
            total_revenue = 0
            for(region in region_revenue) total_revenue += region_revenue[region]
            
            printf "%-8s %-15s %-12s %-15s %-10s\n", "Region", "Total Revenue", "Deal Count", "Avg Deal Size", "Market %"
            printf "%-8s %-15s %-12s %-15s %-10s\n", "------", "-------------", "----------", "-------------", "--------"
            
            for(region in region_revenue) {
                avg_deal = region_revenue[region] / region_deals[region]
                market_pct = (region_revenue[region] / total_revenue) * 100
                printf "%-8s $%13.2f %12d $%13.2f %8.1f%%\n", region, region_revenue[region], region_deals[region], avg_deal, market_pct
            }
        }' "$combined_sales" | sort -k2 -nr
        
        echo ""
        
        echo "SERVER PERFORMANCE OUTLIERS:"
        echo "============================"
        echo "High CPU Usage (>90%):"
        awk -F',' 'NR>1 && $3 ~ /^[0-9]+(\.[0-9]+)?$/ && $3 > 90 {
            printf "  %-8s at %-19s: %5.1f%% CPU\n", $1, $2, $3
        }' "$SERVER_METRICS_FILE" | head -10
        
        echo ""
        echo "High Memory Usage (>90%):"
        awk -F',' 'NR>1 && $4 ~ /^[0-9]+(\.[0-9]+)?$/ && $4 > 90 {
            printf "  %-8s at %-19s: %5.1f%% Memory\n", $1, $2, $4
        }' "$SERVER_METRICS_FILE" | head -10
        
        echo ""
        echo "Critical Status Servers:"
        awk -F',' 'NR>1 && $6 == "critical" {
            printf "  %-8s at %-19s: CPU=%s%% MEM=%s%% DISK=%s%%\n", $1, $2, $3, $4, $5
        }' "$SERVER_METRICS_FILE"
        
        rm -f "$combined_sales"
        
    } > "$output_file"
    
    log_info "Trend Analysis Report generated: $output_file"
}

generate_data_quality_report() {
    log_info "Generating Data Quality Report..."
    
    local output_file="${REPORTS_DIR}/data_quality.txt"
    
    {
        echo "==============================================="
        echo "          DATA QUALITY REPORT"
        echo "==============================================="
        echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        echo "MISSING DATA ANALYSIS:"
        echo "====================="
        
        echo "Employees File:"
        local emp_total=$(tail -n +2 "$EMPLOYEES_FILE" | wc -l)
        echo "  Total records: $emp_total"
        echo "  Missing names: $(awk -F',' 'NR>1 && ($2 == "" || $2 == "NULL")' "$EMPLOYEES_FILE" | wc -l)"
        echo "  Missing departments: $(awk -F',' 'NR>1 && ($3 == "" || $3 == "NULL")' "$EMPLOYEES_FILE" | wc -l)"
        echo "  Missing salaries: $(awk -F',' 'NR>1 && ($4 == "" || $4 == "NULL" || $4 !~ /^[0-9]+(\.[0-9]+)?$/)' "$EMPLOYEES_FILE" | wc -l)"
        echo "  Missing hire dates: $(awk -F',' 'NR>1 && ($5 == "" || $5 == "NULL")' "$EMPLOYEES_FILE" | wc -l)"
        echo "  Missing manager IDs: $(awk -F',' 'NR>1 && ($6 == "" || $6 == "NULL")' "$EMPLOYEES_FILE" | wc -l)"
        
        echo ""
        echo "Sales Q1 File:"
        local q1_total=$(tail -n +2 "$SALES_Q1_FILE" | wc -l)
        echo "  Total records: $q1_total"
        echo "  Missing employee IDs: $(awk -F',' 'NR>1 && ($2 == "" || $2 == "NULL")' "$SALES_Q1_FILE" | wc -l)"
        echo "  Missing amounts: $(awk -F',' 'NR>1 && ($3 == "" || $3 == "NULL")' "$SALES_Q1_FILE" | wc -l)"
        echo "  Missing dates: $(awk -F',' 'NR>1 && ($4 == "" || $4 == "NULL")' "$SALES_Q1_FILE" | wc -l)"
        
        echo ""
        echo "Sales Q2 File:"
        local q2_total=$(tail -n +2 "$SALES_Q2_FILE" | wc -l)
        echo "  Total records: $q2_total"
        echo "  Missing employee IDs: $(awk -F',' 'NR>1 && ($2 == "" || $2 == "NULL")' "$SALES_Q2_FILE" | wc -l)"
        echo "  Missing amounts: $(awk -F',' 'NR>1 && ($3 == "" || $3 == "NULL")' "$SALES_Q2_FILE" | wc -l)"
        echo "  Missing dates: $(awk -F',' 'NR>1 && ($4 == "" || $4 == "NULL")' "$SALES_Q2_FILE" | wc -l)"
        
        echo ""
        echo "Server Metrics File:"
        local server_total=$(tail -n +2 "$SERVER_METRICS_FILE" | wc -l)
        echo "  Total records: $server_total"
        echo "  Missing server IDs: $(awk -F',' 'NR>1 && ($1 == "" || $1 == "NULL")' "$SERVER_METRICS_FILE" | wc -l)"
        echo "  Missing timestamps: $(awk -F',' 'NR>1 && ($2 == "" || $2 == "NULL")' "$SERVER_METRICS_FILE" | wc -l)"
        echo "  Missing CPU data: $(awk -F',' 'NR>1 && ($3 == "" || $3 == "NULL")' "$SERVER_METRICS_FILE" | wc -l)"
        
        echo ""
    
        echo "DUPLICATE RECORDS:"
        echo "=================="
        
        echo "Duplicate transactions (same transaction_id):"
        local combined_sales="/tmp/combined_sales_dup.csv"
        {
            tail -n +2 "$SALES_Q1_FILE"
            tail -n +2 "$SALES_Q2_FILE"
        } > "$combined_sales"
        
        awk -F',' '{count[$1]++} END {for(id in count) if(count[id] > 1) print "  " id ": " count[id] " occurrences"}' "$combined_sales"
        
        echo ""
        echo "Duplicate employee records (same employee_id):"
        awk -F',' 'NR>1 {count[$1]++} END {for(id in count) if(count[id] > 1) print "  " id ": " count[id] " occurrences"}' "$EMPLOYEES_FILE"
        
        echo ""
        
        echo "DATA VALIDATION ISSUES:"
        echo "======================="
        
        echo "Invalid dates:"
        {
            awk -F',' 'NR>1 && $5 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ && $5 != "" && $5 != "NULL" {print "  Employees: " $1 " - " $5}' "$EMPLOYEES_FILE"
            awk -F',' 'NR>1 && $4 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ && $4 != "" && $4 != "NULL" {print "  Sales Q1: " $1 " - " $4}' "$SALES_Q1_FILE"
            awk -F',' 'NR>1 && $4 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ && $4 != "" && $4 != "NULL" {print "  Sales Q2: " $1 " - " $4}' "$SALES_Q2_FILE"
        } | head -10
        
        echo ""
        echo "Negative amounts:"
        {
            awk -F',' 'NR>1 && $4 ~ /^-/ {print "  Employees salary: " $1 " - $" $4}' "$EMPLOYEES_FILE"
            awk -F',' 'NR>1 && $3 ~ /^-/ {print "  Sales Q1: " $1 " - $" $3}' "$SALES_Q1_FILE"
            awk -F',' 'NR>1 && $3 ~ /^-/ {print "  Sales Q2: " $1 " - $" $3}' "$SALES_Q2_FILE"
            awk -F',' 'NR>1 && ($3 ~ /^-/ || $4 ~ /^-/ || $5 ~ /^-/) {print "  Server metrics: " $1 " - CPU:" $3 " MEM:" $4 " DISK:" $5}' "$SERVER_METRICS_FILE"
        }
        
        echo ""
        echo "Invalid numeric values:"
        {
            awk -F',' 'NR>1 && $4 != "" && $4 != "NULL" && $4 !~ /^[0-9]+(\.[0-9]+)?$/ {print "  Employee salary: " $1 " - " $4}' "$EMPLOYEES_FILE"
            awk -F',' 'NR>1 && $3 != "" && $3 != "NULL" && $3 !~ /^[0-9]+(\.[0-9]+)?$/ {print "  Sales amount: " $1 " - " $3}' "$combined_sales"
        } | head -5
        
        echo ""
        
        echo "SUMMARY STATISTICS:"
        echo "=================="
        
        local total_records=$((emp_total + q1_total + q2_total + server_total))
        local valid_employees=$(awk -F',' 'NR>1 && $2 != "" && $3 != "" && $4 ~ /^[0-9]+(\.[0-9]+)?$/ && $4 > 0' "$EMPLOYEES_FILE" | wc -l)
        local valid_sales=$(awk -F',' '$2 != "" && $3 ~ /^[0-9]+(\.[0-9]+)?$/ && $3 > 0 && $4 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/' "$combined_sales" | wc -l)
        local valid_servers=$(awk -F',' 'NR>1 && $1 != "" && $2 != "" && $3 ~ /^[0-9]+(\.[0-9]+)?$/' "$SERVER_METRICS_FILE" | wc -l)
        
        echo "Total records processed: $total_records"
        echo "Valid employee records: $valid_employees / $emp_total ($(awk "BEGIN {printf \"%.1f\", $valid_employees/$emp_total*100}")%)"
        echo "Valid sales records: $valid_sales / $((q1_total + q2_total)) ($(awk "BEGIN {printf \"%.1f\", $valid_sales/($q1_total + $q2_total)*100}")%)"
        echo "Valid server records: $valid_servers / $server_total ($(awk "BEGIN {printf \"%.1f\", $valid_servers/$server_total*100}")%)"
        
        local overall_quality=$(awk "BEGIN {printf \"%.1f\", ($valid_employees + $valid_sales + $valid_servers)/$total_records*100}")
        echo "Overall data quality: ${overall_quality}%"
        
        rm -f "$combined_sales"
        
    } > "$output_file"
    
    log_info "Data Quality Report generated: $output_file"
}

main() {
    log_info "Starting CSV Data Processing Pipeline..."
    
    validate_input_files
    
    generate_top_performers_report
    generate_department_analysis_report
    generate_trend_analysis_report
    generate_data_quality_report
    
    log_info "All reports generated successfully in ${REPORTS_DIR}/"
    log_info "Processing completed in $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo ""
    echo "==============================================="
    echo "           PROCESSING SUMMARY"
    echo "==============================================="
    echo "Reports generated:"
    ls -la "${REPORTS_DIR}/"*.txt | awk '{printf "  %-30s %s\n", $9, $5 " bytes"}'
    echo ""
    echo "Processing completed successfully!"
}

main "$@"