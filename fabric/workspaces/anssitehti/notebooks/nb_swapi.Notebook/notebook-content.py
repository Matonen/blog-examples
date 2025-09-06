# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "e82b6e09-4d54-4e69-93b0-a86bdffa0ba6",
# META       "default_lakehouse_name": "lh_anssitehti",
# META       "default_lakehouse_workspace_id": "918ad2ba-c5c6-4621-9a14-8b9444185097",
# META       "known_lakehouses": [
# META         {
# META           "id": "e82b6e09-4d54-4e69-93b0-a86bdffa0ba6"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

import requests

# Fetch planets data from SWAPI
response = requests.get("https://swapi.info/api/planets")
response.raise_for_status()
planets = response.json()

print(f"Fetched {len(planets)} planets from SWAPI")



# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.createDataFrame(planets)
df.write.format("delta").mode("overwrite").saveAsTable("planets")

display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
