# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [3.0.0] - 2025-05-07

### Adicionado
- Suporte para múltiplos sistemas operacionais na verificação de dependências
- Menu interativo para facilitar o uso
- Módulos para monitoramento e observabilidade com CloudWatch
- Módulos para otimização de custos e gerenciamento de orçamentos
- Módulos para segurança e compliance com análise de políticas IAM
- Módulos para automação de rotinas com backups e agendamento de tarefas
- Módulos para gerenciamento de containers (EKS, ECS, ECR)
- Módulos para gerenciamento de banco de dados (RDS, DynamoDB)
- Integração com o AWS FinOps Dashboard para visualização e gerenciamento de custos
- Arquivo `.gitignore` para evitar commit de dados sensíveis
- Documentação do processo de desenvolvimento com Amazon Q

### Corrigido
- Erro de sintaxe no script principal
- Problemas de compatibilidade com diferentes sistemas operacionais
- Melhorias na detecção de dependências

### Alterado
- Reorganização dos módulos em diretórios separados
- Melhoria na interface de usuário
- Atualização da documentação

## [2.0.0] - 2024-12-15

### Adicionado
- Suporte para AWS SSO na configuração de perfis
- Execução do Prowler para auditoria de segurança
- Listagem de recursos AWS (EC2, S3, RDS, Lambda, IAM)
- Criação de usuário de suporte

### Alterado
- Melhoria na estrutura do código
- Adição de logging detalhado

## [1.0.0] - 2024-06-01

### Adicionado
- Versão inicial do script
- Verificação de dependências básicas
- Configuração de perfil AWS CLI
- Execução do Arch Prune
