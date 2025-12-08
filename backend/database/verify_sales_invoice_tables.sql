-- Verify Sales Invoice Tables Structure
-- Run this to check if all required tables and columns exist

-- Check sales_invoices table
SELECT 
    'sales_invoices table structure' as check_name,
    COUNT(*) as column_count
FROM information_schema.columns 
WHERE table_name = 'sales_invoices';

-- Check sales_invoice_items table
SELECT 
    'sales_invoice_items table structure' as check_name,
    COUNT(*) as column_count
FROM information_schema.columns 
WHERE table_name = 'sales_invoice_items';

-- List all columns in sales_invoices
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'sales_invoices'
ORDER BY ordinal_position;

-- List all columns in sales_invoice_items
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'sales_invoice_items'
ORDER BY ordinal_position;

-- Check foreign key constraints
SELECT 
    constraint_name,
    table_name,
    column_name,
    referenced_table_name,
    referenced_column_name
FROM information_schema.key_column_usage
WHERE table_name IN ('sales_invoices', 'sales_invoice_items')
    AND referenced_table_name IS NOT NULL;

-- Check indexes
SELECT 
    table_name,
    index_name,
    column_name,
    non_unique
FROM information_schema.statistics
WHERE table_name IN ('sales_invoices', 'sales_invoice_items')
ORDER BY table_name, index_name, seq_in_index;
