# AfterQuery Assessment Task - CSV Data Processing Pipeline

- simulates a real world business data analysis challenge. 
- process multiple CSV files containing employee data, sales records, and server metrics.
- generate summary reports using bash and unix tools

## Scenario

youre receiving monthly CSV exports from:
- **HR System**: Employee data (departments, salaries, hire dates)
- **Sales CRM**: Sales transactions (rep, amount, date, region)
- **Server Monitoring**: Performance metrics (CPU, memory, disk usage)

## Setup Instructions

### Prerequisites
- have docker installed on your system

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/gaxxrav/afterquery.git
   cd csv-data-processing-pipeline
   ```

2. **Build the Docker container:**
   ```bash
   docker build -t csv-pipeline .
   ```

3. **Run main:**
   ```bash
   docker run --rm -v $(pwd):/workspace csv-pipeline
   ```

4. **Run tests:**
   ```bash
   ./run-tests.sh
   ```

- `solution.sh` script processes the provided CSV files and generates four comprehensive reports:

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

The generated CSV files are in the `data/` directory:

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
- Clean adn formatted reports (plain text)
- Consistent structure for automated testing
- handles edge cases well

### Performance Requirements
- fast runtime
- no privileged Docker flags required
- deterministic outputs (same input = same output)
- self-contained (no internet access required)

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
├── solution.sh           
├── run-tests.sh
├── data/
│   ├── employees.csv
│   ├── sales_q1.csv
│   ├── sales_q2.csv
│   └── server_metrics.csv
├── tests/
│   └── test_outputs.py
├── expected_reports/
│   ├── top_performers.txt
│   ├── department_analysis.txt
│   ├── trend_analysis.txt
│   └── data_quality.txt
└── scripts/
    └── generate_sample_data.sh
```