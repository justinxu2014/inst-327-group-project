# INST 327 Group Project Scripts

Scripts and assets for INST 327 group project.

## Local Setup 

<details> 
  <summary>Guide to Git Installation and Github</summary> 

  * <details> 
      <summary>MacOS (> Mavericks 10.9)</summary>

      #### Git installation

      * Run git command `git --version` in terminal
        ```zsh
        git --version
        ```

      #### Clone Repository 
      
      * Navigate to directory in terminal using the `cd <directory path>` command
        ```zsh
        cd desktop
        ```
      * Run git command `git clone <repository url>` in terminal
        ```zsh 
        git clone https://github.com/justinxu2014/inst-327-group-project.git
        ```
      </details>
  * <details >
      <summary>Windows</summary>

      #### Git installation
      * Download and run installer from: https://git-scm.com/downloads/win

      #### Clone Repository 
      
      * Navigate to directory in command prompt(CMD) using `cd <directory path>` command
        ```console
        cd desktop
        ```
      * Run git command `git clone <repository url>` in command promt(CMD)
        ```console 
        git clone https://github.com/justinxu2014/inst-327-group-project.git
        ```
    </details>
</details>

### Add configuration to SQL Workbench 8.0

SQL Workbench 8.0 blocks the import of local files by default. To rectify this, we need to add a simple configuration to the connection settings: 

### `OPT_LOCAL_INFILE=1`

### Step 1:

![Step 1](https://inst-327-gp.s3.us-east-1.amazonaws.com/step+1.png "Step 1")

### Step 2:
![Step 2](https://inst-327-gp.s3.us-east-1.amazonaws.com/step+2.png "Step 2")

## Unnormalized DB Creation

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

### Run `DB Creation.sql` in SQL Workbench 8.0

  MacOS: `CMD + SHIFT + RETURN`\
  Windows: `CTRL + SHIFT + ENTER`

## Normalized DB Creation 

### Run `DB Normalize.sql` in SQL Workbench 8.0 after unnormalized DB initalization

MacOS: `CMD + SHIFT + RETURN`\
Windows: `CTRL + SHIFT + ENTER`

## Dataset Dictionary

* `notice_number`: a unique ID attached to the notice, if one was sent.
* `ticket_number`: a unique ID for each citation
* `issue_date`: date and time the ticket was issued
* `location`: street address where the ticket was issued
* `zip_code`: the ZIP code associated with the vehicle registration
* `violation_code`: municipal code associated with violation; these have changed slightly over time
* `violation_description`: name of violation
* `unit`: This number relates to subcategories within units, such as police precincts or private contractors. A file with a unit crosswalk obtained from the Department of Finance is included in the data download.
* `unit_description`: the agency that issued the ticket, typically “CPD” for Chicago Police Department or “DOF” for Department of Finance, which can include subcontractors.
* `officer`: a unique ID for the specific police officer or parking enforcement aide who issued the ticket.
* `vehicle_make`: vehicle make
* `license_plate_type`: the vast majority of license plates are for passenger vehicles. But also included are trucks, temporary plates and taxi cabs, among many others.
* `fine_1`: original cost of citation
* `fine_2`: price of citation plus any late penalties or collections fees. Unpaid tickets can double in price and accrue a 22-percent collection charge.
* `current_due`: total amount due for that citation and any related late penalties when data was last updated.
* `total_payments`: total amount paid for ticket and associated penalties when data was last updated.
* `ticket_queue`: This category describes the most recent status of the ticket. These are marked “Paid” if the ticket was paid; “Dismissed” if the ticket was dismissed, (either internally or as a result of an appeal); “Hearing Req” if the ticket was contested and awaiting a hearing at the time the data was pulled; “Notice” if the ticket was not yet paid and the city sent a notice to the address on file for that vehicle; “Court” if the ticket is involved in some sort of court case, not including bankruptcy; “Bankruptcy” if the ticket was unpaid and included as a debt in a consumer bankruptcy case; and “Define” if the city cannot identify the vehicle owner and collect on a debt.
* `ticket_queue_date`: when the “ticket_queue” was last updated.
* `notice_level`: This field describes the type of notice the city has sent a motorist. The types of notices include: “VIOL,” which means a notice of violation was sent; “SEIZ” indicates the vehicle is on the city’s boot list; “DETR” indicates a hearing officer found the vehicle owner was found liable for the citation; “FINL” indicates the unpaid ticket was sent to collections; and “DLS” means the city intends to seek a license suspension. If the field is blank, no notice was sent. 
* `hearing_dispo`: outcome of a hearing, either “Liable” or “Not Liable.” If the ticket was not contested this field is blank.
* `hearing_reason`: The reason given for the hearing.

[Source](https://github.com/propublica/il-tickets-notebooks/blob/master/README.md)

## DB Design Diagram 

![ERD Diagram](https://inst-327-gp.s3.us-east-1.amazonaws.com/ERD+Diagram.svg?)

## Additional Reources

<details open>
<summary>Normalization Guide</summary>

* #### 1NF

  * Break elements down into atomic values
  ![NF1- Atomicity](https://inst-327-gp.s3.us-east-1.amazonaws.com/NF1-+Atomic.svg)
  * Break down multi-value elements
  ![NF1- Multi-Value Elements](https://inst-327-gp.s3.us-east-1.amazonaws.com/NF1-+Multi-Value+Elements.svg)
  * Break down repeating columns
  ![NF1- Repeating Columns](https://inst-327-gp.s3.us-east-1.amazonaws.com/NF1-+Repeating+Columns.svg)

* #### 2NF

  * Remove partial dependencies (is a non-key attribute defined by only some of the key attributes?)
    * Composite Key: Primary key comprises of 2 or more columns in a table.
    * Found in tables with a composite key.
    * Ex. Artist Name is defined by Artist ID and not Album ID. Album Name is defined by Album ID and not Artist ID.

  ![NF2- Partial Dependencies](https://inst-327-gp.s3.us-east-1.amazonaws.com/NF2-+Partial+Dependencies.svg)

* #### 3NF

  * Remove transitive dependencies (Does a non-key attribute define another non-key attribute?)
    * Ex. Song ID determines rating. Rating determines grade. Therefore Song ID transitively determines grade.

    ![NF3- Transitive Dependencies](https://inst-327-gp.s3.us-east-1.amazonaws.com/NF3-+Transitive+Dependencies.svg)
</details>
