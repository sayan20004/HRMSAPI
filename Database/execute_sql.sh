#!/bin/bash

# Execute SQL Script to create Functions and Stored Procedures
# This script will connect to SQL Server and execute StoredProceduresAndFunctions.sql

echo "Connecting to SQL Server and executing StoredProceduresAndFunctions.sql..."

/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P 'StrongPass@123' -d HRMSDB -i StoredProceduresAndFunctions.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SQL script executed successfully!"
    echo "✅ All functions and stored procedures have been created."
    echo ""
    echo "You can now restart your API with: dotnet run"
else
    echo ""
    echo "❌ Error executing SQL script. Please check the error messages above."
fi
