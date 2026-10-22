# Laravel Docker

Ambiente de desenvolvimento Laravel com Docker Compose, PHP-FPM, Nginx, PostgreSQL e Node.js. Os serviços são executados em containers separados para facilitar a organização, a manutenção e a reprodução do ambiente.

## Tecnologias utilizadas

- **PHP 8.4-FPM** — execução da aplicação Laravel.
- **Nginx 1.28** — servidor web e encaminhamento das requisições para o PHP-FPM.
- **PostgreSQL 17** — banco de dados relacional.
- **Node.js 22** — instalação das dependências do frontend e execução do Vite.
- **Vite 8** — compilação dos arquivos CSS e JavaScript.
- **Tailwind CSS 4** — estilização da interface.
- **Docker Compose** — gerenciamento dos containers e da rede do projeto.

## Estrutura do projeto

```text
laravel-docker/
├── .env
├── .env.example
├── .gitignore
├── .dockerignore
├── Dockerfile
├── compose.yml
├── README.md
├── docker/
│   └── nginx/
│       └── default.conf
└── app/
    ├── .env
    ├── .env.example
    ├── package.json
    ├── package-lock.json
    ├── artisan
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── public/
    ├── resources/
    ├── routes/
    ├── storage/
    └── ...
```

## Arquitetura dos containers

| Serviço | Função | Porta |
|---|---|---|
| `nginx` | Recebe as requisições HTTP e encaminha para o PHP-FPM | `8080` no host → `80` no container |
| `app` | Executa a aplicação Laravel com PHP-FPM | `9000`, interna |
| `db` | Armazena os dados no PostgreSQL | `5432`, interna |
| `node` | Instala dependências e compila os arquivos do frontend | Sem porta publicada |

Os serviços `app`, `nginx` e `db` compartilham a rede Docker `laravel_network`.

O serviço `node` também participa dessa rede e utiliza a pasta `app/` montada em `/var/www`. Ele é executado sob demanda, por meio de comandos `docker compose run --rm`, sem precisar permanecer em execução.

O banco de dados utiliza o volume persistente `postgres_data`, preservando os dados entre reinicializações dos containers.

## Pré-requisitos

Antes de iniciar, instale:

- Docker Engine ou Docker Desktop com integração ao ambiente Linux/WSL.
- Docker Compose v2.
- Git.

O Node.js não precisa estar instalado diretamente no sistema hospedeiro, pois é executado em um container separado.

## Configuração do ambiente

### 1. Clone o repositório

```bash
git clone URL_DO_REPOSITORIO
cd laravel-docker
```

Substitua `URL_DO_REPOSITORIO` pelo endereço real do repositório.

### 2. Configure as variáveis do Docker Compose

Crie o arquivo de ambiente da raiz:

```bash
cp .env.example .env
```

Edite `.env` e configure as variáveis necessárias para o Docker Compose, especialmente as credenciais do PostgreSQL.

O valor de `POSTGRES_PASSWORD` deve ser definido antes de iniciar os containers. Não utilize senhas reais em arquivos de exemplo publicados no repositório.

### 3. Configure o ambiente Laravel

Crie o arquivo de ambiente da aplicação:

```bash
cp app/.env.example app/.env
```

Edite `app/.env` e configure a conexão com o banco de dados:

```dotenv
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=sua_senha
```

Os valores do banco de dados devem corresponder às variáveis configuradas no arquivo `.env` da raiz.

O endereço `db` é o nome do serviço PostgreSQL dentro da rede Docker. Não utilize `localhost` como host do banco de dados a partir do container Laravel.

### 4. Inicie os containers

```bash
docker compose up -d --build
```

Verifique o estado dos serviços:

```bash
docker compose ps
```

### 5. Configure a chave da aplicação

Se `APP_KEY` ainda não estiver definida, gere uma chave para o ambiente local:

```bash
docker compose exec app php artisan key:generate
```

Não execute esse comando desnecessariamente em uma aplicação já configurada: trocar a chave pode invalidar dados criptografados e sessões existentes.

### 6. Instale as dependências PHP

Caso a pasta `vendor` ainda não exista, instale as dependências do Composer:

```bash
docker compose exec app composer install
```

### 7. Execute as migrações

```bash
docker compose exec app php artisan migrate
```

Esse comando cria ou atualiza as tabelas definidas pelas migrações da aplicação.

## Frontend: Node.js, npm e Vite

O Node.js está separado do container PHP. Isso mantém as ferramentas de frontend independentes das dependências necessárias para executar o Laravel.

O serviço `node` utiliza a imagem `node:22-alpine`, monta `./app` em `/var/www` e trabalha nesse diretório.

