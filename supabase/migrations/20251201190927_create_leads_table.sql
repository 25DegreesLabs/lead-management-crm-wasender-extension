/*
  # Create leads table

  ## Overview
  Creates the main leads table to store lead information including contact details,
  segments, scoring, WhatsApp group membership, and engagement tracking.

  ## Tables Created
    - `leads`
      - `id` (uuid, primary key) - Unique identifier
      - `user_id` (text) - User who owns this lead ('default_user' for non-auth mode)
      - `phone_number` (bigint) - Lead's phone number
      - `first_name` (text) - First name
      - `last_name` (text) - Last name
      - `email` (text) - Email address
      - `segment` (text) - HOT, WARM, or COLD
      - `lead_score` (integer) - Numeric score (default 0)
      - `last_contacted_date` (timestamptz) - When last contacted
      - `status` (text) - Lead status
      - `reply_received` (boolean) - Whether lead replied
      - `engagement_level` (text) - Engagement level
      - `positive_signal_groups` (text[]) - Array of positive WhatsApp groups
      - `negative_signal_groups` (text[]) - Array of negative WhatsApp groups
      - `neutral_signal_groups` (text[]) - Array of neutral WhatsApp groups
      - `intent_groups` (text[]) - Array of intent groups
      - `custom_groups` (text[]) - Array of custom groups
      - `whatsapp_groups_raw` (text[]) - Raw WhatsApp group data
      - `group_net_score` (integer) - Net score from groups (default 0)
      - `primary_group` (text) - Primary group name
      - `primary_group_category` (text) - Primary group category
      - `total_groups_count` (integer) - Total number of groups (default 0)
      - `do_not_contact` (boolean) - Do not contact flag (default false)
      - `do_not_contact_reason` (text) - Reason for do not contact
      - `nationality` (text) - Lead nationality
      - `bio_snippet` (text) - Bio snippet
      - `preferred_language` (text) - Preferred language
      - `timezone` (text) - Timezone
      - `source_url` (text) - Source URL
      - `scrape_source` (text) - Scrape source
      - `first_seen_date` (timestamptz) - When first seen
      - `last_scrape_seen_date` (timestamptz) - Last scrape seen date
      - `scrape_appearance_count` (integer) - Scrape appearance count (default 0)
      - `profile_changed` (boolean) - Profile changed flag (default false)
      - `first_contacted_date` (timestamptz) - First contact date
      - `contact_count` (integer) - Contact count (default 0)
      - `last_reply_date` (timestamptz) - Last reply date
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

  ## Security
    - Enable RLS on leads table
    - Add policies for authenticated users to manage their own leads
    - Add policies for public access when user_id is 'default_user'

  ## Indexes
    - Index on user_id for fast user filtering
    - Index on phone_number for fast lookups
    - Index on segment for filtering
    - Index on last_contacted_date for campaign filters
*/

CREATE TABLE IF NOT EXISTS leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,
  phone_number bigint NOT NULL,
  first_name text,
  last_name text,
  email text,
  segment text NOT NULL,
  lead_score integer DEFAULT 0,
  last_contacted_date timestamptz,
  status text,
  reply_received boolean DEFAULT false,
  engagement_level text,
  positive_signal_groups text[],
  negative_signal_groups text[],
  neutral_signal_groups text[],
  intent_groups text[],
  custom_groups text[],
  whatsapp_groups_raw text[],
  group_net_score integer DEFAULT 0,
  primary_group text,
  primary_group_category text,
  total_groups_count integer DEFAULT 0,
  do_not_contact boolean DEFAULT false,
  do_not_contact_reason text,
  nationality text,
  bio_snippet text,
  preferred_language text,
  timezone text,
  source_url text,
  scrape_source text,
  first_seen_date timestamptz,
  last_scrape_seen_date timestamptz,
  scrape_appearance_count integer DEFAULT 0,
  profile_changed boolean DEFAULT false,
  first_contacted_date timestamptz,
  contact_count integer DEFAULT 0,
  last_reply_date timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- Policies for authenticated users
CREATE POLICY "Users can view their own leads"
  ON leads FOR SELECT
  TO authenticated
  USING (user_id = auth.uid()::text);

CREATE POLICY "Users can insert their own leads"
  ON leads FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY "Users can update their own leads"
  ON leads FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY "Users can delete their own leads"
  ON leads FOR DELETE
  TO authenticated
  USING (user_id = auth.uid()::text);

-- Policies for public access (default_user)
CREATE POLICY "Allow public read for default_user leads"
  ON leads FOR SELECT
  TO public
  USING (user_id = 'default_user');

CREATE POLICY "Allow public insert for default_user leads"
  ON leads FOR INSERT
  TO public
  WITH CHECK (user_id = 'default_user');

CREATE POLICY "Allow public update for default_user leads"
  ON leads FOR UPDATE
  TO public
  USING (user_id = 'default_user')
  WITH CHECK (user_id = 'default_user');

CREATE POLICY "Allow public delete for default_user leads"
  ON leads FOR DELETE
  TO public
  USING (user_id = 'default_user');

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_leads_user_id ON leads(user_id);
CREATE INDEX IF NOT EXISTS idx_leads_phone_number ON leads(phone_number);
CREATE INDEX IF NOT EXISTS idx_leads_segment ON leads(segment);
CREATE INDEX IF NOT EXISTS idx_leads_last_contacted_date ON leads(last_contacted_date);
CREATE INDEX IF NOT EXISTS idx_leads_user_segment ON leads(user_id, segment);
