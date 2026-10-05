-- =============================================================
-- Schema do banco de dados: bd-alunos
-- Projeto: aluno-crud
-- SGBD: PostgreSQL
-- =============================================================

-- Tabela de alunos
CREATE TABLE  alunos (
    id_aluno      SERIAL       PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    matricula     VARCHAR(20)  NOT NULL UNIQUE,
    cpf           CHAR(11)     NOT NULL UNIQUE,
    data_admissao TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);


