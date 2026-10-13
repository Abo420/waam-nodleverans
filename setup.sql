-- WAAM Nödleverans – kör hela filen i Supabase → SQL Editor → New query → Run.
-- Byt först ut e-postadressen längst ner mot den du ska logga in med.

create table if not exists public.orders (
  id          uuid primary key,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  name        text not null check (char_length(name) between 1 and 120),
  phone       text not null check (char_length(phone) between 5 and 40),
  persons     int  not null default 1 check (persons between 1 and 20),
  street      text not null check (char_length(street) between 1 and 160),
  apartment   text check (char_length(apartment) <= 60),
  postcode    text not null check (char_length(postcode) <= 12),
  city        text not null check (char_length(city) <= 80),
  lat         double precision check (lat between -90 and 90),
  lng         double precision check (lng between -180 and 180),
  landing     text check (char_length(landing) <= 200),
  can_receive boolean not null default false,
  medicines   jsonb not null default '[]'::jsonb check (jsonb_typeof(medicines) = 'array' and jsonb_array_length(medicines) <= 20),
  supplies    jsonb not null default '[]'::jsonb check (jsonb_typeof(supplies) = 'array' and jsonb_array_length(supplies) <= 20),
  notes       text check (char_length(notes) <= 1000),
  status      text not null default 'ny' check (status in ('ny','packad','skickad','levererad'))
);

-- Vilka konton som får se logistikvyn
create table if not exists public.admins (
  email text primary key
);

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from public.admins where lower(email) = lower(auth.jwt() ->> 'email'));
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- Radsäkerhet
alter table public.orders enable row level security;
alter table public.admins enable row level security;   -- inga policyer = ingen åtkomst utifrån

drop policy if exists "alla kan skicka beställning" on public.orders;
create policy "alla kan skicka beställning" on public.orders
  for insert to anon, authenticated
  with check (status = 'ny');

drop policy if exists "admin läser" on public.orders;
create policy "admin läser" on public.orders
  for select to authenticated
  using (public.is_admin());

drop policy if exists "admin uppdaterar" on public.orders;
create policy "admin uppdaterar" on public.orders
  for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin tar bort" on public.orders;
create policy "admin tar bort" on public.orders
  for delete to authenticated
  using (public.is_admin());

grant insert on public.orders to anon, authenticated;
grant select, update, delete on public.orders to authenticated;

-- Liveuppdatering av logistikvyn
do $$ begin
  alter publication supabase_realtime add table public.orders;
exception when duplicate_object then null; end $$;

-- >>> BYT UT mot din e-post (samma som du skapar användaren med) <<<
insert into public.admins (email) values ('qweytyut123@gmail.com')
on conflict do nothing;
