/*
  # Create user_whatsapp_groups table

  ## Overview
  Creates the user_whatsapp_groups table to store WhatsApp group configurations
  that are used for lead scoring and campaign targeting.

  ## Tables Created
    - `user_whatsapp_groups`
      - `id` (uuid, primary key) - Unique identifier
      - `user_id` (text) - User who owns this group ('default_user' for non-auth mode)
      - `group_name` (text) - WhatsApp group name
      - `score_value` (integer) - Score value for this group (positive, negative, or neutral)
      - `description` (text) - Group description
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

  ## Security
    - Enable RLS on user_whatsapp_groups table
    - Add policies for authenticated users to manage their own groups
    - Add policies for public access when user_id is 'default_user'

  ## Constraints
    - Unique constraint on (user_id, group_name) to prevent duplicates

  ## Indexes
    - Index on user_id for fast user filtering
    - Index on group_name for fast lookups
*/

CREATE TABLE IF NOT EXISTS user_whatsapp_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,
  group_name text NOT NULL,
  score_value integer NOT NULL DEFAULT 0,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT unique_user_group_name UNIQUE (user_id, group_name)
);

-- Enable Row Level Security
ALTER TABLE user_whatsapp_groups ENABLE ROW LEVEL SECURITY;

-- Policies for authenticated users
CREATE POLICY "Users can view their own WhatsApp groups"
  ON user_whatsapp_groups FOR SELECT
  TO authenticated
  USING (user_id = auth.uid()::text);

CREATE POLICY "Users can insert their own WhatsApp groups"
  ON user_whatsapp_groups FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY "Users can update their own WhatsApp groups"
  ON user_whatsapp_groups FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY "Users can delete their own WhatsApp groups"
  ON user_whatsapp_groups FOR DELETE
  TO authenticated
  USING (user_id = auth.uid()::text);

-- Policies for public access (default_user)
CREATE POLICY "Allow public read for default_user groups"
  ON user_whatsapp_groups FOR SELECT
  TO public
  USING (user_id = 'default_user');

CREATE POLICY "Allow public insert for default_user groups"
  ON user_whatsapp_groups FOR INSERT
  TO public
  WITH CHECK (user_id = 'default_user');

CREATE POLICY "Allow public update for default_user groups"
  ON user_whatsapp_groups FOR UPDATE
  TO public
  USING (user_id = 'default_user')
  WITH CHECK (user_id = 'default_user');

CREATE POLICY "Allow public delete for default_user groups"
  ON user_whatsapp_groups FOR DELETE
  TO public
  USING (user_id = 'default_user');

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_whatsapp_groups_user_id ON user_whatsapp_groups(user_id);
CREATE INDEX IF NOT EXISTS idx_user_whatsapp_groups_group_name ON user_whatsapp_groups(group_name);
CREATE INDEX IF NOT EXISTS idx_user_whatsapp_groups_user_group ON user_whatsapp_groups(user_id, group_name);