### Instalar as dependências

Execute na raiz do projeto:

```bash
docker compose run --rm node npm install
```

Esse comando instala as dependências definidas no `app/package.json`, gera ou atualiza `app/package-lock.json` e disponibiliza os pacotes em `app/node_modules`.

O arquivo `package-lock.json` deve ser versionado no Git para ajudar a reproduzir as versões instaladas. A pasta `node_modules` não deve ser enviada ao repositório.

### Compilar os arquivos para produção

```bash
docker compose run --rm node npm run build
```

O Vite gera os arquivos compilados em `app/public/build`.

Essa compilação pode ser executada novamente sempre que houver alterações nos arquivos de frontend.

### Modo de desenvolvimento

O projeto também define o comando:

```bash
docker compose run --rm --service-ports node npm run dev
```

O servidor de desenvolvimento do Vite precisa estar configurado para escutar em `0.0.0.0` e ter sua porta `5173` publicada no serviço `node` do Compose para ser acessível pelo navegador do host.

A configuração atual não publica essa porta. Portanto, o comando acima, sozinho, não garante que o servidor Vite possa ser acessado pelo navegador. Para usar atualização automática durante o desenvolvimento, ajuste a configuração do serviço e o `vite.config.js`.

## Acessar a aplicação

Com os containers iniciados, acesse:

**http://localhost:8080**

A porta externa é configurável pela variável `NGINX_PORT` no `.env` da raiz, cujo valor padrão é `8080`.

## Comandos úteis

### Gerenciar os containers

```bash
# Iniciar os serviços
docker compose up -d

# Reconstruir e iniciar
docker compose up -d --build

# Verificar os serviços
docker compose ps

# Consultar os logs
docker compose logs -f

# Consultar os logs de um serviço
docker compose logs -f app

# Parar os serviços
docker compose down
```

O comando `docker compose down` não remove o volume persistente do banco de dados. Evite usar `docker compose down -v` se quiser preservar os dados.

### Laravel e Artisan

```bash
# Verificar as migrações
docker compose exec app php artisan migrate:status

# Executar migrações
docker compose exec app php artisan migrate

# Limpar o cache de configuração
docker compose exec app php artisan config:clear

# Listar as rotas
docker compose exec app php artisan route:list
```

### Node.js e Vite

```bash
# Conferir a versão do Node.js
docker compose run --rm node node --version

# Conferir a versão do npm
docker compose run --rm node npm --version

# Instalar dependências
docker compose run --rm node npm install

# Compilar o frontend
docker compose run --rm node npm run build

# Listar as dependências instaladas
docker compose run --rm node npm ls --depth=0
```

## Persistência dos dados

Os dados do PostgreSQL são armazenados no volume Docker `postgres_data`.

Para listar os volumes:

```bash
docker volume ls
```

Para verificar os containers ativos:

```bash
docker ps
```

Os arquivos da aplicação são compartilhados com os containers por meio de volumes bind mount, permitindo editar o código no sistema hospedeiro.

## Segurança e GitHub

Os arquivos de ambiente reais podem conter senhas, tokens e chaves de criptografia. Eles não devem ser publicados no GitHub.

Este projeto utiliza `.gitignore` e `.dockerignore` para excluir arquivos de ambiente e dependências locais. Antes de enviar alterações ao repositório, confira o estado do Git:

```bash
git status --short
```

Confira também se arquivos sensíveis já estão sendo rastreados:

```bash
git ls-files -- .env app/.env
```

Os arquivos `.env.example` podem ser versionados, desde que contenham apenas valores de exemplo e nenhuma credencial real.

As pastas `vendor`, `node_modules` e `public/build` não precisam ser enviadas ao Git neste fluxo de trabalho. As dependências podem ser instaladas e o frontend compilado conforme descrito acima.

## Solução de problemas

### A aplicação não abre

Verifique os containers e os logs:

```bash
docker compose ps
docker compose logs -f nginx app
```

### Erro de conexão com o PostgreSQL

Confira se o serviço `db` está saudável e se as variáveis de conexão do arquivo `app/.env` correspondem às credenciais configuradas na raiz.

```bash
docker compose ps
docker compose logs db
```

### Alterações no frontend não aparecem

Execute novamente a compilação:

```bash
docker compose run --rm node npm run build
```

Confirme se os arquivos foram gerados em `app/public/build`.

### Dependências do Node.js com problemas

Reinstale as dependências:

```bash
docker compose run --rm node npm install
```

Se o problema persistir, verifique as mensagens de erro antes de remover arquivos ou alterar versões de dependências.

## Licença

Defina a licença do projeto conforme a sua intenção de distribuição e reutilização.
