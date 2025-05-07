#!/bin/bash
# arch-cli.sh - Ferramenta para gerenciamento de contas AWS
# Versão 2.0.0
# Autor: Luiz Machado (@cryptobr)

# Configurações
CONFIG_DIR="$HOME/.arch-cli"
CONFIG_FILE="$CONFIG_DIR/config.json"
LOG_FILE="$CONFIG_DIR/arch-cli.log"

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    local level=$1
    local message=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        *) echo -e "$message" ;;
    esac
}

# Função para detectar o sistema operacional
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux-other"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Função para criar diretório de configuração
setup_config_dir() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        log "INFO" "Diretório de configuração criado: $CONFIG_DIR"
    fi
    
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
        log "INFO" "Arquivo de log criado: $LOG_FILE"
    fi
}

# Função para exibir o cabeçalho
show_header() {
    echo -e "
######################################################################
${GREEN}
                _                _ _ 
  __ _ _ __ ___| |__         ___| (_)
 / _\` | '__/ __| '_ \ _____ / __| | |
| (_| | | | (__| | | |_____| (__| | |
 \__,_|_|  \___|_| |_|      \___|_|_| v2.0${NC}
" 
    echo "Created by: Luiz Machado (@cryptobr)"
    echo "######################################################################"
    echo ""
}

# Função para verificar dependências
check_dependencies() {
    local os_type=$(detect_os)
    log "INFO" "Verificando dependências no sistema: $os_type"
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        log "WARNING" "AWS CLI não está instalado."
        echo "AWS CLI não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            case $os_type in
                "debian")
                    log "INFO" "Instalando AWS CLI via apt..."
                    sudo apt-get update
                    sudo apt-get install -y awscli
                    ;;
                "redhat")
                    log "INFO" "Instalando AWS CLI via yum..."
                    sudo yum install -y awscli
                    ;;
                "macos")
                    log "INFO" "Instalando AWS CLI via brew..."
                    brew install awscli
                    ;;
                *)
                    log "ERROR" "Sistema operacional não suportado para instalação automática."
                    echo "Por favor, instale o AWS CLI manualmente: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
                    exit 1
                    ;;
            esac
            log "SUCCESS" "AWS CLI instalado com sucesso."
        elif [ "$install_resp" -eq 2 ]; then
            log "ERROR" "AWS CLI é necessário para continuar."
            echo "Saindo do script."
            exit 1
        fi
    else
        log "SUCCESS" "AWS CLI já está instalado."
        echo "AWS CLI já está instalado. [${GREEN} OK ${NC}]"
    fi
    
    # Verificar Python3
    if ! command -v python3 &> /dev/null; then
        log "WARNING" "Python3 não está instalado."
        echo "Python3 não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            case $os_type in
                "debian")
                    log "INFO" "Instalando Python3 via apt..."
                    sudo apt-get update
                    sudo apt-get install -y python3 python3-pip
                    ;;
                "redhat")
                    log "INFO" "Instalando Python3 via yum..."
                    sudo yum install -y python3 python3-pip
                    ;;
                "macos")
                    log "INFO" "Instalando Python3 via brew..."
                    brew install python3
                    ;;
                *)
                    log "ERROR" "Sistema operacional não suportado para instalação automática."
                    echo "Por favor, instale o Python3 manualmente."
                    exit 1
                    ;;
            esac
            log "SUCCESS" "Python3 instalado com sucesso."
        elif [ "$install_resp" -eq 2 ]; then
            log "ERROR" "Python3 é necessário para continuar."
            echo "A instalação é necessária..."
            exit 1
        fi
    else
        log "SUCCESS" "Python3 já está instalado."
        echo "Python3 já está instalado. [${GREEN} OK ${NC}]"
    fi
    
    # Verificar Prowler
    if ! command -v prowler &> /dev/null; then
        log "WARNING" "Prowler não está instalado."
        echo "Prowler não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            log "INFO" "Instalando Prowler via pip..."
            pip3 install prowler
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Prowler instalado com sucesso."
                echo "Prowler instalado com sucesso."
            else
                log "ERROR" "Falha ao instalar o Prowler."
                echo "Falha ao instalar o Prowler. Tente instalar manualmente: pip3 install prowler"
                exit 1
            fi
        elif [ "$install_resp" -eq 2 ]; then
            log "ERROR" "Prowler é necessário para continuar."
            echo "A instalação é necessária..."
            exit 1
        fi
    else
        log "SUCCESS" "Prowler já está instalado."
        echo "Prowler já está instalado. [${GREEN} OK ${NC}]"
    fi
}

# Função para configurar novo perfil no AWS CLI
configure_profile() {
    log "INFO" "Iniciando configuração de novo perfil AWS CLI"
    echo "Configurando novo perfil no AWS CLI..."
    
    echo "Qual o nome do profile?"
    read -r profile_name
    
    # Opções de autenticação
    echo "Escolha o método de autenticação:"
    echo "[1] Chaves de acesso (Access Key/Secret Key)"
    echo "[2] AWS SSO"
    read -r auth_method
    
    if [ "$auth_method" -eq 1 ]; then
        echo "Informe a Access Key:"
        read -r access_key
        
        echo "Informe a Secret Key:"
        read -rs secret_key
        echo ""
        
        echo "Qual a região padrão?"
        read -r region
        
        echo "Qual o formato de saída padrão? (json, yaml, text, table)"
        read -r output
        
        # Configurar o perfil
        aws configure set aws_access_key_id "$access_key" --profile "$profile_name"
        aws configure set aws_secret_access_key "$secret_key" --profile "$profile_name"
        aws configure set region "$region" --profile "$profile_name"
        aws configure set output "${output:-json}" --profile "$profile_name"
        
        log "SUCCESS" "Perfil '$profile_name' configurado com sucesso."
        echo "Perfil '$profile_name' configurado com sucesso."
    elif [ "$auth_method" -eq 2 ]; then
        echo "Informe o URL de início de sessão do SSO:"
        read -r sso_start_url
        
        echo "Informe a região do SSO:"
        read -r sso_region
        
        echo "Informe o nome da conta SSO:"
        read -r sso_account_name
        
        echo "Informe o nome do perfil SSO:"
        read -r sso_role_name
        
        echo "Qual a região padrão para o AWS CLI?"
        read -r region
        
        # Configurar o perfil SSO
        aws configure set sso_start_url "$sso_start_url" --profile "$profile_name"
        aws configure set sso_region "$sso_region" --profile "$profile_name"
        aws configure set sso_account_name "$sso_account_name" --profile "$profile_name"
        aws configure set sso_role_name "$sso_role_name" --profile "$profile_name"
        aws configure set region "$region" --profile "$profile_name"
        aws configure set output "json" --profile "$profile_name"
        
        # Iniciar login SSO
        echo "Iniciando login SSO..."
        aws sso login --profile "$profile_name"
        
        log "SUCCESS" "Perfil SSO '$profile_name' configurado com sucesso."
        echo "Perfil SSO '$profile_name' configurado com sucesso."
    else
        log "ERROR" "Opção inválida."
        echo "Opção inválida. Saindo..."
        exit 1
    fi
}

# Função para executar o Prowler
run_prowler() {
    log "INFO" "Iniciando execução do Prowler"
    echo "Iniciando o ${GREEN}Prowler${NC}..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_for_prowler
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_for_prowler" &> /dev/null; then
        log "ERROR" "Perfil '$profile_for_prowler' não encontrado."
        echo "Perfil '$profile_for_prowler' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    # Criar diretório para relatórios
    local output_dir="./prowler_reports/$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p "$output_dir"
    
    echo "Executando Prowler com o perfil '$profile_for_prowler'..."
    echo "Os relatórios serão salvos em: $output_dir"
    
    # Aumentar limite de arquivos abertos e executar o Prowler
    log "INFO" "Executando: prowler aws --profile $profile_for_prowler -M csv html -o $output_dir"
    ulimit -n 4096 && prowler aws --profile "$profile_for_prowler" -M csv html -o "$output_dir"
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Prowler executado com sucesso. Relatórios disponíveis em: $output_dir"
        echo "Prowler executado com sucesso. Relatórios disponíveis em: $output_dir"
    else
        log "ERROR" "Erro ao executar o Prowler."
        echo "Erro ao executar o Prowler. Verifique o arquivo de log para mais detalhes."
    fi
}

# Função para executar o Arch Prune
run_arch_prune() {
    local status=$1
    log "INFO" "Iniciando Arch Prune com status: $status"
    
    # Verificar se o diretório arch-prune existe
    if [ ! -d "../arch-prune" ]; then
        log "ERROR" "Diretório arch-prune não encontrado."
        echo "Diretório arch-prune não encontrado. Verifique se o repositório está estruturado corretamente."
        echo "Estrutura esperada:"
        echo "arch-cli/"
        echo "└── arch-prune/"
        echo "    └── arch-prune.sh"
        return 1
    fi
    
    # Verificar se o script arch-prune.sh existe
    if [ ! -f "../arch-prune/arch-prune.sh" ]; then
        log "ERROR" "Script arch-prune.sh não encontrado."
        echo "Script arch-prune.sh não encontrado em ../arch-prune/"
        return 1
    fi
    
    echo "Iniciando o ${GREEN}Arch Prune${NC} com status: $status..."
    cd ../arch-prune/ && ./arch-prune.sh "$status"
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Arch Prune executado com sucesso."
    else
        log "ERROR" "Erro ao executar o Arch Prune."
        echo "Erro ao executar o Arch Prune. Verifique o arquivo de log para mais detalhes."
    fi
    
    cd - > /dev/null
}

# Função para criar usuário de suporte
create_support_user() {
    local account_id=$1
    log "INFO" "Criando usuário de suporte para a conta: $account_id"
    
    if [ -z "$account_id" ]; then
        log "ERROR" "Account ID não informado."
        echo "Account ID não informado."
        return 1
    fi
    
    # Verificar se o script Python existe
    if [ ! -f "../arch-prune/create_suporte_user_cf.py" ]; then
        log "ERROR" "Script create_suporte_user_cf.py não encontrado."
        echo "Script create_suporte_user_cf.py não encontrado em ../arch-prune/"
        return 1
    fi
    
    echo "Criando usuário de suporte para a conta: $account_id"
    python3 ../arch-prune/create_suporte_user_cf.py "$account_id"
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Usuário de suporte criado com sucesso."
        echo "Usuário de suporte criado com sucesso."
    else
        log "ERROR" "Erro ao criar usuário de suporte."
        echo "Erro ao criar usuário de suporte. Verifique o arquivo de log para mais detalhes."
    fi
}

# Função para listar recursos AWS
list_aws_resources() {
    log "INFO" "Listando recursos AWS"
    echo "Listando recursos AWS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha o tipo de recurso para listar:"
    echo "[1] EC2 Instances"
    echo "[2] S3 Buckets"
    echo "[3] RDS Instances"
    echo "[4] Lambda Functions"
    echo "[5] IAM Users"
    echo "[6] Todos os recursos acima"
    read -r resource_type
    
    case $resource_type in
        1)
            echo "Listando instâncias EC2..."
            aws ec2 describe-instances --profile "$profile_name" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table
            ;;
        2)
            echo "Listando buckets S3..."
            aws s3 ls --profile "$profile_name"
            ;;
        3)
            echo "Listando instâncias RDS..."
            aws rds describe-db-instances --profile "$profile_name" --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]' --output table
            ;;
        4)
            echo "Listando funções Lambda..."
            aws lambda list-functions --profile "$profile_name" --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table
            ;;
        5)
            echo "Listando usuários IAM..."
            aws iam list-users --profile "$profile_name" --query 'Users[*].[UserName,CreateDate]' --output table
            ;;
        6)
            echo "Listando instâncias EC2..."
            aws ec2 describe-instances --profile "$profile_name" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table
            
            echo "Listando buckets S3..."
            aws s3 ls --profile "$profile_name"
            
            echo "Listando instâncias RDS..."
            aws rds describe-db-instances --profile "$profile_name" --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]' --output table
            
            echo "Listando funções Lambda..."
            aws lambda list-functions --profile "$profile_name" --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table
            
            echo "Listando usuários IAM..."
            aws iam list-users --profile "$profile_name" --query 'Users[*].[UserName,CreateDate]' --output table
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Recursos listados com sucesso."
}

# Função para exibir ajuda
show_help() {
    echo "
Utilização: sh arch-cli.sh [opção] [parâmetros]

Opções disponíveis:
    --deps, -deps           Verifica dependências necessárias (AWS-CLI, Python3, Prowler)
    --ap, -ap <status>      Inicia o Arch Prune com o status especificado
                            Status válidos: forCleanUp, available, maintenance, underAnalysis
    --prowler, -prowler     Inicia o Prowler para auditoria de segurança
    --np, -np               Configura um novo perfil no AWS CLI
    --lsu, -lsu --acc <ID>  Cria um usuário administrativo de suporte na conta AWS
    --list, -list           Lista recursos AWS
    --help, -help           Mostra esta mensagem de ajuda
"
}

# Função principal
main() {
    # Configuração inicial
    setup_config_dir
    show_header
    
    # Processar argumentos
    case "$1" in
        --deps|-deps)
            check_dependencies
            ;;
        --ap|-ap)
            if [ -z "$2" ]; then
                log "ERROR" "Status não informado."
                echo "[ERRO] - Status da conta não informado"
                echo "Informe o tipo de status que deseja executar: forCleanUp, available, maintenance, underAnalysis"
                echo "ex: --ap forCleanUp"
                exit 1
            elif [[ "$2" =~ ^(forCleanUp|available|maintenance|underAnalysis)$ ]]; then
                run_arch_prune "$2"
            else
                log "ERROR" "Status inválido: $2"
                echo "[ERRO] - Status inválido: $2"
                echo "Status válidos: forCleanUp, available, maintenance, underAnalysis"
                exit 1
            fi
            ;;
        --prowler|-prowler)
            run_prowler
            ;;
        --np|-np)
            configure_profile
            ;;
        --lsu|-lsu)
            if [ "$2" = "--acc" ] || [ "$2" = "-acc" ]; then
                if [ -z "$3" ]; then
                    log "ERROR" "Account ID não informado."
                    echo "[ERRO] - Account ID não informado"
                    exit 1
                else
                    create_support_user "$3"
                fi
            else
                log "ERROR" "Parâmetro --acc não informado."
                echo "[ERRO] - Parâmetro --acc não informado"
                echo "Uso correto: --lsu --acc <Account ID>"
                exit 1
            fi
            ;;
        --list|-list)
            list_aws_resources
            ;;
        --help|-help|*)
            show_help
            ;;
    esac
}

# Executar função principal
main "$@"
