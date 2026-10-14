-- WAAM v2 – kör HELA filen i Supabase → SQL Editor → New query → Run.
-- Lägger till: beställare (privat/hemtjänst), "tar slut när", drönare + ankomsttid,
-- hjärtstartarlarm (kind = 'aed') och spårning med referensnummer.

alter table public.orders add column if not exists kind            text not null default 'medicin';
alter table public.orders add column if not exists requester_role  text;
alter table public.orders add column if not exists requester_name  text;
alter table public.orders add column if not exists requester_phone text;
alter table public.orders add column if not exists requester_unit  text;
alter table public.orders add column if not exists runs_out        text;
alter table public.orders add column if not exists drone           text;
alter table public.orders add column if not exists dispatched_at   timestamptz;
alter table public.orders add column if not exists eta             timestamptz;

do $$ begin
  alter table public.orders add constraint orders_kind_chk check (kind in ('medicin','aed'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table public.orders add constraint orders_role_chk check (requester_role is null or requester_role in ('privat','planerare','ssk','hemtjanst'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table public.orders add constraint orders_runs_chk check (runs_out is null or runs_out in ('slut','24h','3d','senare'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table public.orders add constraint orders_req_len_chk check (char_length(coalesce(requester_name,'')) <= 120 and char_length(coalesce(requester_phone,'')) <= 40 and char_length(coalesce(requester_unit,'')) <= 120);
exception when duplicate_object then null; end $$;

-- Vem som helst får skicka: medicin startar som 'ny', hjärtstartare skickas direkt.
drop policy if exists "alla kan skicka beställning" on public.orders;
create policy "alla kan skicka beställning" on public.orders
  for insert to anon, authenticated
  with check (
    (kind = 'medicin' and status = 'ny' and drone is null and dispatched_at is null and eta is null)
    or
    (kind = 'aed' and status = 'skickad')
  );

-- Spårning: returnerar bara status och tider för ett referensnummer (sista 8 tecknen i id).
create or replace function public.get_order_status(p_ref text)
returns table(status text, kind text, eta timestamptz, dispatched_at timestamptz, created_at timestamptz)
language sql stable security definer set search_path = public
as $$
  select o.status, o.kind, o.eta, o.dispatched_at, o.created_at
  from public.orders o
  where char_length(p_ref) = 8
    and right(replace(o.id::text, '-', ''), 8) = lower(p_ref)
  order by o.created_at desc
  limit 1;
$$;
revoke all on function public.get_order_status(text) from public;
grant execute on function public.get_order_status(text) to anon, authenticated;
