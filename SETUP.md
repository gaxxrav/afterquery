CSV Data Processing Pipeline – Setup Guide

Prerequisites
	•	Docker installed and running

Quick Start
	1.	Build Docker container:

docker build -t csv-pipeline .

	2.	Run the assessment:

docker run --rm -v $(pwd):/workspace csv-pipeline

	3.	Run tests:

chmod +x run-tests.sh
./run-tests.sh

Project Structure

```text
csv-data-processing-pipeline/
├── solution.sh                  # Main solution script
├── run-tests.sh                 # Test execution script
├── data/                        # Sample CSV files
│   ├── employees.csv
│   ├── sales_q1.csv
│   ├── sales_q2.csv
│   └── server_metrics.csv
├── reports/                     # Generated output reports
│   ├── top_performers.txt
│   ├── department_analysis.txt
│   ├── trend_analysis.txt
│   └── data_quality.txt
└── tests/
    └── test_outputs.py          # Automated test suite
```

Required Reports
	1.	Top Performers Report (reports/top_performers.txt)
	•	Top 5 sales reps by total revenue
	•	Top 5 sales reps by number of deals closed
	•	Performance metrics per rep
	2.	Department Analysis (reports/department_analysis.txt)
	•	Average salary per department
	•	Employee count per department
	•	Department revenue contribution
	•	Salary distribution
	3.	Trend Analysis (reports/trend_analysis.txt)
	•	Monthly sales trends
	•	Regional performance comparison
	•	Server performance outliers
	4.	Data Quality Report (reports/data_quality.txt)
	•	Missing data detection
	•	Duplicate records
	•	Invalid dates or negative amounts
	•	Summary statistics

Tools to Use
	•	awk – processing, calculations, aggregation
	•	sed – data cleaning
	•	sort / uniq – ranking, deduplication
	•	join – combining CSVs
	•	grep – pattern validation
	•	cut – extracting fields
	•	Bash – loops, functions, conditionals

Running the Script

chmod +x solution.sh
./solution.sh

Optional: Run tests

./run-tests.sh

Notes
	•	Input CSVs are in data/
	•	Generated reports go in reports/
	•	Script must handle missing data, duplicates, invalid values, and malformed lines
	•	Runtime should be under 10 minutes