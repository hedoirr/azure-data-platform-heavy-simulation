# Databricks notebook source
from pyspark.sql import functions as F

country_code = dbutils.widgets.get("country_code") if "country_code" in [w.name for w in dbutils.widgets.get()] else "FR"

silver_path = f"abfss://silver@storageaccount.dfs.core.windows.net/sales/{country_code}/"
gold_path = f"abfss://gold@storageaccount.dfs.core.windows.net/sales/{country_code}/"

df = spark.read.format("delta").load(silver_path)

gold_df = (
    df.groupBy(
        "country_code",
        "sale_date",
        "customer_id",
        "product_id"
    )
    .agg(
        F.sum("quantity").alias("total_quantity"),
        F.sum("amount").alias("total_amount"),
        F.countDistinct("sale_id").alias("sales_count")
    )
    .withColumn("gold_load_ts", F.current_timestamp())
)

(
    gold_df.write
    .format("delta")
    .mode("overwrite")
    .option("overwriteSchema", "true")
    .save(gold_path)
)

spark.sql(f"""
    CREATE TABLE IF NOT EXISTS gold.sales_gold_{country_code}
    USING DELTA
    LOCATION '{gold_path}'
""")