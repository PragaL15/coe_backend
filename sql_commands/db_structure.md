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
8. 
