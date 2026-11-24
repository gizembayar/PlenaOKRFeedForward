-- NOT DUL, BUT COOL. — temel şema
-- Kullanıcı profili, "Benim Hayatım" verisi ve Stripe üyelik durumu.

create table if not exists public.profiles (
  id                    uuid primary key references auth.users (id) on delete cascade,
  display_name          text,
  tier                  text not null default 'free' check (tier in ('free', 'cool', 'icon')),
  life_profile          jsonb,
  saved_ids             text[] not null default '{}',
  done_ids              text[] not null default '{}',
  stripe_customer_id    text unique,
  stripe_subscription_id text,
  subscription_status   text,
  current_period_end    timestamptz,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Kullanıcı yalnızca kendi profilini görür.
create policy "profiles: kendi kaydını oku"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: kendi kaydını güncelle"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Üyelik ve Stripe alanlarını istemci DEĞİŞTİREMEZ; bunları yalnızca
-- stripe-webhook (service role) yazar. Sütun bazlı yetki:
revoke update on public.profiles from authenticated, anon;
grant update (display_name, life_profile, saved_ids, done_ids)
  on public.profiles to authenticated;

-- updated_at
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

create trigger profiles_touch
  before update on public.profiles
  for each row execute function public.touch_updated_at();

-- Yeni kullanıcı kaydında profil oluştur.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'display_name')
  on conflict (id) do nothing;
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Webhook idempotency: aynı Stripe olayını iki kez işleme.
create table if not exists public.stripe_events (
  id          text primary key,
  type        text not null,
  received_at timestamptz not null default now()
);
alter table public.stripe_events enable row level security;
-- (politika yok → yalnızca service role erişir)
