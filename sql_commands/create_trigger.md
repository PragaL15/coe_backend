1. create the common trigger function 
```sql
CREATE OR REPLACE FUNCTION set_created_at_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.createdAt = CURRENT_TIMESTAMP;  -- Set createdAt to current timestamp
        NEW.updatedAt = CURRENT_TIMESTAMP;  -- Set updatedAt to current timestamp
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.updatedAt = CURRENT_TIMESTAMP;  -- Update updatedAt to current timestamp
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

2. Apply the table_name alone according to the table

```sql
CREATE TRIGGER set_created_at_updated_at_course
BEFORE INSERT OR UPDATE ON table_name
FOR EACH ROW
EXECUTE FUNCTION set_created_at_updated_at();
```
