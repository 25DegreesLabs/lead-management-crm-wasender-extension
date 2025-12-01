/*
  # Create campaigns table

  ## Overview
  Creates the campaigns table to store marketing campaign information including
  targeting, budget, metrics, and status tracking.

  ## Tables Created
    - `campaigns`
      - `id` (uuid, primary key) - Unique identifier
      - `user_id` (text) - User who owns this campaign ('default_user' for non-auth mode)
      - `campaign_name` (text) - Campaign name
      - `description` (text) - Campaign description
      - `target_segment` (text) - Target segment (HOT, WARM, COLD, ALL)
      - `budget_eur` (numeric) - Budget in EUR
      - `expected_reply_rate` (numeric) - Expected reply rate percentage
      - `sync_reminder_frequency` (text) - Reminder frequency
      - `contact_filter` (jsonb) - Contact filter rules (skip days, etc.)
      - `status` (text) - Campaign status (CREATED, ACTIVE, COMPLETED, etc.)
      - `leads_count` (integer) - Number of eligible leads (default 0)
      - `webhook_status` (text) - Webhook status (PENDING_SHEETS_SYNC, etc.)
      - `start_date` (date) - Campaign start date
      - `metrics` (jsonb) - Campaign metrics (sent_count, failed_count, replied_count, etc.)
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

  ## Security
    - Enable RLS on campaigns table
    - Add policies for authenticated users to manage their own campaigns
    - Add policies for public access when user_id is 'default_user'

  ## Indexes
    - Index on user_id for fast user filtering
    - Index on status for filtering
    - Index on created_at for sorting
*/

CREATE TABLE IF NOT EXISTS campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,
  campaign_name text NOT NULL,
  description text,
  target_segment text NOT NULL,
  budget_eur numeric,
  expected_reply_rate numeric,
  sync_reminder_frequency text,
  contact_filter jsonb,
  status text DEFAULT 'CREATED',
  leads_count integer DEFAULT 0,
  webhook_status text DEFAULT 'PENDING_SHEETS_SYNC',
  start_date date DEFAULT CURRENT_DATE,
  metrics jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;

-- Policies for authenticated users
CREATE POLICY "Users can view their own campaigns"
  ON campaigns FOR SELECT
  TO authenticated
  USING (user_id = auth.uid()::text);

CREATE POLICY "Users can insert their own campaigns"
  ON campaigns FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY "Users can update their own campaigns"
  ON campaigns FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY "Users can delete their own campaigns"
  ON campaigns FOR DELETE
  TO authenticated
  USING (user_id = auth.uid()::text);

-- Policies for public access (default_user)
CREATE POLICY "Allow public read for default_user campaigns"
  ON campaigns FOR SELECT
  TO public
  USING (user_id = 'default_user');

CREATE POLICY "Allow public insert for default_user campaigns"
  ON campaigns FOR INSERT
  TO public
  WITH CHECK (user_id = 'default_user');

CREATE POLICY "Allow public update for default_user campaigns"
  ON campaigns FOR UPDATE
  TO public
  USING (user_id = 'default_user')
  WITH CHECK (user_id = 'default_user');

CREATE POLICY "Allow public delete for default_user campaigns"
  ON campaigns FOR DELETE
  TO public
  USING (user_id = 'default_user');

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_campaigns_user_id ON campaigns(user_id);
CREATE INDEX IF NOT EXISTS idx_campaigns_status ON campaigns(status);
CREATE INDEX IF NOT EXISTS idx_campaigns_created_at ON campaigns(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_campaigns_user_created ON campaigns(user_id, created_at DESC);
