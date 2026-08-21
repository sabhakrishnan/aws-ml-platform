import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions

from pyspark.context import SparkContext
from pyspark.sql.functions import col


args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

job = Job(glue_context)
job.init(args["JOB_NAME"], args)


# ---------------------------------------------------------
# 1. Read raw data from Glue Catalog
# ---------------------------------------------------------

raw_dynamic_frame = glue_context.create_dynamic_frame.from_catalog(
    database="aws_ml_platform",
    table_name="raw",
)

raw_df = raw_dynamic_frame.toDF()


# ---------------------------------------------------------
# 2. Data quality filtering
# ---------------------------------------------------------

clean_df = (
    raw_df
    .filter(col("instant").isNotNull())
    .dropDuplicates(["instant"])
)


# ---------------------------------------------------------
# 3. Write curated dataset
# ---------------------------------------------------------

clean_df.write \
    .mode("overwrite") \
    .parquet(
        "s3://aws-ml-platform-bucket-c40fb655/curated/hour/"
    )


job.commit()