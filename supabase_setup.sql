-- Ghoomo Travel Planner - Supabase Database Setup
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/_/sql

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
create table if not exists users (
  id uuid references auth.users primary key,
  email text unique not null,
  name text not null,
  persona text,
  preferred_currency text default 'USD',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable Row Level Security
alter table users enable row level security;

-- RLS Policies for users
create policy "Users can view own data"
  on users for select
  using (auth.uid() = id);

create policy "Users can insert own data"
  on users for insert
  with check (auth.uid() = id);

create policy "Users can update own data"
  on users for update
  using (auth.uid() = id);

-- ============================================
-- TRIPS TABLE
-- ============================================
create table if not exists trips (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references users(id) on delete cascade,
  destination text not null,
  start_date date not null,
  end_date date,
  budget numeric,
  status text default 'planning',
  itinerary jsonb,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable Row Level Security
alter table trips enable row level security;

-- RLS Policies for trips
create policy "Users can view own trips"
  on trips for select
  using (auth.uid() = user_id);

create policy "Users can create own trips"
  on trips for insert
  with check (auth.uid() = user_id);

create policy "Users can update own trips"
  on trips for update
  using (auth.uid() = user_id);

create policy "Users can delete own trips"
  on trips for delete
  using (auth.uid() = user_id);

-- ============================================
-- SAVED FLIGHTS TABLE
-- ============================================
create table if not exists saved_flights (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  flight_data jsonb not null,
  created_at timestamp with time zone default now()
);

-- Enable Row Level Security
alter table saved_flights enable row level security;

-- RLS Policies for saved_flights
create policy "Users can view own saved flights"
  on saved_flights for select
  using (auth.uid() = user_id);

create policy "Users can create own saved flights"
  on saved_flights for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own saved flights"
  on saved_flights for delete
  using (auth.uid() = user_id);

-- ============================================
-- SAVED HOTELS TABLE
-- ============================================
create table if not exists saved_hotels (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references users(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  hotel_data jsonb not null,
  created_at timestamp with time zone default now()
);

-- Enable Row Level Security
alter table saved_hotels enable row level security;

-- RLS Policies for saved_hotels
create policy "Users can view own saved hotels"
  on saved_hotels for select
  using (auth.uid() = user_id);

create policy "Users can create own saved hotels"
  on saved_hotels for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own saved hotels"
  on saved_hotels for delete
  using (auth.uid() = user_id);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
create index if not exists trips_user_id_idx on trips(user_id);
create index if not exists trips_created_at_idx on trips(created_at desc);
create index if not exists saved_flights_user_id_idx on saved_flights(user_id);
create index if not exists saved_flights_trip_id_idx on saved_flights(trip_id);
create index if not exists saved_hotels_user_id_idx on saved_hotels(user_id);
create index if not exists saved_hotels_trip_id_idx on saved_hotels(trip_id);

-- ============================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply trigger to users table
drop trigger if exists update_users_updated_at on users;
create trigger update_users_updated_at
  before update on users
  for each row
  execute function update_updated_at_column();

-- Apply trigger to trips table
drop trigger if exists update_trips_updated_at on trips;
create trigger update_trips_updated_at
  before update on trips
  for each row
  execute function update_updated_at_column();

-- ============================================
-- DONE!
-- ============================================
-- Your database is now ready to use with the Ghoomo app!
