# Changelog

## [3.2.0] - 2025-05-16
### Removido
- Funcionalidade Arch Prune removida do projeto

## [3.1.0] - 2025-05-16
### Adicionado
- Sistema de perfil AWS ativo persistente
- Menu para troca rápida de perfil AWS
- Opção de linha de comando `--profile` para gerenciar perfil ativo
- Exibição do perfil ativo no menu principal
- Opção para definir perfil ativo ao criar um novo perfil

### Modificado
- Funções de utilidade para usar o perfil ativo por padrão
- Interface de usuário para mostrar o perfil ativo atual

## [3.0.0] - 2025-05-07
### Adicionado
- Implementação Python completa com CLI usando Click
- Integração com AWS FinOps Dashboard
- Módulos para monitoramento e observabilidade
- Módulos para otimização de custos
- Módulos para segurança e compliance
- Módulos para automação de rotinas
- Módulos para gerenciamento de containers
- Módulos para gerenciamento de banco de dados

### Modificado
- Estrutura do projeto reorganizada
- Melhorias na interface de usuário
- Suporte para múltiplos sistemas operacionais

## [2.0.0] - 2025-04-15
### Adicionado
- Suporte para AWS SSO
- Execução do Prowler para auditoria de segurança
- Listagem de recursos AWS (EC2, S3, RDS, Lambda, IAM)
- Criação de usuário de suporte

### Modificado
- Verificação de dependências melhorada
- Interface de usuário aprimorada

## [1.0.0] - 2025-03-01
### Adicionado
- Versão inicial do Arch CLI
- Verificação de dependências básicas
- Configuração de perfil AWS CLI
- Execução do Arch Prune
