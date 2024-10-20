# DVD Rental Analysis Project

This project uses a DVD rental sample database included in the dataset folder. The main objective of this project was to summarize a business report using the database and analyze the data to directly answer a business question.

### PROGRAMMING ENVIRONMENT:
- **OPERATING SYSTEM:** Windows 11
- **PROGRAMMING LANGUAGE:** SQL
- **RELATIONAL DBMS:** PostgreSQL 17
- **GUI:** pgAdmin4
- **DATABASE:** dvdrental

### Methods and Techniques:
- **Transformations:** Converted boolean status values into more readable text labels (e.g., 'Active' or 'Inactive') to make the data easier to interpret.
- **Functions:** Used custom SQL functions to calculate specific metrics such as total rental spending and populate the summary table.
- **Stored Procedures:** Implemented a stored procedure to 'refresh' the data in a summary data table.
- **Joins:** Utilized joins to combine data from multiple tables (customer, rental, and payment).
- **Aggregations:** Employed aggregation functions (SUM, COUNT, MAX) to derive insights from the data.

### Business Report:
A DVD rental business would like to identify who their top 10 customers are based on their total rental spending in order to target marketing and promotional offers. By identifying these high-value customers, the business can offer loyalty rewards, personalized recommendations, improve retention, and benchmark the effectiveness of any marketing campaigns. I will be querying the customer, payment, and rental tables to calculate the total amount spent by each customer and rank them.

### Business Question:
Who are the top 10 customers based on total rental spending?
