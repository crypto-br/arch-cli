# Arch CLI

## Visão Geral
Este script foi projetado para facilitar o gerenciamento do time de Arquitetura, SRE e DevOps, oferecendo ferramentas para administração de contas AWS.

## Versão
- 3.0.0

## Funcionalidades
- **Verificação de Dependências (`--deps`)**: Verifica e instala dependências necessárias como AWS CLI, Python3 e Prowler, com suporte a múltiplos sistemas operacionais.
- **Arch Prune (`--ap`)**: Inicia o Arch Prune para limpeza de recursos AWS com base em status específicos.
- **Prowler (`--prowler`)**: Executa o Prowler para auditoria de segurança da conta AWS, gerando relatórios em formatos CSV e HTML com barra de progresso.
- **Configuração de Perfil AWS CLI (`--np`)**: Auxilia na configuração de novos perfis no AWS CLI, incluindo suporte para AWS SSO.
- **Criação de Usuário de Suporte (`--lsu`)**: Cria um usuário administrativo de suporte na conta AWS.
- **Listagem de Recursos AWS (`--list`)**: Lista recursos AWS como EC2, S3, RDS, Lambda, IAM e CloudFormation.
- **Monitoramento e Observabilidade (`--monitor`)**: Gerencia alarmes CloudWatch, visualiza logs e verifica saúde de serviços.
- **Otimização de Custos (`--cost`)**: Analisa custos, identifica recursos subutilizados e gerencia orçamentos.
- **Segurança e Compliance (`--security`)**: Analisa políticas IAM, verifica conformidade e gerencia rotação de credenciais.
- **Automação de Rotinas (`--automation`)**: Gerencia backups e agenda tarefas recorrentes.
- **Gerenciamento de Containers (`--containers`)**: Gerencia clusters EKS, serviços ECS e imagens ECR.
- **Gerenciamento de Banco de Dados (`--database`)**: Gerencia instâncias RDS e tabelas DynamoDB.

## Pré-requisitos
- AWS CLI
- Python 3
- Prowler

## Estrutura do Projeto
```
arch-cli/
├── arch-cli.sh              # Script principal
├── modules/                 # Módulos separados por funcionalidade
│   ├── utils.sh             # Funções utilitárias
│   ├── dependencies.sh      # Verificação de dependências
│   ├── aws_profile.sh       # Configuração de perfis AWS
│   ├── prowler.sh           # Execução do Prowler
│   ├── arch_prune.sh        # Execução do Arch Prune
│   ├── support_user.sh      # Criação de usuário de suporte
│   ├── aws_resources.sh     # Listagem de recursos AWS
│   ├── monitoring.sh        # Monitoramento e observabilidade
│   ├── cost_optimization.sh # Otimização de custos
│   ├── security.sh          # Segurança e compliance
│   ├── automation.sh        # Automação de rotinas
│   ├── containers.sh        # Gerenciamento de containers
│   └── database.sh          # Gerenciamento de banco de dados
└── arch-prune/              # Diretório do Arch Prune (externo)
    └── arch-prune.sh        # Script do Arch Prune
```

## Instalação e Uso
Clone o repositório e torne o script executável:
```bash
git clone <repositorio>
cd arch-cli
chmod +x arch-cli.sh
```

Execute o script com a opção desejada:
```bash
./arch-cli.sh --option
```

Ou execute sem argumentos para acessar o menu interativo:
```bash
./arch-cli.sh
```

## Opções
- `--deps`, `-deps`: Verifica e instala as dependências necessárias.
- `--ap`, `-ap <status>`: Inicia o Arch Prune com o status especificado.
  - Status válidos: `forCleanUp`, `available`, `maintenance`, `underAnalysis`
- `--prowler`, `-prowler`: Executa o Prowler para auditoria de segurança.
- `--np`, `-np`: Configura um novo perfil no AWS CLI (suporta chaves de acesso e SSO).
- `--lsu`, `-lsu --acc <Account ID>`: Cria um usuário administrativo de suporte na conta AWS.
- `--list`, `-list`: Lista recursos AWS (EC2, S3, RDS, Lambda, IAM, CloudFormation).
- `--monitor`, `-monitor`: Acessa o menu de monitoramento e observabilidade.
- `--cost`, `-cost`: Acessa o menu de otimização de custos.
- `--security`, `-security`: Acessa o menu de segurança e compliance.
- `--automation`, `-automation`: Acessa o menu de automação de rotinas.
- `--containers`, `-containers`: Acessa o menu de gerenciamento de containers.
- `--database`, `-database`: Acessa o menu de gerenciamento de banco de dados.
- `--help`, `-help`: Mostra as opções disponíveis.

## Logs e Configuração
O script mantém logs detalhados em `~/.arch-cli/arch-cli.log` para facilitar a depuração e auditoria.

## Compatibilidade
O script é compatível com:
- Ubuntu/Debian
- Red Hat/CentOS
- macOS

## Melhorias na Versão 3.0
- Adição de funcionalidades para times de SRE, Infra e DevOps
- Menu interativo para facilitar o uso
- Monitoramento e observabilidade com CloudWatch
- Otimização de custos e gerenciamento de orçamentos
- Segurança e compliance com análise de políticas IAM
- Automação de rotinas com backups e agendamento de tarefas
- Gerenciamento de containers (EKS, ECS, ECR)
- Gerenciamento de banco de dados (RDS, DynamoDB)

## Aviso - Atenção
Este script pode realizar alterações significativas nas configurações e recursos da sua conta AWS. Use com cautela e sempre verifique os comandos antes de executá-los em ambientes de produção.
