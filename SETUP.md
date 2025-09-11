# CSV Data Processing Pipeline - Complete Setup Guide

## Overview

This is a complete AfterQuery Bash/Linux assessment task for CSV Data Processing Pipeline. Everything is built from scratch and ready for submission to the AfterQuery assessment portal.

## Prerequisites

- **Docker** installed and running
- **Git** (for version control)
- **Basic terminal/command line knowledge**

## Quick Start (5 minutes)

1. **Navigate to project directory:**
   ```bash
   cd /Users/gaurav/CascadeProjects/csv-data-processing-pipeline
   ```

2. **Build Docker container:**
   ```bash
   docker build -t csv-pipeline .
   ```

3. **Run the assessment:**
   ```bash
   docker run --rm -v $(pwd):/workspace csv-pipeline
   ```

4. **Run comprehensive tests:**
   ```bash
   chmod +x run-tests.sh
   ./run-tests.sh
   ```

## Project Structure

```
csv-data-processing-pipeline/
├── README.md                    # Main documentation
├── SETUP.md                     # This setup guide
├── task.yaml                    # AfterQuery task configuration
├── Dockerfile                   # Container configuration
├── docker-compose.yml           # Multi-container setup
├── solution.sh                  # Main solution script (IMPLEMENT THIS)
├── run-tests.sh                 # Test execution script
├── data/                        # Sample CSV data files
│   ├── employees.csv            # Employee records (100+ entries)
│   ├── sales_q1.csv            # Q1 sales data (150+ entries)
│   ├── sales_q2.csv            # Q2 sales data (150+ entries)
│   └── server_metrics.csv      # Server performance data (120+ entries)
├── tests/                       # Comprehensive test suite
│   └── test_outputs.py         # 10 automated test cases
├── reports/                     # Generated output reports
│   ├── top_performers.txt      # Top sales performers analysis
│   ├── department_analysis.txt # Department metrics and statistics
│   ├── trend_analysis.txt      # Monthly trends and regional performance
│   └── data_quality.txt        # Data validation and quality report
├── scripts/                     # Helper utilities
│   └── generate_sample_data.sh # Data generation script
└── test_results/               # Test execution results
    ├── test_summary.txt        # Test execution summary
    ├── test_results.xml        # JUnit XML results
    └── test_failures.txt       # Failure analysis (if any)
```

## Task Requirements

### Business Scenario
You're a systems administrator processing monthly CSV exports from:
- **HR System**: Employee data (departments, salaries, hire dates)
- **Sales CRM**: Sales transactions (rep, amount, date, region)
- **Server Monitoring**: Performance metrics (CPU, memory, disk usage)

### Required Reports

1. **Top Performers Report** (`reports/top_performers.txt`)
   - Top 5 sales reps by total revenue
   - Top 5 sales reps by number of deals closed
   - Performance metrics per rep

2. **Department Analysis** (`reports/department_analysis.txt`)
   - Average salary by department
   - Employee count per department
   - Department revenue contribution
   - Salary distribution statistics

3. **Trend Analysis** (`reports/trend_analysis.txt`)
   - Monthly sales trends (growth/decline)
   - Regional performance comparison
   - Server performance outliers (high CPU/memory)

4. **Data Quality Report** (`reports/data_quality.txt`)
   - Missing data detection and count
   - Duplicate record identification
   - Data validation (invalid dates, negative amounts)
   - Summary statistics

### Technical Requirements

**Tools to Demonstrate:**
- `awk`: Field processing, calculations, aggregations
- `sed`: Data cleaning, format standardization
- `sort/uniq`: Ranking, deduplication
- `join`: Combining multiple CSV files
- `grep`: Pattern matching, validation
- `cut`: Field extraction
- Standard Bash: loops, conditionals, functions

**Performance Requirements:**
- Runtime under 10 minutes
- No privileged Docker flags
- Deterministic outputs
- Self-contained (no internet access)

## Implementation Guide

### Step 1: Understand the Data

Examine the sample data files:
```bash
head -5 data/employees.csv
head -5 data/sales_q1.csv
head -5 data/sales_q2.csv
head -5 data/server_metrics.csv
```

### Step 2: Implement solution.sh

The `solution.sh` script is already provided as a reference implementation demonstrating expert-level Bash skills. Key features:

