#!/bin/bash
# Generates realistic test data with controlled edge cases

set -euo pipefail

readonly DATA_DIR="data"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$DATA_DIR"

echo "Generating sample CSV datafiles..."

cat > "$DATA_DIR/employees.csv" << 'EOF'
employee_id,name,department,salary,hire_date,manager_id
1001,John Smith,Engineering,95000,2020-01-15,1050
1002,Sarah Johnson,Sales,75000,2019-03-22,1051
1003,Michael Brown,Marketing,68000,2021-07-10,1052
1004,Emily Davis,HR,72000,2018-11-05,1053
1005,David Wilson,Operations,65000,2020-09-18,1054
1006,Lisa Anderson,Engineering,88000,2019-06-12,1050
1007,Robert Taylor,Sales,82000,2020-02-28,1051
1008,Jennifer Martinez,Marketing,71000,2021-04-14,1052
1009,Christopher Lee,Engineering,92000,2018-08-30,1050
1010,Amanda White,HR,69000,2019-12-03,1053
1050,Victoria Torres,Engineering,125000,2015-01-10,
1051,Gregory Peterson,Sales,110000,2016-02-15,
1052,Melanie Gray,Marketing,105000,2016-08-20,
1053,Sean Ramirez,HR,108000,2015-11-12,
1054,Tiffany James,Operations,102000,2017-03-08,
1091,,Engineering,85000,2019-08-16,1050
1092,Rachel,Marketing,,2021-02-03,1052
1093,Justin Thompson,HR,72000,,1053
1094,Samantha White,Operations,65000,2020-12-29,
1095,Tyler Martinez,Sales,invalid,2019-05-15,1051
1096,Brittany Johnson,Engineering,93000,2021-13-40,1050
1097,Jonathan Davis,Marketing,68000,2020-02-30,1052
1098,Kayla Wilson,HR,-5000,2019-07-22,1053
1099,Austin Brown,Operations,67000,2021-04-31,1054
1100,Danielle Miller,Sales,80000,2018-02-29,1051
EOF

echo " Generated employees.csv (25 records with edge cases)"

# sales_q1.csv
cat > "$DATA_DIR/sales_q1.csv" << 'EOF'
transaction_id,employee_id,amount,date,region,product
T001,1002,15000,2024-01-05,North,Software
T002,1007,8500,2024-01-08,South,Hardware
T003,1012,12000,2024-01-10,East,Consulting
T004,1016,6500,2024-01-12,West,Support
T005,1021,18000,2024-01-15,North,Software
T146,9999,-2500,2024-01-15,North,Software
T147,1007,,2024-02-20,South,Hardware
T148,1012,15000,invalid-date,East,Consulting
T149,,12000,2024-03-25,West,Support
T150,1016,18000,2024-02-30,North,Software
EOF

echo "Generated sales_q1.csv (10 edge cases)"

# sales_q2.csv (includes duplicates)
cat > "$DATA_DIR/sales_q2.csv" << 'EOF'
transaction_id,employee_id,amount,date,region,product
T201,1002,16500,2024-04-02,North,Software
T202,1007,9200,2024-04-05,South,Hardware
T203,1012,13500,2024-04-08,East,Consulting
T204,1016,7800,2024-04-10,West,Support
T205,1021,19500,2024-04-12,North,Software
T001,1002,15000,2024-01-05,North,Software
T147,1007,,2024-05-20,South,Hardware
T348,9999,-3500,2024-04-15,East,Consulting
T349,,14000,2024-05-25,West,Support
T350,1016,20000,2024-06-31,North,Software
EOF

echo "Generated sales_q2.csv (10 records with duplicates and edge cases)"

# server_metrics.csv wiht performance data and outliers
cat > "$DATA_DIR/server_metrics.csv" << 'EOF'
server_id,timestamp,cpu_usage,memory_usage,disk_usage,status
WEB-01,2024-01-01 00:00:00,25.4,68.2,45.1,healthy
WEB-02,2024-01-01 00:00:00,32.1,72.5,52.3,healthy
DB-01,2024-01-01 00:00:00,45.8,85.2,78.9,healthy
DB-02,2024-01-01 00:00:00,38.9,79.1,65.4,healthy
APP-01,2024-01-01 00:00:00,28.7,64.3,41.2,healthy
APP-02,2024-01-01 00:00:00,35.2,71.8,48.7,healthy
WEB-01,2024-01-01 03:00:00,95.2,92.1,46.2,critical
DB-01,2024-01-01 06:00:00,98.7,96.4,80.3,critical
DB-02,2024-01-01 10:00:00,88.4,94.2,95.1,critical
APP-01,2024-01-01 14:00:00,92.8,89.3,43.4,critical
APP-02,2024-01-01 16:00:00,96.7,91.8,51.2,critical
,2024-01-01 21:00:00,25.2,68.9,44.8,healthy
WEB-02,2024-01-01 21:00:00,,72.4,53.2,healthy
DB-01,,47.1,85.6,79.4,healthy
DB-02,2024-01-01 21:00:00,40.7,invalid,66.8,healthy
APP-01,2024-01-01 21:00:00,28.4,-15.2,41.5,error
APP-02,2024-01-01 21:00:00,35.7,74.8,150.3,warning
EOF

echo "Generated server_metrics.csv (17 records with outliers and edge cases)"

echo ""
echo "Sample data generation completed!"
echo "Files created in $DATA_DIR/:"
ls -la "$DATA_DIR"/*.csv

echo ""
echo "Edge cases included:"
echo "- Missing employee names and departments"
echo "- Invalid salary values (negative, non-numeric)"
echo "- Invalid dates (Feb 30, month 13, etc.)"
echo "- Duplicate transaction IDs across files"
echo "- Missing employee IDs in sales data"
echo "- Server performance outliers (>90% CPU/Memory)"
echo "- Critical server status entries"
echo "- Missing server IDs and timestamps"
echo "- Invalid numeric values in server metrics"
