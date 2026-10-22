# Laravel Docker

[![Docker](https://img.shields.io/badge/Docker-Containerização-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Laravel](https://img.shields.io/badge/Laravel-PHP_Framework-FF2D20?logo=laravel&logoColor=white)](https://laravel.com/)
[![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&logoColor=white)](https://www.php.net/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)

Ambiente de desenvolvimento Laravel utilizando Docker Compose, PHP-FPM, Nginx e PostgreSQL.

O objetivo deste projeto é simplificar a criação e a execução de aplicações Laravel por meio de contêineres Docker, proporcionando um ambiente organizado, reproduzível e fácil de configurar.

## 📑 Sumário

- [Tecnologias utilizadas](#-tecnologias-utilizadas)
- [Arquitetura do projeto](#-arquitetura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Configuração do ambiente](#-configuração-do-ambiente)
- [Executando a aplicação](#-executando-a-aplicação)
- [Banco de dados e migrações](#-banco-de-dados-e-migrações)
- [Comandos úteis](#-comandos-úteis)
- [Persistência dos dados](#-persistência-dos-dados)
- [Solução de problemas](#-solução-de-problemas)
- [Segurança](#-segurança)

## 🛠️ Tecnologias utilizadas

| Tecnologia | Finalidade |
|---|---|
| [Docker](https://www.docker.com/) | Executar os serviços em contêineres isolados. |
| [Docker Compose](https://docs.docker.com/compose/) | Gerenciar os serviços e suas configurações. |
| [Laravel](https://laravel.com/) | Framework PHP da aplicação. |
| [PHP-FPM](https://www.php.net/) | Processar o código PHP. |
| [Nginx](https://nginx.org/) | Receber requisições HTTP e encaminhá-las ao PHP-FPM. |
| [PostgreSQL](https://www.postgresql.org/) | Armazenar os dados da aplicação. |
| [Composer](https://getcomposer.org/) | Gerenciar as dependências PHP. |

## 🏗️ Arquitetura do projeto

A aplicação utiliza três serviços principais:

```text
                 Navegador
                     |
                     v
               localhost:8080
                     |
                     v
              +-------------+
              |    Nginx    |
              +-------------+
                     |
                     v
              +-------------+
              | PHP-FPM /   |
              |   Laravel   |
              +-------------+
                     |
                     v
              +-------------+
              | PostgreSQL  |
              +-------------+
```

Os serviços se comunicam por meio de uma rede Docker, permitindo que a aplicação acesse o banco de dados pelo nome do serviço, sem precisar expor a porta do PostgreSQL ao navegador.

## 📁 Estrutura do projeto

```text
laravel-docker/
├── .env.example
├── .gitignore
├── .dockerignore
├── Dockerfile
├── compose.yaml
├── README.md
│
├── docker/
│   └── nginx/
│       └── default.conf
│
└── app/
    ├── .env.example
    ├── artisan
    ├── composer.json
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── public/
    ├── resources/
    ├── routes/
    ├── storage/
    └── tests/
```

### Principais arquivos

- `compose.yaml`: define os serviços, a rede e os volumes do Docker.
- `Dockerfile`: define como a imagem PHP da aplicação é construída.
- `docker/nginx/default.conf`: configura o servidor Nginx.
- `.env.example`: apresenta as variáveis necessárias ao Docker Compose.
- `app/.env.example`: apresenta as variáveis necessárias ao Laravel.
- `app/`: contém o código-fonte da aplicação Laravel.
- `README.md`: documenta a instalação e o uso do projeto.

> Os arquivos `.env` reais são criados localmente e não devem ser enviados ao GitHub.

## 📋 Pré-requisitos

Antes de começar, certifique-se de que possui:

- [Git](https://git-scm.com/downloads) instalado.
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) com integração WSL 2, para Windows com WSL, ou Docker Engine e Docker Compose, para Linux.
- Acesso ao repositório deste projeto.

Não é necessário instalar PHP, Composer, Nginx ou PostgreSQL diretamente no sistema operacional, desde que os serviços estejam configurados nos contêineres.

## 🚀 Instalação

### 1. Clone o repositório

No terminal, execute:

```bash
git clone URL_DO_REPOSITORIO
```

Entre na pasta do projeto:

```bash
cd laravel-docker
```

Substitua `URL_DO_REPOSITORIO` pelo endereço real do repositório no GitHub.

### 2. Crie o arquivo de ambiente do Docker

Na raiz do projeto, execute:

```bash
cp .env.example .env
```

Esse arquivo contém as variáveis utilizadas pelo Docker Compose.

### 3. Crie o arquivo de ambiente do Laravel

Execute:

```bash
cp app/.env.example app/.env
```

Esse arquivo contém as configurações específicas da aplicação Laravel.

## ⚙️ Configuração do ambiente

### 1. Configure as variáveis do Docker

Abra o arquivo `.env` da raiz e confira as variáveis utilizadas no `compose.yaml`.

Exemplo ilustrativo:

```dotenv
APP_UID=1000
APP_GID=1000
NGINX_PORT=8080

POSTGRES_DB=laravel
POSTGRES_USER=laravel
POSTGRES_PASSWORD=altere_esta_senha
```

Os nomes e os valores devem corresponder à configuração real do projeto.

Utilize uma senha própria no seu ambiente local.

### 2. Configure o Laravel

Abra o arquivo `app/.env` e configure as variáveis da aplicação.

Exemplo:

```dotenv
APP_NAME=Laravel
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8080

DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=altere_esta_senha
```

Ajuste as credenciais para que correspondam às utilizadas pelo serviço PostgreSQL no arquivo `.env` da raiz.

**Importante:** dentro da rede Docker, o Laravel deve utilizar `DB_HOST=db`, considerando que `db` é o nome do serviço no `compose.yaml`. O endereço `localhost` dentro do contêiner apontaria para o próprio contêiner, e não para o banco de dados.

### 3. Inicie os serviços

Na raiz do projeto, execute:

```bash
docker compose up -d --build
```

Esse comando constrói as imagens necessárias e inicia os serviços em segundo plano.

Confira se os contêineres estão em execução:

```bash
docker compose ps
```

### 4. Gere a chave da aplicação

Com o serviço `app` em execução, execute:

```bash
docker compose exec app php artisan key:generate
```

O comando gera uma chave de criptografia e atualiza o arquivo de ambiente utilizado pelo Laravel.

Não compartilhe o valor de `APP_KEY` nem o publique no repositório.

> Execute a geração da chave durante a configuração inicial. Não substitua uma chave já utilizada por uma aplicação com dados existentes sem avaliar as consequências.

## 🌐 Executando a aplicação

Depois de iniciar os serviços, abra o navegador no endereço:

**[http://localhost:8080](http://localhost:8080)**

Se a variável `NGINX_PORT` estiver configurada com outro valor, utilize a porta correspondente.

Para acompanhar os registros dos serviços:

```bash
docker compose logs -f
```

Para interromper a visualização dos registros, pressione `Ctrl + C`. Isso não encerra os contêineres.

## 🗄️ Banco de dados e migrações

As migrações do Laravel definem a estrutura das tabelas do banco de dados.

Para executar as migrações pendentes:

```bash
docker compose exec app php artisan migrate
```

Para verificar o estado das migrações:

```bash
docker compose exec app php artisan migrate:status
```

Antes de executar migrações, verifique se o PostgreSQL está em execução e se as credenciais estão corretas.

> Em ambientes com dados importantes, faça backups antes de realizar alterações estruturais no banco de dados.

## ⌨️ Comandos úteis

Execute os comandos a seguir na raiz do projeto.

### Docker Compose

| Comando | Descrição |
|---|---|
| `docker compose up -d` | Inicia os serviços. |
| `docker compose up -d --build` | Reconstrói as imagens e inicia os serviços. |
| `docker compose ps` | Lista os serviços e seus estados. |
| `docker compose logs -f` | Acompanha os registros em tempo real. |
| `docker compose logs app` | Exibe os registros do serviço Laravel/PHP. |
| `docker compose logs nginx` | Exibe os registros do Nginx. |
| `docker compose logs db` | Exibe os registros do PostgreSQL. |
| `docker compose restart` | Reinicia os serviços. |
| `docker compose down` | Para e remove os contêineres e a rede criada pelo Compose. |

### Laravel

| Comando | Descrição |
|---|---|
| `docker compose exec app php artisan about` | Exibe informações sobre a aplicação. |
| `docker compose exec app php artisan route:list` | Lista as rotas registradas. |
| `docker compose exec app php artisan migrate:status` | Consulta o estado das migrações. |
| `docker compose exec app php artisan config:clear` | Limpa o cache de configuração. |
| `docker compose exec app php artisan cache:clear` | Limpa o cache da aplicação. |
| `docker compose exec app composer install` | Instala as dependências PHP. |

O comando `docker compose exec` executa uma instrução dentro de um contêiner que já está em execução.

## 💾 Persistência dos dados

O PostgreSQL utiliza um volume Docker denominado `postgres_data`, conforme a configuração do projeto.

Isso permite manter os dados do banco mesmo quando os contêineres são removidos com:

```bash
docker compose down
```

Para iniciar o ambiente novamente:

```bash
docker compose up -d
```

**Atenção:** o comando abaixo pode remover os volumes e apagar os dados persistidos do banco:

```bash
docker compose down -v
```

Utilize-o somente se realmente quiser remover os volumes associados.

## 🔧 Solução de problemas

### A página não abre

Verifique o estado dos serviços:

```bash
docker compose ps
```

Consulte os registros do Nginx e da aplicação:

```bash
docker compose logs nginx app
```

Confira se a porta configurada em `NGINX_PORT` está correta e disponível.

### Erro de conexão com o PostgreSQL

Verifique:

- Se o serviço `db` está em execução.
- Se `DB_HOST=db` está definido em `app/.env`.
- Se o banco, o usuário e a senha correspondem às configurações do PostgreSQL.
- Se o banco já terminou sua inicialização.

### Erro relacionado à `APP_KEY`

Verifique se `APP_KEY` está definida corretamente em `app/.env`.

Para gerar a chave durante a configuração inicial, com o serviço `app` em execução:

```bash
docker compose exec app php artisan key:generate
```

Depois, limpe o cache de configuração:

```bash
docker compose exec app php artisan config:clear
```

### Erro de dependências PHP

Se a pasta `vendor/` não existir, instale as dependências com:

```bash
docker compose exec app composer install
```

Esse comando exige que o serviço `app` esteja em execução e que o Composer esteja disponível no contêiner.

### Erro de permissões

Se ocorrerem erros de permissão em `storage/` ou `bootstrap/cache/`, verifique o usuário configurado no contêiner e as permissões desses diretórios.

Evite utilizar `chmod -R 777` como solução padrão.

## 🔐 Segurança

Este projeto destina-se inicialmente ao desenvolvimento local.

Antes de utilizar a aplicação em produção:

- Nunca publique arquivos `.env` reais.
- Não compartilhe senhas, tokens ou chaves privadas.
- Mantenha os arquivos `.env.example` sem credenciais reais.
- Desative `APP_DEBUG` em produção.
- Configure HTTPS e permissões adequadas.
- Planeje backups do banco de dados.
- Revise as portas expostas e as configurações dos contêineres.
- Utilize credenciais específicas e seguras para produção.

Se alguma credencial real já tiver sido publicada no GitHub, removê-la do arquivo não é suficiente: a credencial deve ser substituída.

## 📄 Licença

Se pretende permitir que outras pessoas utilizem, modifiquem ou distribuam este projeto, escolha e adicione uma licença apropriada.

Sem uma licença, não presuma que terceiros têm autorização irrestrita para reutilizar o código.

---

Desenvolvido para facilitar a criação de ambientes Laravel com Docker, tornando a configuração mais simples, organizada e reproduzível.
