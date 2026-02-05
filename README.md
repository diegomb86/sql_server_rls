# RLS (Row-Level Security) no SQL Server

Este repositório é um exemplo mínimo de implementação de RLS para restringir linhas por empresa. O script principal está em `step_by_step.sql`.

## Como usar
- Abra `step_by_step.sql` e execute na ordem dos passos.
- Substitua os placeholders `<<...>>` pelos seus valores reais (usuários, schema, tabelas e coluna de negócio).
- Ajuste a lógica da função `security.fn_rls_business` conforme a sua regra de acesso.

## O que o script faz
- Cria logins e usuários.
- Concede permissões de leitura.
- Cria tabela de mapeamento `security.user_business`.
- Cria a função de filtro do RLS.
- Cria e ativa a security policy.
- Mostra testes com `EXECUTE AS`.
