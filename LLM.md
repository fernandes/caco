# Caco - Guia para LLM

Caco é uma gem Ruby para configuração de máquinas no estilo "infrastructure as code", inspirada em ferramentas como Puppet/Chef, mas com uma abordagem mais Ruby-like.

## Arquitetura

```
control-repo/              # Repositório de configuração
├── Gemfile                # Inclui gem 'caco'
├── bin/caco               # Executável principal
├── data/                  # Dados hierárquicos (YAML)
│   ├── common.yaml        # Valores comuns a todas as máquinas
│   ├── os/
│   │   ├── Darwin.yaml    # Valores específicos para macOS
│   │   └── Debian.yaml    # Valores específicos para Debian
│   └── nodes/
│       └── hostname.yaml  # Valores específicos por hostname
├── keys/                  # Chaves eyaml (não commitadas)
│   ├── private_key.pkcs7.pem
│   └── public_key.pkcs7.pem
└── nodes/                 # Arquivos de configuração por máquina
    ├── xeon.lab.rb        # Config para máquina "xeon.lab"
    └── caco/              # Módulos compartilhados
        ├── fernandes.rb
        └── fernandes/
            └── view/      # Templates ERB
```

## Resources Principais (DSL)

### Caco.file
Cria/modifica arquivos no sistema.

```ruby
# Criar arquivo com conteúdo
Caco.file "/path/to/file.txt",
  content: "conteúdo do arquivo",
  owner: "user",        # opcional
  group: "group",       # opcional
  mode: 0644            # opcional, usar notação octal

# Criar diretório
Caco.file "/path/to/dir",
  guard: :directory,
  owner: "user"

# Deletar arquivo
Caco.file "/path/to/file",
  guard: :absent
```

**Parâmetros:**
- `name` (String): Caminho absoluto do arquivo
- `content` (String, opcional): Conteúdo do arquivo
- `owner` (String, opcional): Usuário proprietário
- `group` (String, opcional): Grupo proprietário
- `mode` (Integer, opcional): Permissões (ex: 0755, 0600)
- `guard` (Symbol): `:present` (padrão), `:absent`, `:directory`

### Caco.execute
Executa comandos shell.

```ruby
# Comando simples
Caco.execute "install package",
  command: "apt-get install -y nginx"

# Com usuário específico
Caco.execute "run as user",
  command: "bundle install",
  user: "deploy",
  cwd: "/home/deploy/app"

# Com streaming de output
Caco.execute "long running",
  command: "make build",
  stream_output: ->(key, line) { puts "[#{key}] #{line}" }
```

**Parâmetros:**
- `name` (String): Descrição do comando
- `command` (String/Array, opcional): Comando a executar (se nil, usa name)
- `user` (String, opcional): Usuário para executar (usa `runuser`)
- `cwd` (String, opcional): Diretório de trabalho
- `stream_output` (Proc, opcional): Callback para output em tempo real

**Retorno:** `Caco::Resource::Result` com:
- `exit_code`: Código de saída
- `output`: stdout
- `stderr`: stderr
- `success?`: Boolean

### Caco.package
Instala/remove pacotes do sistema.

```ruby
# Instalar pacote (formula no macOS, apt no Debian)
Caco.package "nginx"

# Instalar cask no macOS
Caco.package "visual-studio-code", source: :cask

# Remover pacote
Caco.package "apache2", guard: :absent
```

**Parâmetros:**
- `name` (String): Nome do pacote
- `guard` (Symbol): `:present` (padrão) ou `:absent`
- `source` (Symbol, opcional): `:cask` para Homebrew casks no macOS

**Providers automáticos:**
- macOS: Homebrew (`BrewProvider`) - suporta formulas e casks
- Debian: APT (`AptProvider`)

### Caco.service
Habilita/desabilita serviços.

```ruby
# Habilitar serviço
Caco.service "nginx"

# Desabilitar serviço
Caco.service "apache2", guard: :absent
```

**Providers automáticos:**
- macOS: launchd (`LaunchdProvider`)
- Debian: systemd (`SystemdProvider`)

## Sistema de Dados (Settings)

Os dados são carregados hierarquicamente do menos para o mais específico:

1. `data/common.yaml`
2. `data/os/<OS>.yaml` (Darwin, Debian, etc.)
3. `data/os/<OS>/<distro>.yaml` (ex: bookworm, jammy)
4. `data/nodes/<fqdn>.yaml`

### Acessando dados

```ruby
# Via Settings (gem config)
Settings.home              # => "/home/fernandes"
Settings.aws.cf2.access_key_id

# Via Facter (dados do sistema)
Caco::Facter.("os", "name")           # => "Debian" ou "Darwin"
Caco::Facter.("kernel")               # => "Linux" ou "Darwin"
Caco::Facter.("networking", "fqdn")   # => "xeon.lab"
```

### Criptografia eyaml

Valores sensíveis são criptografados com PKCS7:

```yaml
# data/common.yaml
fernandes:
  github_token: ENC[PKCS7,MIIBmQ...]
```

Para criar/editar valores criptografados:
```bash
eyaml createkeys              # Primeira vez: cria chaves
eyaml edit data/common.yaml   # Edita arquivo com valores criptografados
```

