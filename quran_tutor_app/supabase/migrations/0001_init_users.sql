-- Minimal initial schema to unblock login.
-- Matches the columns referenced by:
--   lib/features/auth/data/datasources/auth_remote_datasource.dart
--   lib/features/auth/data/models/user_model.dart
--
-- Apply via Supabase Dashboard -> SQL Editor -> run this file.
-- (Or via the Supabase CLI: `supabase db push`.)

-- 1. public.users table -------------------------------------------------------

create table if not exists public.users (
  id              uuid primary key references auth.users(id) on delete cascade,
  email           text not null,
  display_name    text,
  arabic_name     text,
  role            text not null check (role in ('student','teacher','admin')),
  status          text not null check (status in ('pending','approved','rejected')),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz,
  phone_number    text,
  date_of_birth   timestamptz,
  teacher_id      uuid references public.users(id) on delete set null,
  bio             text,
  website_url     text
);

create index if not exists users_role_idx   on public.users (role);
create index if not exists users_status_idx on public.users (status);

-- 2. Row-Level Security -------------------------------------------------------

alter table public.users enable row level security;

-- Each user can read their own row.
drop policy if exists "users self read" on public.users;
create policy "users self read"
  on public.users for select
  using (auth.uid() = id);

-- Each user can update their own row.
drop policy if exists "users self update" on public.users;
create policy "users self update"
  on public.users for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Each user can insert their own row (signup flow does this client-side).
drop policy if exists "users self insert" on public.users;
create policy "users self insert"
  on public.users for insert
  with check (auth.uid() = id);

-- Admins can do everything. (You will set role='admin' on at least one row.)
drop policy if exists "admins all" on public.users;
create policy "admins all"
  on public.users for all
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'admin'
    )
  );

-- 3. Seed your existing auth user as approved admin -------------------------
-- This matches the user shown in the "login then logout" log:
--   id    = 20d7f2a7-3e0a-42ef-8ce1-6be84bb46eba
--   email = haskhr@hotmail.com

insert into public.users (id, email, display_name, role, status, created_at)
values (
  '20d7f2a7-3e0a-42ef-8ce1-6be84bb46eba',
  'haskhr@hotmail.com',
  'Hassan',
  'admin',
  'approved',
  now()
)
on conflict (id) do update
  set role   = excluded.role,
      status = excluded.status;
