# Agenda de Férias CTIC

Página estática de inclusão e acompanhamento de férias, licenças e banco de horas por equipe, com login Google e banco de dados em tempo real no Supabase.

- **App:** https://renatochavesp-gif.github.io/ferias-ctic/
- **Banco de dados:** Supabase (projeto `ferias-ctic`, ref `hwvwxvfdfsjcmzinvipy`)
- **Hospedagem:** GitHub Pages (arquivo estático, sem build)

## Estrutura

```
index.html          # app inteiro (HTML + CSS + JS), usa o SDK do Supabase no navegador
supabase/schema.sql  # schema do banco (tabelas + regras de segurança), para referência/recriação
```

## Como funciona o acesso

- Login via "Entrar com o Google" (Supabase Auth).
- Só quem tem o e-mail cadastrado na tabela `colaboradores` consegue ler ou gravar dados — reforçado por Row Level Security no Postgres, não só na tela.
- Para dar acesso a alguém novo: um colaborador já autorizado entra na aba **Equipes & colaboradores** e preenche o campo "E-mail (login)" com o Gmail da pessoa.

## Configuração pendente (feita manualmente, uma única vez)

O login com Google depende de uma credencial OAuth do Google Cloud, que precisa ser criada fora daqui:

1. **Google Cloud Console** → APIs e Serviços → Credenciais → Criar credenciais → **ID do cliente OAuth** → tipo "Aplicativo da Web".
   - Origens JavaScript autorizadas: `https://renatochavesp-gif.github.io`
   - URI de redirecionamento autorizado: `https://hwvwxvfdfsjcmzinvipy.supabase.co/auth/v1/callback`
2. Copiar o **Client ID** e o **Client Secret** gerados.
3. No **Supabase Dashboard** do projeto `ferias-ctic` → Authentication → Sign In / Providers → **Google** → colar as duas chaves e ativar.

Sem esse passo o botão "Entrar com o Google" não funciona (o Google recusa o login por origem/redirecionamento não autorizado).

## Banco de dados

Tabelas: `equipes`, `colaboradores` (com `saldos` em JSON por ano) e `ferias` (férias/licença/banco de horas/trabalha-no-recesso). O saldo "restante" de cada período é sempre calculado a partir dos lançamentos reais em `ferias`, nunca guardado como número solto — isso evita o problema que existia na planilha original, onde os totais podiam ficar desatualizados.

Ver `supabase/schema.sql` para o schema completo e comentado.
