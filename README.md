# CSV Data Processing Pipeline - AfterQuery Assessment Task

## Overview

This is a comprehensive Bash/Linux assessment task that simulates a real-world business data analysis challenge. You'll process multiple CSV files containing employee data, sales records, and server metrics to generate executive summary reports using Bash and standard Unix tools.

## Business Scenario

You're a systems administrator at a mid-size company receiving monthly CSV exports from:
- **HR System**: Employee data (departments, salaries, hire dates)
- **Sales CRM**: Sales transactions (rep, amount, date, region)
- **Server Monitoring**: Performance metrics (CPU, memory, disk usage)

## Setup Instructions

### Prerequisites
- have docker installed on your system

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd csv-data-processing-pipeline
   ```

2. **Build the Docker container:**
   ```bash
   docker build -t csv-pipeline .
   ```

3. **Run the assessment:**
   ```bash
   docker run --rm -v $(pwd):/workspace csv-pipeline
   ```

4. **Run tests:**
   ```bash
   ./run-tests.sh
   ```

## Task Requirements

Create a `solution.sh` script that processes the provided CSV files and generates four comprehensive reports:

### 1. Top Performers Report
- Top 5 sales reps by total revenue
- Top 5 sales reps by number of deals closed
- Performance metrics per rep

### 2. Department Analysis
- Average salary by department
- Employee count per department
- Department revenue contribution
- Salary distribution statistics

### 3. Trend Analysis
- Monthly sales trends (growth/decline)
- Regional performance comparison
- Server performance outliers (high CPU/memory)

### 4. Data Quality Report
- Missing data detection and count
- Duplicate record identification
- Data validation (invalid dates, negative amounts)
- Summary statistics

## Data Files

The following CSV files are provided in the `data/` directory:

- `employees.csv`: Employee information (100 records)
- `sales_q1.csv`: Q1 sales transactions (150 records)
- `sales_q2.csv`: Q2 sales transactions (150 records)
- `server_metrics.csv`: Server performance data (120 records)

## Technical Requirements

### Tools to Demonstrate
- **awk**: Field processing, calculations, aggregations
- **sed**: Data cleaning, format standardization
- **sort/uniq**: Ranking, deduplication
- **join**: Combining multiple CSV files
- **grep**: Pattern matching, validation
- **cut**: Field extraction
- **Standard Bash**: loops, conditionals, functions

### Output Format
- Clean, formatted reports (plain text or CSV)
- Consistent structure for automated testing
- Clear headers and summaries
- Graceful handling of edge cases

### Performance Requirements
- Runtime under 10 minutes
- No privileged Docker flags required
- Deterministic outputs (same input = same output)
- Self-contained (no internet access required)

## Testing

The assessment includes a comprehensive test suite with 7 automated tests:

1. `test_top_sales_reps_by_revenue()` - Revenue calculations and ranking
2. `test_department_salary_averages()` - Mathematical accuracy of averages
3. `test_missing_data_detection()` - Edge case handling for empty/null fields
4. `test_duplicate_transaction_removal()` - Data quality validation
5. `test_monthly_trend_analysis()` - Date parsing and grouping accuracy
6. `test_output_format_consistency()` - Standardized report format
7. `test_server_performance_outliers()` - Statistical analysis accuracy

## Project Structure

```
csv-data-processing-pipeline/
├── README.md
├── task.yaml
├── Dockerfile
├── docker-compose.yml
├── solution.sh                 # Your implementation goes here
├── run-tests.sh
├── data/
│   ├── employees.csv
│   ├── sales_q1.csv
│   ├── sales_q2.csv
│   └── server_metrics.csv
├── tests/
│   └── test_outputs.py
├── expected_outputs/
│   ├── top_performers.txt
│   ├── department_analysis.txt
│   ├── trend_analysis.txt
│   └── data_quality.txt
└── scripts/
    └── generate_sample_data.sh
```

## Edge Cases to Handle

Your solution should gracefully handle:
- Malformed CSV lines
- Missing employee records in sales data
- Invalid date formats
- Negative sales amounts
- Duplicate transactions
- Empty fields
- Inconsistent field separators

## Submission Guidelines

1. Implement your solution in `solution.sh`
2. Ensure all tests pass: `./run-tests.sh`
3. Verify Docker container runs successfully
4. Check that outputs match expected format
5. Test with edge cases and malformed data

## Troubleshooting

### Common Issues

**Docker build fails:**
- Ensure Docker is running
- Check Dockerfile syntax
- Verify base image availability

**Tests fail:**
- Check output format matches expected structure
- Verify CSV parsing handles edge cases
- Ensure mathematical calculations are accurate

**Performance issues:**
- Optimize awk/sed patterns
- Use efficient sorting algorithms
- Minimize file I/O operations

**Permission errors:**
- Ensure scripts are executable: `chmod +x solution.sh run-tests.sh`
- Check Docker volume mounting permissions

## Assessment Criteria

Your solution will be evaluated on:
- **Correctness**: Accurate data processing and calculations
- **Code Quality**: Clean, readable, well-documented Bash code
- **Performance**: Efficient processing of large datasets
- **Edge Case Handling**: Robust error handling and data validation
- **Tool Usage**: Effective use of Unix/Linux command-line tools
- **Output Format**: Professional, consistent report formatting

Good luck with your assessment!
