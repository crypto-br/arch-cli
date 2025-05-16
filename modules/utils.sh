#!/bin/bash
# utils.sh - Funções utilitárias para o arch-cli
# Versão 3.2.0

# Configurações
CONFIG_DIR="$HOME/.arch-cli"
CONFIG_FILE="$CONFIG_DIR/config.json"
ACTIVE_PROFILE_FILE="$CONFIG_DIR/active_profile"
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
    
    # Inicializar o arquivo de perfil ativo se não existir
    if [ ! -f "$ACTIVE_PROFILE_FILE" ]; then
        echo "default" > "$ACTIVE_PROFILE_FILE"
        log "INFO" "Arquivo de perfil ativo criado: $ACTIVE_PROFILE_FILE"
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
 \__,_|_|  \___|_| |_|      \___|_|_| v3.2${NC}
" 
    echo "Created by: Luiz Machado (@cryptobr)"
    echo "######################################################################"
    echo ""
}

# Função para exibir ajuda
show_help() {
    echo "
Utilização: sh arch-cli.sh [opção] [parâmetros]

Opções disponíveis:
    --deps, -deps           Verifica dependências necessárias (AWS-CLI, Python3, Prowler)
    --prowler, -prowler     Inicia o Prowler para auditoria de segurança
    --np, -np               Configura um novo perfil no AWS CLI
    --lsu, -lsu --acc <ID>  Cria um usuário administrativo de suporte na conta AWS
    --list, -list           Lista recursos AWS (EC2, S3, RDS, Lambda, IAM, CloudFormation)
    --monitor, -monitor     Acessa o menu de monitoramento e observabilidade
    --cost, -cost           Acessa o menu de otimização de custos
    --security, -security   Acessa o menu de segurança e compliance
    --automation, -automation Acessa o menu de automação de rotinas
    --containers, -containers Acessa o menu de gerenciamento de containers
    --database, -database   Acessa o menu de gerenciamento de banco de dados
    --finops, -finops       Acessa o menu do AWS FinOps Dashboard
    --profile, -profile [nome] Define ou gerencia o perfil AWS ativo
    --help, -help           Mostra esta mensagem de ajuda
"
}

# Função para verificar se o AWS CLI está configurado
check_aws_cli_configured() {
    local profile=$1
    
    if [ -z "$profile" ]; then
        profile=$(get_active_profile)
    fi
    
    if ! aws configure list --profile "$profile" &> /dev/null; then
        log "ERROR" "Perfil AWS CLI '$profile' não está configurado."
        echo "Perfil AWS CLI '$profile' não está configurado."
        echo "Use './arch-cli.sh --np' para configurar um novo perfil."
        return 1
    fi
    
    return 0
}

# Função para obter o perfil AWS ativo
get_active_profile() {
    if [ -f "$ACTIVE_PROFILE_FILE" ]; then
        cat "$ACTIVE_PROFILE_FILE"
    else
        echo "default"
    fi
}

# Função para definir o perfil AWS ativo
set_active_profile() {
    local profile=$1
    echo "$profile" > "$ACTIVE_PROFILE_FILE"
    log "INFO" "Perfil ativo definido para: $profile"
    show_success "Perfil ativo definido para: $profile"
}

# Função para listar e selecionar um perfil AWS
select_aws_profile() {
    local profiles=$(aws configure list-profiles)
    
    if [ -z "$profiles" ]; then
        log "ERROR" "Nenhum perfil AWS CLI encontrado."
        echo "Nenhum perfil AWS CLI encontrado."
        echo "Use './arch-cli.sh --np' para configurar um novo perfil."
        return 1
    fi
    
    local active_profile=$(get_active_profile)
    echo "Perfil ativo atual: $active_profile"
    echo
    echo "Perfis disponíveis:"
    local i=1
    local profile_array=()
    
    while read -r profile; do
        if [ "$profile" = "$active_profile" ]; then
            echo "[$i] $profile (ATIVO)"
        else
            echo "[$i] $profile"
        fi
        profile_array+=("$profile")
        ((i++))
    done <<< "$profiles"
    
    echo "Selecione um perfil (1-$((i-1))):"
    read -r selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $((i-1)) ]; then
        log "ERROR" "Seleção inválida: $selection"
        echo "Seleção inválida."
        return 1
    fi
    
    local selected_profile=${profile_array[$((selection-1))]}
    set_active_profile "$selected_profile"
    echo "$selected_profile"
    return 0
}

# Função para criar diretório de exportação
create_export_dir() {
    local dir_name=$1
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local export_dir="./${dir_name}_${timestamp}"
    
    mkdir -p "$export_dir"
    echo "$export_dir"
}

# Função para exibir barra de progresso
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r[%${completed}s%${remaining}s] %d%%" "$(printf '%0.s#' $(seq 1 $completed))" "$(printf '%0.s-' $(seq 1 $remaining))" "$percentage"
}

# Função para validar entrada numérica
validate_number() {
    local input=$1
    local min=$2
    local max=$3
    
    if ! [[ "$input" =~ ^[0-9]+$ ]] || [ "$input" -lt "$min" ] || [ "$input" -gt "$max" ]; then
        return 1
    fi
    
    return 0
}

# Função para confirmar ação
confirm_action() {
    local message=$1
    
    echo "$message [s/n]"
    read -r response
    
    if [[ "$response" =~ ^[Ss]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Função para exibir mensagem de sucesso
show_success() {
    local message=$1
    echo -e "${GREEN}✓ $message${NC}"
}

# Função para exibir mensagem de erro
show_error() {
    local message=$1
    echo -e "${RED}✗ $message${NC}"
}

# Função para exibir mensagem de aviso
show_warning() {
    local message=$1
    echo -e "${YELLOW}⚠ $message${NC}"
}

# Função para exibir mensagem de informação
show_info() {
    local message=$1
    echo -e "${BLUE}ℹ $message${NC}"
}
# Função para exibir o menu de troca de perfil
switch_profile_menu() {
    clear
    show_header
    
    echo "Menu de Troca de Perfil AWS:"
    echo "1. Selecionar perfil existente"
    echo "2. Configurar novo perfil"
    echo "3. Mostrar perfil ativo"
    echo "0. Voltar ao menu principal"
    
    echo -n "Escolha uma opção: "
    read -r option
    
    case $option in
        1)
            select_aws_profile
            ;;
        2)
            configure_profile
            ;;
        3)
            local active_profile=$(get_active_profile)
            echo -e "${BLUE}Perfil AWS ativo:${NC} $active_profile"
            ;;
        0)
            return
            ;;
        *)
            echo "Opção inválida."
            ;;
    esac
}
