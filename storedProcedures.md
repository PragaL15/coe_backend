### Stored Procedures

1. GET procedures from faculty_request table and inner join with faculty_table.
```sql
CREATE OR REPLACE FUNCTION get_faculty_requests()
RETURNS TABLE (
    id INTEGER,
    date_submitted TIMESTAMP,
    papers INTEGER,
    deadline TIMESTAMP,
    faculty_name VARCHAR,
    course_code VARCHAR,
    semester_code VARCHAR,
    reason TEXT,
    status VARCHAR,
    remarks TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fr.id,
        fr.createdat AS date_submitted,
        fr.total_allocated_papers AS papers,
        fr.updatedat + (fr.deadline_left || ' days')::INTERVAL AS deadline,
        ft.faculty_name,
        'CS101'::VARCHAR AS course_code, -- Replace with actual course_code logic
        fr.sem_code AS semester_code,
        fr.remarks AS reason,
        CASE 
            WHEN fr.approval_status = 1 THEN 'Approved'
            WHEN fr.approval_status = 2 THEN 'Rejected'
            ELSE 'Initiated'
        END AS status,
        fr.remarks
    FROM 
        faculty_request fr
    INNER JOIN 
        faculty_table ft ON fr.faculty_id = ft.faculty_id;
END;
$$ LANGUAGE plpgsql;
```
---
2. POST procedures from faculty_request table and inner join with faculty_table.

```sql
CREATE OR REPLACE FUNCTION insert_faculty_request(
    faculty_id INTEGER,
    total_allocated_papers INTEGER,
    papers_left INTEGER,
    course_id INTEGER,
    remarks TEXT,
    approval_status INTEGER DEFAULT 0,
    status INTEGER DEFAULT 0,
    deadline_left INTEGER DEFAULT 0,
    sem_code VARCHAR(50) DEFAULT '',
    sem_academic_year VARCHAR(10) DEFAULT '',
    year INTEGER DEFAULT 0
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO faculty_request (
        faculty_id,
        total_allocated_papers,
        papers_left,
        course_id,
        remarks,
        approval_status,
        status,
        deadline_left,
        sem_code,
        sem_academic_year,
        year,
        createdat,
        updatedat
    )
    VALUES (
        faculty_id,
        total_allocated_papers,
        papers_left,
        course_id,
        remarks,
        approval_status,
        status,
        deadline_left,
        sem_code,
        sem_academic_year,
        year,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
END;
$$ LANGUAGE plpgsql;
```
---
