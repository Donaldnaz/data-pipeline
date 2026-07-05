import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'database', 'dest_path'])
sc = SparkContext()
glueContext = GlueContext(sc)
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

tables = {
    'iran_war_oil_prices_daily_2026': {'partitionKeys': ['phase']},
    'iran_war_gas_prices_by_state':   {'partitionKeys': ['region']},
    'iran_war_key_events_timeline':   {'partitionKeys': ['category']},
}

for table_name, opts in tables.items():
    frame = glueContext.create_dynamic_frame.from_catalog(
        database=args['database'],
        table_name=table_name,
        transformation_ctx=table_name
    )
    glueContext.write_dynamic_frame.from_options(
        frame=frame,
        connection_type="s3",
        connection_options={
            "path": args['dest_path'] + "/" + table_name + "/",
            "partitionKeys": opts['partitionKeys']
        },
        format="parquet",
        transformation_ctx=table_name + "_sink"
    )

job.commit()
