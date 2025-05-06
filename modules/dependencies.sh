#!/bin/bash
# dependencies.sh - Módulo para verificação e instalação de dependências
# Parte do Arch CLI

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
