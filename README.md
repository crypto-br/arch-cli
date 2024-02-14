# Faster CLI

## Visão Geral
Este script foi projetado para facilitar o gerenciamento do time de Infra da CloudFaster & CloudFaster Academy

## Versão
- 1.0.0

## Funcionalidades
- **Verificação de Dependências (`--deps`)**: Verifica e instala dependências necessárias como AWS CLI, Python3 e Prowler.
- **Arch Prune (`--ap`)**: Inicia o Nuke Faster para limpeza de recursos AWS com base em status específicos.
- **Prowler (`--prowler`)**: Executa o Prowler para auditoria de segurança da conta AWS, gerando relatórios em formatos CSV e HTML.
- **Configuração de Perfil AWS CLI (`--np`)**: Auxilia na configuração de novos perfis no AWS CLI.
- **Criação de Usuário de Suporte (`--lsu`)**: Cria um usuário administrativo de suporte na conta AWS.

## Pré-requisitos
- AWS CLI
- Python 3
- Prowler

## Utilização com o Arch Prune
- É necessário ter baixado o arch-prune, utilização sugerida de diretório:
```bash
arch-cli/
          |_core/arch-cli.sh
          |_arch-prune/arch-prune.sh
```

## Instalação e Uso
Clone o repositório e torne o script executável:
```bash
git clone <repositorio>
chmod +x arch-cli.sh
```

Execute o script com a opção desejada:
```bash
./arch-cli.sh --option
```

## Opções
- `--deps`, `-deps`: Verifica e instala as dependências necessárias.
- `--nf`, `-nf`: Inicia o Arch Prune. Requer status adicional (`forCleanUp`, `avaliable`, `maintenance`, `underAnalysis`).
- `--prowler`, `-prowler`: Executa o Prowler com um perfil AWS CLI especificado.
- `--np`, `-np`: Configura um novo perfil no AWS CLI.
- `--lsu`, `-lsu --acc <Account ID>`: Cria um usuário administrativo de suporte na conta AWS.
- `--help`, `-help`: Mostra as opções disponíveis.

## Aviso - Atenção
Este script pode realizar alterações significativas nas configurações e recursos da sua conta AWS. Use com cautela e sempre verifique os comandos antes de executá-los em ambientes de produção.
