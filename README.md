# INST 327 Group Project Scripts
A SQL script to import CSV data for INST 327 Group Project.

## Local Setup 

### Add configuration to SQL Workbench 8.0

SQL Workbench 8.0 blocks the import of local files by default. To rectify this, we need to add a simple configuration to the connection settings: 

### `OPT_LOCAL_INFILE=1`

### Step 1:

![Step 1](https://inst-327-gp.s3.us-east-1.amazonaws.com/step+1.png "Step 1")

### Step 2:
![Step 2](https://inst-327-gp.s3.us-east-1.amazonaws.com/step+2.png "Step 2")

## Running 

### Replace placeholder path with full local path to the csv file.
```SQL
-- Replace placeholder file path with your local file path.
LOAD DATA LOCAL INFILE "Full File Path/Chicago Traffic Citations.csv"  -- <- File Path Here
INTO TABLE citations
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
...
```

### Run SQL Script in SQL Workbench 8.0

  MacOS: `CMD + SHIFT + RETURN`\
  Windows: `CTRL + SHIFT + ENTER`
