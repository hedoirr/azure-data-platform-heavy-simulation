CREATE SCHEMA dim;
GO

CREATE SCHEMA fact;
GO

CREATE TABLE dim.dim_country (
    country_sk INT IDENTITY(1,1) PRIMARY KEY,
    country_code VARCHAR(10) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dim.dim_customer (
    customer_sk INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(200) NULL,
    country_code VARCHAR(10) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dim.dim_product (
    product_sk INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(200) NULL,
    category_name VARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dim.dim_date (
    date_sk INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year_num INT NOT NULL,
    month_num INT NOT NULL,
    day_num INT NOT NULL,
    month_name VARCHAR(20) NOT NULL
);
GO

CREATE TABLE fact.fact_sales (
    sales_sk BIGINT IDENTITY(1,1) PRIMARY KEY,
    date_sk INT NOT NULL,
    country_sk INT NOT NULL,
    customer_sk INT NOT NULL,
    product_sk INT NOT NULL,
    total_quantity INT NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL,
    sales_count INT NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_fact_sales_date FOREIGN KEY (date_sk) REFERENCES dim.dim_date(date_sk),
    CONSTRAINT FK_fact_sales_country FOREIGN KEY (country_sk) REFERENCES dim.dim_country(country_sk),
    CONSTRAINT FK_fact_sales_customer FOREIGN KEY (customer_sk) REFERENCES dim.dim_customer(customer_sk),
    CONSTRAINT FK_fact_sales_product FOREIGN KEY (product_sk) REFERENCES dim.dim_product(product_sk)
);
GO