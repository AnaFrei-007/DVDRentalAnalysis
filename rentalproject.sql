-- USER-DEFINED FUNCTION/TRANSFORMATION
CREATE OR REPLACE FUNCTION transform_active_status(status BOOLEAN)
RETURNS TEXT AS $$
BEGIN
    IF status THEN
        RETURN 'Active';
    ELSE
        RETURN 'Inactive';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- TEST FUNCTION
SELECT transform_active_status('true'); --returns ‘Active’

-- DROP TABLES
DROP TABLE top_10_detailed;
DROP TABLE top_10_summary;

-- CREATE A DETAILED TABLE
CREATE TABLE top_10_detailed (
customer_id INTEGER NOT NULL,
customer_name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL,
rental_id INTEGER NOT NULL,
rental_date DATE NOT NULL,
amount DECIMAL(10, 2) NOT NULL,
payment_date DATE NOT NULL,
active_status VARCHAR(10) NOT NULL,
PRIMARY KEY (customer_id, rental_id)
);

-- CREATE A SUMMARY TABLE
CREATE TABLE top_10_summary (
customer_id INTEGER PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
total_rental_spending DECIMAL(10, 2) NOT NULL,
total_number_of_rentals INTEGER NOT NULL,
last_rental_date DATE NOT NULL,
active_status VARCHAR(10) NOT NULL
);

SELECT * FROM top_10_detailed;
SELECT * FROM top_10_summary;

-- CREATE A TRIGGER FUNCTION
DROP FUNCTION populate_summary_table();

CREATE OR REPLACE FUNCTION populate_summary_table()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM top_10_summary;
    INSERT INTO top_10_summary (
        customer_id,
        customer_name,
        total_rental_spending,
        total_number_of_rentals,
        last_rental_date,
        active_status
    )
    SELECT
        d.customer_id,
        d.customer_name,
        SUM(d.amount) AS total_rental_spending,
        COUNT(d.rental_id) AS total_number_of_rentals,
        MAX(d.rental_date) AS last_rental_date,
        d.active_status
    FROM
        top_10_detailed d
    GROUP BY
        d.customer_id,
        d.customer_name,
        d.active_status
    ORDER BY
        total_rental_spending DESC
    LIMIT 10;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_summary ON top_10_detailed;

CREATE TRIGGER update_summary
AFTER INSERT OR UPDATE OR DELETE
ON top_10_detailed
FOR EACH STATEMENT
EXECUTE FUNCTION populate_summary_table();

-- POPULATE DETAILED TABLE
INSERT INTO top_10_detailed (customer_id, customer_name, email, rental_id, rental_date, amount, payment_date, active_status)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    r.rental_id,
    r.rental_date,
    p.amount,
    p.payment_date,
    transform_active_status(c.activebool) AS active_status
FROM
    customer c
JOIN
    payment p ON c.customer_id = p.customer_id
JOIN
    rental r ON p.rental_id = r.rental_id
WHERE
    c.customer_id IN (
        SELECT customer_id
        FROM payment
        GROUP BY customer_id
        ORDER BY SUM(amount) DESC
        LIMIT 10);

SELECT * FROM top_10_detailed; --Returns 384 rows, 10 customers and all of their rentals
SELECT * FROM top_10_summary; --Returns 10 rows, Eleanor Hunt is top customer

--INSERT ROWS
INSERT INTO top_10_detailed
VALUES (999, 'Jane Doe','jane.doe@sakilacustomer.org',9999,'2000-01-01',2000.00,'2000-02-02','Active');

SELECT * FROM top_10_detailed; --Returns 385 rows
SELECT * FROM top_10_summary; --Jane Doe is top customer

-- CREATE A REFRESH TABLES STORED PROCEDURE
CREATE OR REPLACE PROCEDURE refresh_customer_data()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM top_10_detailed;
    INSERT INTO top_10_detailed (
        customer_id,
        customer_name,
        email,
        rental_id,
        rental_date,
        amount,
        payment_date,
        active_status
    )
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.email,
        r.rental_id,
        r.rental_date,
        p.amount,
        p.payment_date,
        transform_active_status(c.activebool) AS active_status
    FROM
        customer c
    JOIN
        payment p ON c.customer_id = p.customer_id
    JOIN
        rental r ON p.rental_id = r.rental_id
    WHERE
        c.customer_id IN (
            SELECT customer_id
            FROM payment
            GROUP BY customer_id
            ORDER BY SUM(amount) DESC
            LIMIT 10
        );
END;
$$;

CALL refresh_customer_data();

SELECT * FROM top_10_detailed; -- Returns 384 rows
SELECT * FROM top_10_summary; -- Eleanor Hunt as n.1 customer



