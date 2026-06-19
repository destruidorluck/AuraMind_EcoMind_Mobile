-- Aura Mind app-state schema.
-- Cole este arquivo no SQL Editor do Supabase. Ele nao recria profiles.

create extension if not exists pgcrypto;

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  theme text not null default 'dark',
  app_language text not null default 'pt',
  selected_alarm_sound text not null default 'Radar',
  selected_voice text not null default 'Aura',
  onboarding_completed boolean not null default false,
  raw_payload jsonb default '{}'::jsonb,
  privacy_payload jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz default now()
);

create table if not exists public.contacts (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null default '',
  phone text,
  type text,
  time text,
  payload jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz default now()
);

create table if not exists public.devices (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null default '',
  room text,
  type text,
  status text,
  active boolean default false,
  connections text[] default array[]::text[],
  manufacturer text,
  model text,
  payload jsonb default '{}'::jsonb,
  last_seen timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz default now()
);

create table if not exists public.audio_logs (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  transcription text,
  payload jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.spotify_accounts (
  id text primary key default encode(gen_random_bytes(12), 'hex'),
  user_id uuid not null references auth.users(id) on delete cascade,
  connected boolean default false,
  payload jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz default now()
);

alter table if exists public.user_settings
  add column if not exists theme text not null default 'dark',
  add column if not exists app_language text not null default 'pt',
  add column if not exists selected_alarm_sound text not null default 'Radar',
  add column if not exists selected_voice text not null default 'Aura',
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists raw_payload jsonb default '{}'::jsonb,
  add column if not exists privacy_payload jsonb default '{}'::jsonb,
  add column if not exists updated_at timestamptz default now();

alter table if exists public.contacts
  add column if not exists name text not null default '',
  add column if not exists phone text,
  add column if not exists type text,
  add column if not exists payload jsonb default '{}'::jsonb,
  add column if not exists time text,
  add column if not exists updated_at timestamptz default now();

alter table if exists public.devices
  add column if not exists name text not null default '',
  add column if not exists room text,
  add column if not exists type text,
  add column if not exists status text,
  add column if not exists active boolean default false,
  add column if not exists connections text[] default array[]::text[],
  add column if not exists manufacturer text,
  add column if not exists model text,
  add column if not exists payload jsonb default '{}'::jsonb,
  add column if not exists last_seen timestamptz,
  add column if not exists updated_at timestamptz default now();

alter table if exists public.audio_logs
  add column if not exists transcription text,
  add column if not exists payload jsonb default '{}'::jsonb;

alter table if exists public.spotify_accounts
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists payload jsonb default '{}'::jsonb,
  add column if not exists connected boolean default false,
  add column if not exists updated_at timestamptz default now();

create table if not exists public.aura_groups (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'Aura Mind',
  invite_code text not null default encode(gen_random_bytes(8), 'hex'),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.group_members (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  group_id text,
  email text,
  name text,
  role text not null default 'Membro',
  can_manage_devices boolean not null default true,
  can_manage_members boolean not null default false,
  can_use_voice boolean not null default true,
  can_use_media boolean not null default true,
  can_view_history boolean not null default false,
  payload jsonb not null default '{}'::jsonb,
  joined_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.member_invites (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  group_id text,
  email text not null,
  role text not null default 'Membro',
  invite_url text,
  status text not null default 'pending',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  accepted_at timestamptz
);

create table if not exists public.lists (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.list_items (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  list_id text references public.lists(id) on delete cascade,
  text text not null,
  checked boolean not null default false,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notes (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.alarms (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  label text,
  time text not null,
  active boolean not null default true,
  tone text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.timers (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  label text,
  active boolean not null default false,
  remaining_seconds integer not null default 0,
  total_seconds integer not null default 0,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reminders (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  reminder_date date not null,
  text text not null,
  time text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.activities (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null,
  origin text,
  device text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.device_connections (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  device_id text,
  connection_type text not null,
  status text not null default 'disconnected',
  network_name text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_notifications (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text,
  origin text,
  device text,
  read boolean not null default false,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.skills (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_id text not null,
  title text,
  connected boolean not null default false,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.world_clocks (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  selected_clock_id text not null default 'br-sp',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tone_settings (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  tone_id text not null default 'Radar',
  tone_uri text,
  category text not null default 'alarm',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.aura_messages (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_id text,
  group_id text,
  direction text not null default 'outgoing',
  body text not null,
  status text not null default 'sent',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.call_sessions (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_id text,
  group_id text,
  status text not null default 'ringing',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  ended_at timestamptz
);

create table if not exists public.webrtc_signals (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  session_id text not null,
  signal_type text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table if exists public.aura_messages
  add column if not exists status text not null default 'sent',
  add column if not exists updated_at timestamptz not null default now();

alter table if exists public.call_sessions
  add column if not exists group_id text;

create index if not exists idx_contacts_user_id on public.contacts(user_id);
create index if not exists idx_devices_user_room on public.devices(user_id, room);
create index if not exists idx_activities_user_created on public.activities(user_id, created_at desc);
create index if not exists idx_messages_user_created on public.aura_messages(user_id, created_at desc);
create index if not exists idx_webrtc_session on public.webrtc_signals(session_id, created_at);
create index if not exists idx_call_sessions_user_created on public.call_sessions(user_id, created_at desc);
create unique index if not exists idx_spotify_accounts_user_unique on public.spotify_accounts(user_id);
create unique index if not exists idx_aura_groups_invite_code_unique on public.aura_groups(invite_code);
create unique index if not exists idx_aura_groups_owner_name_unique on public.aura_groups(owner_id, lower(name));
create unique index if not exists idx_contacts_user_phone_unique on public.contacts(user_id, phone)
  where phone is not null and btrim(phone) <> '';
create unique index if not exists idx_contacts_user_name_unique on public.contacts(user_id, lower(name))
  where btrim(name) <> '';
create unique index if not exists idx_devices_user_room_name_unique on public.devices(user_id, lower(coalesce(room, '')), lower(name))
  where btrim(name) <> '';
create unique index if not exists idx_group_members_group_user_unique on public.group_members(group_id, user_id)
  where group_id is not null and btrim(group_id) <> '';
create unique index if not exists idx_group_members_group_email_unique on public.group_members(group_id, lower(email))
  where group_id is not null and btrim(group_id) <> '' and email is not null and btrim(email) <> '';
create unique index if not exists idx_member_invites_pending_unique on public.member_invites(user_id, coalesce(group_id, ''), lower(email))
  where status = 'pending';

alter table public.aura_groups enable row level security;
alter table if exists public.user_settings enable row level security;
alter table if exists public.contacts enable row level security;
alter table if exists public.devices enable row level security;
alter table if exists public.audio_logs enable row level security;
alter table if exists public.spotify_accounts enable row level security;
alter table public.group_members enable row level security;
alter table public.member_invites enable row level security;
alter table public.lists enable row level security;
alter table public.list_items enable row level security;
alter table public.notes enable row level security;
alter table public.alarms enable row level security;
alter table public.timers enable row level security;
alter table public.reminders enable row level security;
alter table public.activities enable row level security;
alter table public.device_connections enable row level security;
alter table public.app_notifications enable row level security;
alter table public.skills enable row level security;
alter table public.world_clocks enable row level security;
alter table public.tone_settings enable row level security;
alter table public.aura_messages enable row level security;
alter table public.call_sessions enable row level security;
alter table public.webrtc_signals enable row level security;

drop policy if exists aura_groups_owner on public.aura_groups;
create policy aura_groups_owner on public.aura_groups
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists aura_groups_member_read on public.aura_groups;
create policy aura_groups_member_read on public.aura_groups
  for select using (
    owner_id = auth.uid()
    or exists (
      select 1
      from public.group_members gm
      where gm.group_id = aura_groups.id
        and (
          gm.user_id = auth.uid()
          or lower(coalesce(gm.email, '')) = lower(coalesce(auth.jwt() ->> 'email', ''))
        )
    )
  );

drop policy if exists own_user_settings on public.user_settings;
create policy own_user_settings on public.user_settings
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_contacts on public.contacts;
create policy own_contacts on public.contacts
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_devices on public.devices;
create policy own_devices on public.devices
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_audio_logs on public.audio_logs;
create policy own_audio_logs on public.audio_logs
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_spotify_accounts on public.spotify_accounts;
create policy own_spotify_accounts on public.spotify_accounts
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_group_members on public.group_members;
create policy own_group_members on public.group_members
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists group_members_email_read on public.group_members;
create policy group_members_email_read on public.group_members
  for select using (
    lower(coalesce(email, '')) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );

drop policy if exists own_member_invites on public.member_invites;
create policy own_member_invites on public.member_invites
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists member_invites_email_read on public.member_invites;
create policy member_invites_email_read on public.member_invites
  for select using (
    lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );

drop policy if exists member_invites_email_accept on public.member_invites;
create policy member_invites_email_accept on public.member_invites
  for update using (
    lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  ) with check (
    lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );

drop policy if exists own_lists on public.lists;
create policy own_lists on public.lists
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_list_items on public.list_items;
create policy own_list_items on public.list_items
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_notes on public.notes;
create policy own_notes on public.notes
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_alarms on public.alarms;
create policy own_alarms on public.alarms
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_timers on public.timers;
create policy own_timers on public.timers
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_reminders on public.reminders;
create policy own_reminders on public.reminders
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_activities on public.activities;
create policy own_activities on public.activities
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_device_connections on public.device_connections;
create policy own_device_connections on public.device_connections
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_app_notifications on public.app_notifications;
create policy own_app_notifications on public.app_notifications
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_skills on public.skills;
create policy own_skills on public.skills
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_world_clocks on public.world_clocks;
create policy own_world_clocks on public.world_clocks
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_tone_settings on public.tone_settings;
create policy own_tone_settings on public.tone_settings
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_aura_messages on public.aura_messages;
create policy own_aura_messages on public.aura_messages
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_call_sessions on public.call_sessions;
create policy own_call_sessions on public.call_sessions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists own_webrtc_signals on public.webrtc_signals;
create policy own_webrtc_signals on public.webrtc_signals
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Incremental app feature columns. These do not recreate profiles.
alter table if exists public.profiles
  add column if not exists avatar_url text,
  add column if not exists avatar_path text;

alter table if exists public.aura_groups
  add column if not exists image_url text,
  add column if not exists image_path text;

alter table if exists public.user_settings
  add column if not exists do_not_disturb boolean not null default false,
  add column if not exists notification_delivery boolean not null default true;

alter table if exists public.contacts
  add column if not exists avatar_url text;

alter table if exists public.devices
  add column if not exists group_id text;

alter table if exists public.group_members
  add column if not exists avatar_url text,
  add column if not exists avatar_path text;

alter table if exists public.alarms
  add column if not exists snooze_minutes integer not null default 10,
  add column if not exists vibrate boolean not null default true,
  add column if not exists volume integer not null default 100,
  add column if not exists ring_duration_seconds integer not null default 90,
  add column if not exists snoozed_until timestamptz;

alter table if exists public.timers
  add column if not exists elapsed_after_finish_seconds integer not null default 0,
  add column if not exists completed_at timestamptz;

alter table if exists public.reminders
  add column if not exists end_time text,
  add column if not exists repeat text not null default 'none',
  add column if not exists alert_minutes_before integer not null default 0,
  add column if not exists active boolean not null default true,
  add column if not exists last_triggered_at timestamptz;

create index if not exists idx_devices_group_id on public.devices(group_id);
create index if not exists idx_reminders_user_date_time on public.reminders(user_id, reminder_date, time);

drop policy if exists devices_group_member_read on public.devices;
create policy devices_group_member_read on public.devices
  for select using (
    user_id = auth.uid()
    or exists (
      select 1
      from public.group_members gm
      where gm.group_id = devices.group_id
        and (
          gm.user_id = auth.uid()
          or lower(coalesce(gm.email, '')) = lower(coalesce(auth.jwt() ->> 'email', ''))
        )
    )
  );

drop policy if exists devices_group_member_manage on public.devices;
create policy devices_group_member_manage on public.devices
  for all using (
    user_id = auth.uid()
    or exists (
      select 1
      from public.group_members gm
      where gm.group_id = devices.group_id
        and gm.user_id = auth.uid()
        and gm.can_manage_devices = true
    )
  ) with check (
    user_id = auth.uid()
    or exists (
      select 1
      from public.group_members gm
      where gm.group_id = devices.group_id
        and gm.user_id = auth.uid()
        and gm.can_manage_devices = true
    )
  );

insert into storage.buckets (id, name, public)
values ('aura-profile-photos', 'aura-profile-photos', false)
on conflict (id) do update set public = false;

drop policy if exists aura_profile_photos_read on storage.objects;
create policy aura_profile_photos_read on storage.objects
  for select using (
    bucket_id = 'aura-profile-photos'
    and (
      auth.uid()::text = (storage.foldername(name))[1]
      or exists (
        select 1
        from public.aura_groups ag
        where (storage.foldername(name))[2] = 'groups'
          and ag.id = (storage.foldername(name))[3]
          and (
            ag.owner_id = auth.uid()
            or exists (
              select 1
              from public.group_members gm
              where gm.group_id = ag.id
                and (
                  gm.user_id = auth.uid()
                  or lower(coalesce(gm.email, '')) =
                     lower(coalesce(auth.jwt() ->> 'email', ''))
                )
            )
          )
      )
    )
  );

drop policy if exists aura_profile_photos_write on storage.objects;
create policy aura_profile_photos_write on storage.objects
  for all using (
    bucket_id = 'aura-profile-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  ) with check (
    bucket_id = 'aura-profile-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

alter table if exists public.profiles enable row level security;

drop policy if exists aura_profiles_self on public.profiles;
create policy aura_profiles_self on public.profiles
  for all using (id = auth.uid()) with check (id = auth.uid());
