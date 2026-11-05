-- Viva USA — estrutura inicial do banco de dados
-- Execute este arquivo no SQL Editor do seu projeto Supabase.
-- Este script cria tabelas privadas por usuário; não habilita acesso público.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  city_of_interest text,
  preferred_language text not null default 'pt-BR',
  moving_stage text,
  priority text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.saved_rentals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  property_name text,
  city text,
  bedrooms text,
  monthly_rent numeric(12,2),
  listing_url text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.saved_courses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  institution text,
  course_name text,
  city text,
  price numeric(12,2),
  duration text,
  modality text,
  status text,
  official_url text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.saved_providers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider_name text,
  category text,
  city text,
  estimated_price numeric(12,2),
  status text,
  contact text,
  website_url text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.saved_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_title text,
  employer text,
  city text,
  hourly_pay numeric(12,2),
  application_status text,
  listing_url text,
  notes text,
  created_at timestamptz not null default now()
);

-- Bloqueia acesso anônimo e concede operações somente a usuários autenticados.
revoke all on public.profiles, public.saved_rentals, public.saved_courses,
  public.saved_providers, public.saved_jobs from anon, authenticated;

grant select, insert, update, delete on public.profiles, public.saved_rentals,
  public.saved_courses, public.saved_providers, public.saved_jobs to authenticated;

alter table public.profiles enable row level security;
alter table public.saved_rentals enable row level security;
alter table public.saved_courses enable row level security;
alter table public.saved_providers enable row level security;
alter table public.saved_jobs enable row level security;

-- Perfis: cada pessoa só acessa o próprio registro.
create policy "profile_select_own" on public.profiles
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "profile_insert_own" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "profile_update_own" on public.profiles
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "profile_delete_own" on public.profiles
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Dados salvos: cada pessoa só acessa os próprios registros.
create policy "rentals_select_own" on public.saved_rentals
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "rentals_insert_own" on public.saved_rentals
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "rentals_update_own" on public.saved_rentals
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "rentals_delete_own" on public.saved_rentals
  for delete to authenticated using ((select auth.uid()) = user_id);

create policy "courses_select_own" on public.saved_courses
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "courses_insert_own" on public.saved_courses
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "courses_update_own" on public.saved_courses
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "courses_delete_own" on public.saved_courses
  for delete to authenticated using ((select auth.uid()) = user_id);

create policy "providers_select_own" on public.saved_providers
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "providers_insert_own" on public.saved_providers
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "providers_update_own" on public.saved_providers
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "providers_delete_own" on public.saved_providers
  for delete to authenticated using ((select auth.uid()) = user_id);

create policy "jobs_select_own" on public.saved_jobs
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "jobs_insert_own" on public.saved_jobs
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "jobs_update_own" on public.saved_jobs
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "jobs_delete_own" on public.saved_jobs
  for delete to authenticated using ((select auth.uid()) = user_id);

create index if not exists saved_rentals_user_id_idx on public.saved_rentals(user_id);
create index if not exists saved_courses_user_id_idx on public.saved_courses(user_id);
create index if not exists saved_providers_user_id_idx on public.saved_providers(user_id);
create index if not exists saved_jobs_user_id_idx on public.saved_jobs(user_id);

-- Nota: configure confirmação de e-mail e URLs autorizadas no painel Auth
-- antes de abrir o cadastro ao público. Nunca coloque a secret/service_role key
-- no HTML ou em código executado no navegador.
