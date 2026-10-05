# aluno-crud

Aplicação de console em **Java** para gerenciamento de alunos (**CRUD**), com persistência em **PostgreSQL** via **JDBC** puro. O projeto ainda é um esqueleto em evolução, organizado em camadas (entidade, fábrica de conexão, repositório e serviço).

---

## 📋 Sumário

- [Sobre o projeto](#-sobre-o-projeto)
- [Tecnologias](#-tecnologias)
- [Arquitetura](#-arquitetura)
- [Estrutura de pastas](#-estrutura-de-pastas)
- [Pré-requisitos](#-pré-requisitos)
- [Como executar](#-como-executar)
- [Banco de dados](#-banco-de-dados)
- [Funcionalidades](#-funcionalidades)
- [Observações e limitações](#-observações-e-limitações)
- [Roadmap](#-roadmap)
- [Autor](#-autor)

---

## 📖 Sobre o projeto

O **aluno-crud** é um exemplo didático de CRUD em Java sem frameworks de persistência (sem Spring Data, sem Hibernate). O acesso ao banco é feito diretamente com a API **JDBC** do próprio Java, e a infraestrutura do PostgreSQL/PgAdmin é provida por **Docker Compose**.

O objetivo é demonstrar, de forma simples e clara:

- Conexão direta com o PostgreSQL através do `DriverManager`;
- Uso de `PreparedStatement` para comandos SQL parametrizados (evitando SQL Injection);
- Organização do código em camadas desacopladas;
- Criação do schema do banco versionada em `schema.sql`.

---

## 🛠 Tecnologias

| Tecnologia        | Versão / Detalhe              |
| ----------------- | ----------------------------- |
| Java              | 27 (`maven.compiler.source`)  |
| Maven             | Gerenciador de build          |
| PostgreSQL JDBC   | `42.7.13`                     |
| PostgreSQL        | `16-alpine` (via Docker)      |
| PgAdmin 4         | `dpage/pgadmin4` (via Docker) |
| Docker Compose    | Infraestrutura local          |

> Para rodar o projeto você precisa do **JDK 27+** e do **Maven** instalados (ou a IDE IntelliJ IDEA).

---

## 🧱 Arquitetura

O projeto segue uma separação simples em camadas:

```
Main  →  (AlunoService)  →  AlunoRepository  →  ConnectionFactory  →  PostgreSQL
         (regras/entrada)   (acesso a dados)     (conexão JDBC)
```

- **`entities`** – modelo de domínio (`Aluno`).
- **`factories`** – criação de conexões com o banco (`ConnectionFactory`).
- **`repositories`** – comandos SQL e acesso aos dados (`AlunoRepository`).
- **`services`** – interação com o usuário via terminal (`AlunoService`), com `Scanner`.

---

## 📁 Estrutura de pastas

```
aluno-crud/
├── docker-compose.yml                 # PostgreSQL (5433) + PgAdmin (5051)
├── pom.xml                            # Dependências e configuração Maven
├── src/
│   └── main/
│       ├── java/
│       │   └── cotiinformatica/
│       │       ├── Main.java                    # Ponto de entrada (esqueleto)
│       │       ├── entities/
│       │       │   └── Aluno.java               # Entidade
│       │       ├── factories/
│       │       │   └── ConnectionFactory.java   # Conexão JDBC
│       │       ├── repositories/
│       │       │   └── AlunoRepository.java     # CRUD (SQL)
│       │       └── services/
│       │           └── AlunoService.java        # Menu/entrada do usuário
│       └── resources/
│           └── schema.sql             # Script de criação da tabela `alunos`
└── target/                            # Saída do build (ignorado no Git)
```

---

## ✅ Pré-requisitos

- [Docker](https://www.docker.com/) e [Docker Compose](https://docs.docker.com/compose/) *(para o banco)*
- JDK 27+
- Maven 3.9+ *(ou usar o IntelliJ IDEA)*

---

## 🚀 Como executar

### 1. Subir o banco de dados e o PgAdmin

Na raiz do projeto:

```bash
docker compose up -d
```

Isso sobe:

| Serviço   | Host (sua máquina)        | Container | Credenciais                            |
| --------- | ------------------------- | --------- | -------------------------------------- |
| PostgreSQL| `localhost:5433`          | `5432`    | DB `bd-alunos` \| user `coti` \| senha `coti` |
| PgAdmin   | http://localhost:5051     | `80`      | e-mail `coti@email.com` \| senha `Coti@2026` |

> No PgAdmin, ao criar a conexão com o servidor, use o host **`postgres`** e a porta **`5432`** (nome/porta internos da rede Docker).

### 2. Criar o schema (tabela `alunos`)

Execute o script `src/main/resources/schema.sql` no banco. Via `psql`:

```bash
psql "postgresql://coti:coti@localhost:5433/bd-alunos" -f src/main/resources/schema.sql
```

Ou cole o conteúdo do arquivo no Query Tool do PgAdmin.

### 3. Compilar

```bash
mvn clean compile
```

### 4. Executar

```bash
mvn exec:java -Dexec.mainClass="cotiinformatica.Main"
```

Ou rode a classe `Main` diretamente pela IDE.

---

## 🗄 Banco de dados

Configuração da conexão em `ConnectionFactory.java`:

```java
var host     = "jdbc:postgresql://localhost:5433/bd-alunos";
var user     = "coti";
var password = "coti";
```

Schema criado por `schema.sql`:

```sql
CREATE TABLE IF NOT EXISTS alunos (
    id_aluno      SERIAL       PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    matricula     VARCHAR(20)  NOT NULL UNIQUE,
    cpf           CHAR(11)     NOT NULL UNIQUE,
    data_admissao TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

> **`data_admissao` é preenchida automaticamente no momento do `INSERT`** (`DEFAULT CURRENT_TIMESTAMP`), por isso o repositório não precisa informá-la.

---

## ⚙️ Funcionalidades

| Operação | Método no serviço     | SQL no repositório                     | Status |
| -------- | --------------------- | -------------------------------------- | ------ |
| Criar    | `cadastrarAluno()`    | `INSERT INTO alunos (nome, matricula, cpf)` | ✅ Implementado |
| Listar   | `consultarAlunos()`   | `SELECT id_aluno, nome, matricula, cpf`| ✅ Implementado |
| Atualizar| `atualizarAluno()`    | `UPDATE alunos SET ... WHERE id_aluno` | ✅ Implementado |
| Excluir  | `excluirAluno()`      | `DELETE FROM alunos WHERE id_aluno`    | ✅ Implementado |

Campos do aluno: `idAluno`, `nome`, `matricula`, `cpf` e `data_admissao` (automática no banco).

---

## ⚠️ Observações e limitações

- A classe **`Main` ainda não está integrada** ao `AlunoService` — atualmente só imprime "Hello and welcome!". É preciso criar um menu que invoque `cadastrarAluno()`, `consultarAlunos()`, `atualizarAluno()` e `excluirAluno()`.
- **Credenciais do banco estão fixas no código** (`ConnectionFactory`). Para produção, use variáveis de ambiente ou arquivo de configuração.
- O `Scanner` é recriado a cada chamada de serviço; o ideal é reutilizar uma única instância.
- Não há tratamento de exceções de negócio detalhado (apenas `printStackTrace`/mensagem genérica).
- Não há testes automatizados.
- O `pom.xml` não declara plugin de execução nem classe principal no empacotamento.

---

## 🗺 Roadmap

- [ ] Criar o menu interativo na `Main` e integrar com `AlunoService`.
- [ ] Adicionar o campo `dataAdmissao` na entidade `Aluno` e exibi-lo na listagem.
- [ ] Externalizar as credenciais (variáveis de ambiente / `.env`).
- [ ] Validações de entrada (CPF, matrícula, campos obrigatórios).
- [ ] Testes unitários (JUnit) para o repositório e o serviço.
- [ ] Migrar acesso a dados para JPA/Hibernate (opcional, como evolução).

---

## 👤 Autor

Desenvolvido por **gabriel22091998** — projeto de estudo de CRUD em Java com JDBC e PostgreSQL.

---

## 📄 Licença

Este projeto é de uso educacional. Defina aqui a licença desejada (ex.: MIT).
