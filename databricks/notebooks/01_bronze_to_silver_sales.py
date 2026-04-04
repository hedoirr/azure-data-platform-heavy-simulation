# Databricks notebook source
from pyspark.sql import functions as F
from pyspark.sql.window import Window

country_code = dbutils.widgets.get("country_code") if "country_code" in [w.name for w in dbutils.widgets.get()] else "FR"

bronze_path = f"abfss://bronze@storageaccount.dfs.core.windows.net/sales/{country_code}/"
silver_path = f"abfss://silver@storageaccount.dfs.core.windows.net/sales/{country_code}/"

df = (
    spark.read
    .option("header", True)
    .option("inferSchema", True)
    .csv(bronze_path)
)

# Standardization
df_clean = (
    df
    .withColumn("country_code", F.lit(country_code))
    .withColumn("sale_date", F.to_date("sale_date"))
    .withColumn("amount", F.col("amount").cast("decimal(18,2)"))
    .withColumn("quantity", F.col("quantity").cast("int"))
    .withColumn("customer_id", F.trim(F.col("customer_id")))
    .withColumn("product_id", F.trim(F.col("product_id")))
    .withColumn("ingestion_ts", F.current_timestamp())
    .dropDuplicates(["sale_id"])
)

# Basic data quality filter
df_valid = (
    df_clean
    .filter(F.col("sale_id").isNotNull())
    .filter(F.col("customer_id").isNotNull())
    .filter(F.col("product_id").isNotNull())
    .filter(F.col("sale_date").isNotNull())
)

(
    df_valid.write
    .format("delta")
    .mode("overwrite")
    .option("overwriteSchema", "true")
    .save(silver_path)
)

spark.sql(f"""
    CREATE TABLE IF NOT EXISTS silver.sales_{country_code}
    USING DELTA
    LOCATION '{silver_path}'
""")