## Módulos Disponíveis

### Caco::Debian
```ruby
Caco::Debian::PackageInstall.(name: "nginx")
Caco::Debian::AptUpdate.()
Caco::Debian::AptRepoAdd.(repo: "deb http://...")
Caco::Debian::AptKeyInstall.(key_url: "https://...")
Caco::Debian::ServiceEnable.(name: "nginx")
Caco::Debian::AddUser.(user: "deploy")
```

### Caco::Macos
```ruby
# Habilitar SSH (Remote Login)
Caco::Macos::RemoteLogin.enable
Caco::Macos::RemoteLogin.disable
Caco::Macos::RemoteLogin.enabled?  # => true/false
```

### Caco::Ssh
```ruby
Caco::Ssh::AuthorizedKeysAdd.(
  user: "fernandes",
  key: "ssh-rsa AAAA...",
  identifier: "fernandes@laptop"
)
```

### Caco::Postgres
```ruby
Caco::Postgres::Install.()
Caco::Postgres::UserCreate.(username: "app", password: "secret")
Caco::Postgres::DatabaseCreate.(name: "myapp_production", owner: "app")
Caco::Postgres::ConfSet.(key: "max_connections", value: "200")
Caco::Postgres::HbaSet.(type: "host", database: "all", user: "all", address: "0.0.0.0/0", method: "md5")
```

### Caco::Nginx
```ruby
Caco::Nginx::Vhost.(
  server_name: "example.com",
  root: "/var/www/example"
)
```

### Caco::Docker
```ruby
Caco::Docker # (módulo disponível mas implementação específica)
```

### Caco::Rbenv / Caco::Nodenv
Instalação e configuração de version managers para Ruby/Node.

### Caco::Prometheus
```ruby
Caco::Prometheus::Install.()
Caco::Prometheus::ExporterInstall.(exporter: "node_exporter")
```

### Caco::Grafana
```ruby
Caco::Grafana::Install.()
```

### Caco::Timescale
```ruby
Caco::Timescale::Install.()
```

### Caco::Haproxy
```ruby
Caco::Haproxy::Install.()
Caco::Haproxy::ConfSet.(...)
```

### Caco::Repmgr
Para replicação PostgreSQL.

## Templates com Cells

Para gerar conteúdo dinâmico, use Trailblazer::Cell:

```ruby
# nodes/caco/mymodule.rb
module Caco
  module MyModule
    module Cell
      class Config < Trailblazer::Cell
        self.view_paths = [File.expand_path('../', __dir__)]

        def home
          Settings.home
        end
      end
    end

    def self.install
      content = Cell::Config.call.to_s
      Caco.file "/etc/myapp/config", content: content
    end
  end
end

# nodes/caco/mymodule/view/config.erb
# Config gerado por Caco
home_dir = <%= home %>
```

### Renderizando templates específicos

```ruby
# Usando render para escolher template
content = Cell::Config.call.render(:another_template).to_s

# Passando model para o cell
content = Cell::Config.call(some_data).to_s
```

## Estrutura de um Node File

```ruby
# nodes/carbon.lab.rb
# frozen_string_literal: true
# typed: strict

extend T::Sig

# Helper local (opcional)
sig { params(package: String).returns(T::Boolean) }
def install_package(package)
  check = Caco.execute("dpkg -s #{package} >&- 2>&-")
  if check.exit_code != 0
    install = Caco.execute("apt-get install -y #{package}")
    return install.exit_code.try(:zero?)
  end
  true
end

# Incluir módulos compartilhados
require_relative "caco/fernandes"

# Configurações específicas desta máquina
Caco::Fernandes.install

# Configurações adicionais
Caco.file "/etc/motd",
  content: "Welcome to Carbon!\n"

Caco.package "htop"
Caco.package "tmux"
```

## Configuração do Caco

Variáveis de ambiente:

- `CACO_LOG_FILE`: Caminho do arquivo de log (padrão: `/var/log/caco.log`)
- `CACO_INTERACTIVE_WRITES`: Se `true`, pergunta antes de sobrescrever arquivos
- `CACO_WRITE_FILES`: Se `false`, não escreve arquivos (dry-run)
- `CACO_WRITE_FILES_ROOT`: Prefixo para todos os caminhos de arquivo (útil para testes)

## Executando

```bash
# Na máquina remota, dentro do control-repo:
./bin/caco

# Com interactive writes (mostra diff antes de sobrescrever):
CACO_INTERACTIVE_WRITES=true ./bin/caco

# Dry-run (não escreve arquivos):
CACO_WRITE_FILES=false ./bin/caco
```

## Criando um Novo Node

1. Criar arquivo `nodes/<hostname>.rb`
2. Incluir módulos necessários com `require_relative`
3. Adicionar configurações específicas
4. (Opcional) Criar `data/nodes/<hostname>.yaml` para dados específicos

## Dicas

- Use `Settings` para acessar dados do YAML
- Use `Caco::Facter.()` para dados do sistema (OS, hostname, etc.)
- Organize código reutilizável em módulos dentro de `nodes/caco/`
- Use Cells para templates complexos
- Mantenha as chaves eyaml fora do git (`keys/` no .gitignore)
- Sincronize o control-repo E as keys para a máquina remota
