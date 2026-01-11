create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price_local numeric not null,
  price_foreign numeric not null,
  image_url text,
  category text not null,
  stock integer not null default 0,
  is_active boolean not null default true,
  track_stock boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  order_no text not null,
  cashier text not null,
  total_amount numeric not null,
  tax numeric not null default 0,
  discount numeric not null default 0,
  status text not null,
  payment_method text not null,
  received numeric not null default 0,
  price_type text not null default 'local',
  store_name text not null,
  store_address text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  role text not null default 'cashier',
  created_at timestamptz not null default now()
);

create table if not exists public.transaction_items (
  id uuid primary key default gen_random_uuid(),
  transaction_id uuid not null references public.transactions(id) on delete cascade,
  product_id uuid references public.products(id),
  name text not null,
  quantity integer not null,
  price numeric not null
);

create index if not exists transaction_items_transaction_id_idx
  on public.transaction_items (transaction_id);

alter table public.products
  add column if not exists price_local numeric default 0,
  add column if not exists price_foreign numeric default 0;

alter table public.transactions
  add column if not exists price_type text default 'local';

update public.products
  set price_local = 0
  where price_local is null;

update public.products
  set price_foreign = price_local
  where price_foreign is null;

-- Jika sebelumnya ada kolom price, lakukan migrasi manual:
-- update public.products set price_local = price, price_foreign = price;

alter table public.products enable row level security;
alter table public.categories enable row level security;
alter table public.transactions enable row level security;
alter table public.transaction_items enable row level security;
alter table public.user_profiles enable row level security;

create policy "Products full access for authenticated"
  on public.products
  for all
  to authenticated
  using (true)
  with check (true);

create policy "Categories full access for authenticated"
  on public.categories
  for all
  to authenticated
  using (true)
  with check (true);

create policy "Transactions full access for authenticated"
  on public.transactions
  for all
  to authenticated
  using (true)
  with check (true);

create policy "Transaction items full access for authenticated"
  on public.transaction_items
  for all
  to authenticated
  using (true)
  with check (true);

create policy "User profiles full access for authenticated"
  on public.user_profiles
  for all
  to authenticated
  using (true)
  with check (true);
