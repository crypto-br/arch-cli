#!/bin/bash
# dependencies.sh - Módulo para verificação e instalação de dependências
# Parte do Arch CLI

# Função para detectar o sistema operacional
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Verificar Amazon Linux
        if [ -f /etc/system-release ] && grep -q "Amazon Linux" /etc/system-release; then
            echo "amazon-linux"
        # Verificar Debian/Ubuntu
        elif [ -f /etc/debian_version ]; then
            echo "debian"
        # Verificar Red Hat/CentOS
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

# Função para instalar AWS CLI v2
install_aws_cli_v2() {
    local os_type=$1
    
    case $os_type in
        "debian"|"ubuntu")
            log "INFO" "Instalando dependências para AWS CLI v2..."
            sudo apt-get update
            sudo apt-get install -y unzip curl
            
            log "INFO" "Baixando AWS CLI v2..."
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip -q awscliv2.zip
            
            log "INFO" "Instalando AWS CLI v2..."
            sudo ./aws/install
            
            log "INFO" "Limpando arquivos temporários..."
            rm -rf aws awscliv2.zip
            ;;
            
        "redhat"|"amazon-linux")
            log "INFO" "Instalando dependências para AWS CLI v2..."
            sudo yum install -y unzip curl
            
            log "INFO" "Baixando AWS CLI v2..."
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip -q awscliv2.zip
            
            log "INFO" "Instalando AWS CLI v2..."
            sudo ./aws/install
            
            log "INFO" "Limpando arquivos temporários..."
            rm -rf aws awscliv2.zip
            ;;
            
        "macos")
            log "INFO" "Instalando AWS CLI v2 via brew..."
            brew install awscli
            ;;
            
        *)
            log "ERROR" "Sistema operacional não suportado para instalação automática do AWS CLI v2."
            echo "Por favor, instale o AWS CLI v2 manualmente: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
            return 1
            ;;
    esac
    
    return 0
}

# Função para verificar dependências
check_dependencies() {
    local os_type=$(detect_os)
    log "INFO" "Verificando dependências no sistema: $os_type"
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        log "WARNING" "AWS CLI não está instalado."
        echo "AWS CLI não está instalado."
        echo "Deseja instalar AWS CLI v2? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            install_aws_cli_v2 "$os_type"
            if [ $? -eq 0 ]; then
                log "SUCCESS" "AWS CLI v2 instalado com sucesso."
                echo "AWS CLI v2 instalado com sucesso."
            else
                log "ERROR" "Falha ao instalar AWS CLI v2."
                echo "Falha ao instalar AWS CLI v2. Tente instalar manualmente."
                exit 1
            fi
        elif [ "$install_resp" -eq 2 ]; then
            log "ERROR" "AWS CLI é necessário para continuar."
            echo "Saindo do script."
            exit 1
        fi
    else
        # Verificar versão do AWS CLI
        aws_version=$(aws --version 2>&1)
        log "SUCCESS" "AWS CLI já está instalado: $aws_version"
        echo "AWS CLI já está instalado: $aws_version [${GREEN} OK ${NC}]"
    fi
    
    # Verificar Python3
    if ! command -v python3 &> /dev/null; then
        log "WARNING" "Python3 não está instalado."
        echo "Python3 não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            case $os_type in
                "debian"|"ubuntu")
                    log "INFO" "Instalando Python3 via apt..."
                    sudo apt-get update
                    sudo apt-get install -y python3 python3-pip
                    ;;
                "redhat"|"amazon-linux")
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
            echo "Python3 instalado com sucesso."
        elif [ "$install_resp" -eq 2 ]; then
            log "ERROR" "Python3 é necessário para continuar."
            echo "A instalação é necessária..."
            exit 1
        fi
    else
        python_version=$(python3 --version 2>&1)
        log "SUCCESS" "Python3 já está instalado: $python_version"
        echo "Python3 já está instalado: $python_version [${GREEN} OK ${NC}]"
    fi
    
    # Verificar pip3
    if ! command -v pip3 &> /dev/null; then
        log "WARNING" "pip3 não está instalado."
        echo "pip3 não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            case $os_type in
                "debian"|"ubuntu")
                    log "INFO" "Instalando pip3 via apt..."
                    sudo apt-get update
                    sudo apt-get install -y python3-pip
                    ;;
                "redhat"|"amazon-linux")
                    log "INFO" "Instalando pip3 via yum..."
                    sudo yum install -y python3-pip
                    ;;
                "macos")
                    log "INFO" "Instalando pip3 via brew..."
                    brew install python3
                    ;;
                *)
                    log "ERROR" "Sistema operacional não suportado para instalação automática."
                    echo "Por favor, instale o pip3 manualmente."
                    exit 1
                    ;;
            esac
            log "SUCCESS" "pip3 instalado com sucesso."
            echo "pip3 instalado com sucesso."
        elif [ "$install_resp" -eq 2 ]; then
            log "ERROR" "pip3 é necessário para continuar."
            echo "A instalação é necessária..."
            exit 1
        fi
    else
        pip_version=$(pip3 --version 2>&1)
        log "SUCCESS" "pip3 já está instalado: $pip_version"
        echo "pip3 já está instalado: $pip_version [${GREEN} OK ${NC}]"
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
                prowler_version=$(prowler --version 2>&1 || echo "Versão desconhecida")
                log "SUCCESS" "Prowler instalado com sucesso: $prowler_version"
                echo "Prowler instalado com sucesso: $prowler_version"
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
        prowler_version=$(prowler --version 2>&1 || echo "Versão desconhecida")
        log "SUCCESS" "Prowler já está instalado: $prowler_version"
        echo "Prowler já está instalado: $prowler_version [${GREEN} OK ${NC}]"
    fi
    
    # Verificar jq (útil para processamento de JSON)
    if ! command -v jq &> /dev/null; then
        log "WARNING" "jq não está instalado."
        echo "jq não está instalado (útil para processamento de JSON)."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            case $os_type in
                "debian"|"ubuntu")
                    log "INFO" "Instalando jq via apt..."
                    sudo apt-get update
                    sudo apt-get install -y jq
                    ;;
                "redhat"|"amazon-linux")
                    log "INFO" "Instalando jq via yum..."
                    sudo yum install -y jq
                    ;;
                "macos")
                    log "INFO" "Instalando jq via brew..."
                    brew install jq
                    ;;
                *)
                    log "ERROR" "Sistema operacional não suportado para instalação automática."
                    echo "Por favor, instale o jq manualmente."
                    ;;
            esac
            if command -v jq &> /dev/null; then
                jq_version=$(jq --version 2>&1)
                log "SUCCESS" "jq instalado com sucesso: $jq_version"
                echo "jq instalado com sucesso: $jq_version"
            else
                log "WARNING" "Falha ao instalar jq, mas o script pode continuar sem ele."
                echo "Falha ao instalar jq, mas o script pode continuar sem ele."
            fi
        elif [ "$install_resp" -eq 2 ]; then
            log "WARNING" "Continuando sem jq. Algumas funcionalidades podem ser limitadas."
            echo "Continuando sem jq. Algumas funcionalidades podem ser limitadas."
        fi
    else
        jq_version=$(jq --version 2>&1)
        log "SUCCESS" "jq já está instalado: $jq_version"
        echo "jq já está instalado: $jq_version [${GREEN} OK ${NC}]"
    fi
}
