-- Migrate existing datetime data to ISO 8601 format
-- This updates all existing records to use the new format

-- Update links
UPDATE links 
SET 
  created_at = strftime('%Y-%m-%dT%H:%M:%SZ', created_at),
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', updated_at)
WHERE created_at NOT LIKE '%Z';

-- Update purchases
UPDATE purchases 
SET 
  created_at = strftime('%Y-%m-%dT%H:%M:%SZ', created_at),
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', updated_at)
WHERE created_at NOT LIKE '%Z';

-- Update notes
UPDATE notes 
SET 
  created_at = strftime('%Y-%m-%dT%H:%M:%SZ', created_at),
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', updated_at)
WHERE created_at NOT LIKE '%Z';

-- Update tags
UPDATE tags 
SET 
  created_at = strftime('%Y-%m-%dT%H:%M:%SZ', created_at),
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', updated_at)
WHERE created_at NOT LIKE '%Z';

-- Update categories
UPDATE categories 
SET 
  created_at = strftime('%Y-%m-%dT%H:%M:%SZ', created_at),
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', updated_at)
WHERE created_at NOT LIKE '%Z';

-- Update link_tag
UPDATE link_tag 
SET 
  created_at = strftime('%Y-%m-%dT%H:%M:%SZ', created_at),
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', updated_at)
WHERE created_at NOT LIKE '%Z';

-- Update note_tag
UPDATE note_tag 
SET 
  created_at = strftime('%Y-%m-%dT%H:%M:%SZ', created_at),
  updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', updated_at)
WHERE created_at NOT LIKE '%Z';
