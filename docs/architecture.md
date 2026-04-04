# Architecture Overview

## Business Context

This project simulates a multinational sales analytics platform, initially deployed for one country and designed for replication across additional countries.

## Core Principles

- modular ingestion
- medallion architecture
- scalability by parameterization
- environment isolation
- data quality and traceability

## Layers

### Bronze
Raw files ingested from source systems without business transformation.

### Silver
Cleansed and standardized data:
- data type normalization
- null handling
- deduplication
- business key validation

### Gold
Business-ready curated datasets:
- enrichment
- KPI-ready structures
- dimensional alignment

## Main Services

- Azure Data Factory for orchestration
- ADLS Gen2 for storage
- Azure Databricks for transformations
- Azure SQL layer for dimensional serving
- Azure DevOps for deployment

## Replication Strategy

Country-specific parameters:
- country_code
- source_path
- sink_path
- watermark column
- schedule