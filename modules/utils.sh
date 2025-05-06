#!/bin/bash
# utils.sh - Módulo com funções utilitárias
# Parte do Arch CLI

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
CONFIG_DIR="$HOME/.arch-cli"
CONFIG_FILE="$CONFIG_DIR/config.json"
LOG_FILE="$CONFIG_DIR/arch-cli.log"

# Função para logging
log() {
    local level=$1
    local message=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] [$level] $message" >> "$LOG_FILE"
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
 \__,_|_|  \___|_| |_|      \___|_|_| v3.0${NC}
" 
    echo "Created by: Luiz Machado (@cryptobr)"
    echo "Improved by: Amazon Q"
    echo "######################################################################"
    echo ""
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
    --monitor, -monitor     Acessa o menu de monitoramento e observabilidade
    --cost, -cost           Acessa o menu de otimização de custos
    --security, -security   Acessa o menu de segurança e compliance
    --automation, -automation Acessa o menu de automação de rotinas
    --containers, -containers Acessa o menu de gerenciamento de containers
    --database, -database   Acessa o menu de gerenciamento de banco de dados
    --help, -help           Mostra esta mensagem de ajuda

Sem argumentos:             Inicia o menu interativo
"
}

# Função para mostrar barra de progresso
show_progress() {
    local pid=$1
    local message=$2
    local i=0
    
    echo -e "$message"
    
    while kill -0 $pid 2>/dev/null; do
        i=$((i+1))
        if [ $i -gt 20 ]; then i=0; fi
        
        # Criar barra de progresso
        bar="["
        for ((j=0; j<i; j++)); do
            bar="${bar}#"
        done
        for ((j=i; j<20; j++)); do
            bar="${bar} "
        done
        bar="${bar}]"
        
        percent=$((i*5))
        echo -ne "${bar} (${percent}%)\r"
        sleep 1
    done
    
    echo -ne '[####################] (100%)\r'
    echo -e "\n"
}
