--Passo 1: Criar os LOGINS
USE master;
GO

CREATE LOGIN usuario_1 WITH PASSWORD = 'SenhaForte#Usuario1_2026';
CREATE LOGIN usuario_2 WITH PASSWORD = 'SenhaForte#Usuario2_2026';
CREATE LOGIN usuario_3 WITH PASSWORD = 'SenhaForte#Usuario3_2026';
GO

--Passo 2: Criar os USUÁRIOS no banco dw
USE dw;
GO

CREATE USER usuario_1 FOR LOGIN usuario_1;
CREATE USER usuario_2 FOR LOGIN usuario_2;
CREATE USER usuario_3 FOR LOGIN usuario_3;
GO

--Passo 3: Dar permissão de leitura (somente o necessário)
USE dw;
GO

GRANT SELECT ON SCHEMA::dbo TO usuario_1;
GRANT SELECT ON SCHEMA::dbo TO usuario_2;
GRANT SELECT ON SCHEMA::dbo TO usuario_3;
GO

--Passo 4: Criar a tabela de mapeamento do RLS (uma vez só)
USE dw;
GO
CREATE SCHEMA security;
GO

CREATE TABLE security.user_business (
    username    sysname NOT NULL,
    id_business varchar(20)     NOT NULL,
    CONSTRAINT PK_user_business PRIMARY KEY (username, id_business)
);
GO

--Passo 5: Mapear cada usuário à sua empresa
INSERT INTO security.user_business (username, id_business)
VALUES
('<<usuario_1>>',   '<<codigo da empresa 1>>'),
('<<usuario_2>>',   '<<codigo da empresa 2>>'),
('<<usuario_3>>',   '<<codigo da empresa 3>>');
GO

--Passo 6: Criar a função do RLS (uma vez só)
ALTER FUNCTION security.fn_rls_business (@id_business VARCHAR(20))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    -- Nesse exemplo, por padrão os usuarios que não estão no rls, terão acesso a todos os registros.
	-- Ajustar conforme a necessidade.
	SELECT 1 AS permitido
    WHERE
        -- se o usuário NÃO tem nenhum registro na user_business → bypass total
        NOT EXISTS (
            SELECT 1
            FROM security.user_business ub
            WHERE ub.username = USER_NAME()
        )

        -- se tem registro → só passa se a empresa estiver mapeada
        OR EXISTS (
            SELECT 1
            FROM security.user_business ub
            WHERE ub.username = USER_NAME()
              AND ub.id_business = @id_business
        )

);
GO

--Passo 7: Criar a security policy
CREATE SECURITY POLICY security.rls_policy_business	
	WITH (STATE = OFF);
GO

--Passo 7.1: Aplicar nas tabelas multiempresa (Apenas uma vez)
ALTER SECURITY POLICY security.rls_policy_business
	
	ADD FILTER PREDICATE security.fn_rls_business(<<nome_coluna_business>>) ON <<nome_schema>>.<<nome_tabela>>,	
	-- [...] Adicionar todas as tabelas, a ultima linha finalizar com ';'
GO

-- Passo 7.2: Ligar policy
ALTER SECURITY POLICY security.rls_policy_business
	WITH (STATE = ON);


--Passo 8: Teste
EXECUTE AS USER = 'usuario_1';
SELECT TOP 10 * FROM <<nome_schema>>.<<nome_tabela>>;  -- deve vir só dados da Empresa 1
REVERT;

EXECUTE AS USER = 'usuario_2';
SELECT TOP 10 * FROM <<nome_schema>>.<<nome_tabela>>;  -- deve vir só dados da Empresa 2
REVERT;



