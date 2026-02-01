-- Enable email confirmation in Supabase
-- Run this in Supabase SQL Editor after initial setup

-- Update auth settings to require email confirmation
-- Note: This is typically done in Supabase Dashboard > Authentication > Settings
-- But here's the SQL to check current settings

-- Check if email confirmation is enabled
SELECT * FROM auth.config;

-- To enable email confirmation:
-- 1. Go to Supabase Dashboard
-- 2. Navigate to Authentication > Settings
-- 3. Under "Email Auth", enable "Confirm email"
-- 4. Customize email templates if needed

-- Add email_confirmed_at column tracking (if not exists)
ALTER TABLE auth.users 
ADD COLUMN IF NOT EXISTS email_confirmed_at TIMESTAMPTZ;

-- Create a function to check if user email is verified
CREATE OR REPLACE FUNCTION is_email_verified(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = user_id 
    AND email_confirmed_at IS NOT NULL
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION is_email_verified(UUID) TO authenticated;