- **Robust error handling** with `set -euo pipefail`
- **Modular functions** for each report type
- **Advanced awk patterns** for data processing
- **Proper CSV handling** including edge cases
- **Performance optimization** with efficient algorithms
- **Comprehensive logging** and progress tracking

### Step 3: Test Your Implementation

Run the comprehensive test suite:
```bash
./run-tests.sh
```

The test suite includes 10 automated tests covering:
- Revenue calculations accuracy
- Department analysis correctness
- Missing data detection
- Duplicate record handling
- Monthly trend analysis
- Output format consistency
- Server performance outliers
- Regional analysis
- Data validation
- Summary statistics

### Step 4: Validate Performance

Check that your solution meets requirements:
- Execution time < 10 minutes
- Memory usage < 512MB
- All reports generated correctly
- Deterministic output
- Proper edge case handling

## Docker Usage

### Basic Usage
```bash
# Build container
docker build -t csv-pipeline .

# Run solution
docker run --rm -v $(pwd):/workspace csv-pipeline

# Run with custom command
docker run --rm -v $(pwd):/workspace csv-pipeline ./run-tests.sh
```

### Using Docker Compose
```bash
# Run solution
docker-compose up csv-pipeline

# Run tests
docker-compose up test-runner

# Clean up
docker-compose down
```

## Testing and Validation

### Manual Testing
```bash
# Run solution manually
./solution.sh

# Check generated reports
ls -la reports/
cat reports/top_performers.txt
```

### Automated Testing
```bash
# Full test suite
./run-tests.sh

# Individual test file
python3 -m pytest tests/test_outputs.py -v

# Specific test
python3 -m pytest tests/test_outputs.py::TestCSVPipeline::test_top_sales_reps_by_revenue -v
```

### Performance Testing
```bash
# Time execution
time ./solution.sh

# Memory usage monitoring
/usr/bin/time -v ./solution.sh
```

## Edge Cases Handled

The sample data includes realistic edge cases:

**Employee Data:**
- Missing names and departments
- Invalid salary values (negative, non-numeric)
- Missing hire dates and manager IDs

**Sales Data:**
- Invalid date formats (Feb 30, month 13)
- Negative transaction amounts
- Missing employee IDs
- Duplicate transaction IDs across files

**Server Data:**
- Performance outliers (>90% CPU/Memory)
- Critical server status entries
- Missing server IDs and timestamps
- Invalid numeric values

## Troubleshooting

### Common Issues

**Docker build fails:**
```bash
# Ensure Docker is running
docker --version

# Clean Docker cache
docker system prune -f

# Rebuild without cache
docker build --no-cache -t csv-pipeline .
```

**Permission errors:**
```bash
# Make scripts executable
chmod +x solution.sh run-tests.sh scripts/generate_sample_data.sh

# Fix ownership (if needed)
sudo chown -R $USER:$USER .
```

**Tests fail:**
```bash
# Check solution output
./solution.sh
ls -la reports/

# Run individual tests
python3 -m pytest tests/test_outputs.py::TestCSVPipeline::test_output_format_consistency -v

# Check test logs
cat test_results/test_failures.txt
```

**Performance issues:**
```bash
# Profile execution
bash -x solution.sh 2>&1 | head -50

# Check resource usage
docker stats csv-data-processor
```

## Submission Checklist

- [ ] All CSV data files present and valid
- [ ] solution.sh implements all required functionality
- [ ] All 4 reports generated correctly
- [ ] All 10 tests pass
- [ ] Docker container builds and runs successfully
- [ ] Performance requirements met (< 10 minutes)
- [ ] Edge cases handled properly
- [ ] Output format consistent and professional
- [ ] No external dependencies or internet access required

## Assessment Criteria

Your solution will be evaluated on:

1. **Correctness (40%)**: Accurate data processing and calculations
2. **Code Quality (20%)**: Clean, readable, well-documented Bash code
3. **Performance (15%)**: Efficient processing of large datasets
4. **Edge Case Handling (15%)**: Robust error handling and data validation
5. **Tool Usage (10%)**: Effective use of Unix/Linux command-line tools

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review test failure logs in `test_results/`
3. Examine sample solution implementation
4. Validate Docker environment setup
5. Ensure all required files are present

## Final Notes

This assessment task is designed to test expert-level Bash scripting and Unix tool usage in a realistic business scenario. The provided solution demonstrates best practices and can serve as a reference implementation.

Good luck with your assessment! 🚀
