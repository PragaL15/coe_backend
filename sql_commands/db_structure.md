1. course_table 
```sql
CREATE TABLE course_table (
    id SERIAL PRIMARY KEY,                 -- Unique identifier for the table
    course_id INT NOT NULL,                -- Course ID
    course_code VARCHAR(50) NOT NULL,      -- Course code
    course_name VARCHAR(255) NOT NULL,     -- Name of the course
    status INT DEFAULT 1,                  -- Status (e.g., 1 for active, 0 for inactive)
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record creation timestamp
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP   -- Last update timestamp
);
```
2. bce_table
```sql 
CREATE TABLE BCE_table (
    id SERIAL PRIMARY KEY,       -- Auto-incremented primary key
    dept_id INT NOT NULL,        -- Department ID
    BCE_id VARCHAR(50) NOT NULL, -- Unique BCE identifier
    BCE_name VARCHAR(100) NOT NULL, -- Name of BCE
    status BOOLEAN DEFAULT TRUE, -- Status, default is TRUE (active)
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Creation timestamp
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Last updated timestamp
    FOREIGN KEY (dept) REFERENCES dept_table(id) 
);
```
3. semester_table
```sql
CREATE TABLE semester_table (
    id SERIAL PRIMARY KEY,                          -- Unique identifier for the table
    sem_code VARCHAR(50) NOT NULL,                  -- Semester code (e.g., "S1", "S2", etc.)
    sem_academic_year VARCHAR(10) NOT NULL,         -- Academic year (e.g., "2024-2025")
    year INT NOT NULL,                              -- Year of the semester (e.g., 1, 2, etc.)
    status INT DEFAULT 1,                           -- Status (e.g., 1 for active, 0 for inactive)
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record creation timestamp
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Record last update timestamp
);
```
4. Faculty_table
```sql
CREATE TABLE faculty_table (
    id SERIAL PRIMARY KEY,                   -- Unique identifier for the faculty
    faculty_id INT NOT NULL,                 -- Faculty ID
    faculty_name VARCHAR(255) NOT NULL,       -- Name of the faculty member
    dept INT NOT NULL,                        -- Department ID (Foreign Key to dept_table)
    mobile_num VARCHAR(15) NOT NULL,
    ADD CONSTRAINT chk_mobile_num_format CHECK (mobile_num ~ '^\d{10}$'); -- stroring the mobile number of the respective faculty 
    status INT DEFAULT 1,                     -- Status (e.g., 1 for active, 0 for inactive)
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record creation timestamp
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record last update timestamp
    FOREIGN KEY (dept) REFERENCES dept_table(id)   -- Foreign Key constraint linking to dept_table
);
```

5. dept_table
```sql
CREATE TABLE dept_table (
    id SERIAL PRIMARY KEY,                 -- Unique identifier for the department
    dept_name VARCHAR(255) NOT NULL,        -- Name of the department
    status INT DEFAULT 1,                  -- Status (e.g., 1 for active, 0 for inactive)
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Record creation timestamp
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Record last update timestamp
);
```

6. Faculty_request
```sql
CREATE TABLE faculty_request (
    id SERIAL PRIMARY KEY,                     -- Unique identifier for the request
    faculty_id INT,                            -- Faculty ID (Foreign Key from faculty_table)
    total_allocated_papers INT,                -- Total papers allocated to the faculty
    papers_left INT,                           -- Number of papers left for the faculty
    course_id INT,                   -- Course id (Foreign Key from course_table)
    remarks TEXT DEFAULT NULL,                 -- Remarks (Default value is NULL)
    approval_status INT DEFAULT 0,             -- Approval status (Default value is 0)
    sem_code VARCHAR(50) NOT NULL,
    sem_academic_year VARCHAR(50) NOT NULL,
    year INT,
    status INT DEFAULT 0,                      -- Status (Default value is 0)
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for record creation
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for last update
    FOREIGN KEY (faculty_id) REFERENCES faculty_table(id),  -- Foreign Key: faculty_id
    FOREIGN KEY (course_id) REFERENCES course_table(course_id) -- Foreign Key: course_code
);
```
7. Academic_year_table
```sql
-- Create the academic_year_table
CREATE TABLE academic_year_table (
    id SERIAL PRIMARY KEY,           -- Auto-incrementing primary key
    academic_id int NOT NULL, -- Academic ID, unique identifier 
    academic_year VARCHAR(20) NOT NULL, -- Academic Year, e.g., "2023-2024"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Auto set creation time
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Auto set update time
);
```
8. daily_faculty_updates - To track the daily upadtes status of allocated papers from each faculty. 

```sql
CREATE TABLE daily_faculty_updates (
    update_id SERIAL PRIMARY KEY, -- auto-incremented primary key
    faculty_id INT NOT NULL, -- faculty ID
    paper_id TEXT NOT NULL, -- paper ID
    paper_corrected_today INT CHECK (paper_corrected_today >= 0), -- corrected papers today, must be >= 0
    remarks TEXT, -- remarks for the update
    FOREIGN KEY (faculty_id, paper_id) REFERENCES faculty_all_records(faculty_id, paper_id), -- foreign key constraint
    CONSTRAINT daily_faculty_updates_paper_corrected_today_check CHECK (paper_corrected_today >= 0) -- ensure non-negative values for paper_corrected_today
);

```
---
9. FacultyDailyUpdates -- To maintain the daily update from faculties

```sql
CREATE TABLE FacultyDailyUpdates (
    id SERIAL PRIMARY KEY,
    faculty_status_id INT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    papers_corrected INT NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (faculty_status_id) REFERENCES FacultyPaperStatus(id) ON DELETE CASCADE
);
```

10. Trigger function created to update the paper_corrected in the faculty_all_records table from the daily_faculty_updates table.

```sql
CREATE OR REPLACE FUNCTION update_paper_corrected()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if paper_corrected_today is greater than 0
    IF NEW.paper_corrected_today > 0 THEN
        -- Update the paper_corrected column in faculty_all_records
        UPDATE faculty_all_records
        SET paper_corrected = paper_corrected + NEW.paper_corrected_today
        WHERE faculty_id = NEW.faculty_id AND paper_id = NEW.paper_id;
    END IF;

    -- Return the NEW record, necessary for INSERT triggers
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_paper_corrected
BEFORE INSERT ON daily_faculty_updates
FOR EACH ROW
EXECUTE FUNCTION update_paper_corrected();

```
11. 