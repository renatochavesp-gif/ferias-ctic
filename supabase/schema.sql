-- Agenda de Férias CTIC — schema do Supabase
-- Rode este arquivo no SQL Editor do Supabase se precisar recriar o banco do zero.
-- (No projeto atual isso já foi aplicado via migrations pelo conector do Supabase.)

create table if not exists equipes (
  id text primary key,
  nome text not null,
  limite int not null default 1
);

create table if not exists colaboradores (
  id text primary key,
  nome text not null,
  matricula text not null,
  equipe_id text not null references equipes(id),
  papel text not null default 'servidor' check (papel in ('servidor','chefe','substituto','estagiario')),
  email text,
  saldos jsonb not null default '{}'::jsonb
);

create table if not exists ferias (
  id uuid primary key default gen_random_uuid(),
  colaborador_id text not null references colaboradores(id),
  equipe_id text not null references equipes(id),
  tipo text not null check (tipo in ('ferias','licenca','bancoHoras','trabalhaRecesso')),
  inicio date not null,
  fim date not null,
  ano_referencia text,
  criado_em timestamptz not null default now()
);

create unique index if not exists colaboradores_email_key on colaboradores (lower(email)) where email is not null;

-- Só quem tem e-mail cadastrado em `colaboradores` pode ler/escrever qualquer tabela.
-- A função fica num schema não exposto pela API (evita chamada direta via /rest/v1/rpc).
create schema if not exists private;

create or replace function private.is_authorized() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (
    select 1 from colaboradores c
    where c.email is not null
      and lower(c.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

revoke all on function private.is_authorized() from public;
grant execute on function private.is_authorized() to anon, authenticated;

alter table equipes enable row level security;
alter table colaboradores enable row level security;
alter table ferias enable row level security;

create policy "authorized_all" on equipes for all using (private.is_authorized()) with check (private.is_authorized());
create policy "authorized_all" on colaboradores for all using (private.is_authorized()) with check (private.is_authorized());
create policy "authorized_all" on ferias for all using (private.is_authorized()) with check (private.is_authorized());

-- Habilita atualização em tempo real (usada pelo index.html via supabase-js Realtime)
alter publication supabase_realtime add table equipes, colaboradores, ferias;

-- Tabela usada pela rotina .github/workflows/keep-alive.yml para gerar atividade real no
-- banco e evitar a pausa automática do plano gratuito (7 dias sem uso). Linha única.
create table if not exists keepalive (
  id int primary key check (id = 1),
  ts timestamptz not null default now()
);
alter table keepalive enable row level security;
create policy "keepalive_insert" on keepalive for insert to anon with check (id = 1);
create policy "keepalive_update" on keepalive for update to anon using (id = 1) with check (id = 1);
create policy "keepalive_select" on keepalive for select to anon using (id = 1);
