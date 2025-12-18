#!/bin/bash
# finops.sh - Módulo para integração com aws-finops-dashboard
# Parte do Arch CLI

# Função para verificar se o git está instalado
check_git() {
    if ! command -v git &> /dev/null; then
        log "WARNING" "Git não está instalado."
        echo "Git não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            local os_type=$(detect_os)
            case $os_type in
                "debian"|"ubuntu")
                    log "INFO" "Instalando Git via apt..."
                    sudo apt-get update
                    sudo apt-get install -y git
                    ;;
                "redhat"|"amazon-linux")
                    log "INFO" "Instalando Git via yum..."
                    sudo yum install -y git
                    ;;
                "macos")
                    log "INFO" "Instalando Git via brew..."
                    brew install git
                    ;;
                *)
                    log "ERROR" "Sistema operacional não suportado para instalação automática."
                    echo "Por favor, instale o Git manualmente."
                    return 1
                    ;;
            esac
            log "SUCCESS" "Git instalado com sucesso."
        else
            log "ERROR" "Git é necessário para continuar."
            echo "Git é necessário para continuar."
            return 1
        fi
    fi
    return 0
}

# Função para verificar se o Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        log "WARNING" "Docker não está instalado."
        echo "Docker não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            local os_type=$(detect_os)
            case $os_type in
                "debian"|"ubuntu")
                    log "INFO" "Instalando Docker via apt..."
                    sudo apt-get update
                    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                    sudo apt-get update
                    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                    sudo usermod -aG docker $USER
                    ;;
                "redhat"|"amazon-linux")
                    log "INFO" "Instalando Docker via yum..."
                    sudo yum install -y yum-utils
                    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                    sudo yum install -y docker-ce docker-ce-cli containerd.io
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    sudo usermod -aG docker $USER
                    ;;
                "macos")
                    log "INFO" "Para macOS, por favor instale o Docker Desktop manualmente."
                    echo "Por favor, baixe e instale o Docker Desktop de: https://www.docker.com/products/docker-desktop"
                    return 1
                    ;;
                *)
                    log "ERROR" "Sistema operacional não suportado para instalação automática."
                    echo "Por favor, instale o Docker manualmente."
                    return 1
                    ;;
            esac
            log "SUCCESS" "Docker instalado com sucesso."
            echo "Docker instalado com sucesso. Pode ser necessário reiniciar o terminal ou o sistema."
        else
            log "ERROR" "Docker é necessário para continuar."
            echo "Docker é necessário para continuar."
            return 1
        fi
    fi
    return 0
}

# Função para verificar se o Docker Compose está instalado
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        log "WARNING" "Docker Compose não está instalado."
        echo "Docker Compose não está instalado."
        echo "Deseja instalar? [1] sim / [2] não"
        read -r install_resp
        
        if [ "$install_resp" -eq 1 ]; then
            local os_type=$(detect_os)
            case $os_type in
                "debian"|"ubuntu"|"redhat"|"amazon-linux")
                    log "INFO" "Instalando Docker Compose..."
                    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                    sudo chmod +x /usr/local/bin/docker-compose
                    ;;
                "macos")
                    log "INFO" "Para macOS, o Docker Compose já vem com o Docker Desktop."
                    echo "Se você instalou o Docker Desktop, o Docker Compose já deve estar disponível."
                    ;;
                *)
                    log "ERROR" "Sistema operacional não suportado para instalação automática."
                    echo "Por favor, instale o Docker Compose manualmente."
                    return 1
                    ;;
            esac
            log "SUCCESS" "Docker Compose instalado com sucesso."
        else
            log "ERROR" "Docker Compose é necessário para continuar."
            echo "Docker Compose é necessário para continuar."
            return 1
        fi
    fi
    return 0
}

# Função para clonar o repositório aws-finops-dashboard
clone_finops_repo() {
    local repo_dir="$HOME/.arch-cli/aws-finops-dashboard"
    
    if [ -d "$repo_dir" ]; then
        log "INFO" "Repositório aws-finops-dashboard já existe. Atualizando..."
        cd "$repo_dir"
        git pull
        cd - > /dev/null
    else
        log "INFO" "Clonando repositório aws-finops-dashboard..."
        mkdir -p "$HOME/.arch-cli"
        git clone https://github.com/ravikiranvm/aws-finops-dashboard.git "$repo_dir"
    fi
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Repositório aws-finops-dashboard clonado/atualizado com sucesso."
        return 0
    else
        log "ERROR" "Falha ao clonar/atualizar o repositório aws-finops-dashboard."
        return 1
    fi
}

# Função para configurar o aws-finops-dashboard
configure_finops_dashboard() {
    local repo_dir="$HOME/.arch-cli/aws-finops-dashboard"
    
    echo "Configurando o AWS FinOps Dashboard..."
    
    # Verificar se o perfil AWS está configurado
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    # Configurar variáveis de ambiente
    cd "$repo_dir"
    
    # Verificar se o arquivo .env existe
    if [ ! -f ".env" ]; then
        log "INFO" "Criando arquivo .env..."
        cp .env.example .env
    fi
    
    # Editar o arquivo .env
    echo "Configurando variáveis de ambiente..."
    echo "Informe a região AWS (ex: us-east-1):"
    read -r aws_region
    
    # Atualizar o arquivo .env
    sed -i "s/AWS_PROFILE=.*/AWS_PROFILE=$profile_name/" .env
    sed -i "s/AWS_REGION=.*/AWS_REGION=$aws_region/" .env
    
    log "SUCCESS" "Configuração do AWS FinOps Dashboard concluída."
    cd - > /dev/null
    return 0
}

# Função para iniciar o aws-finops-dashboard
start_finops_dashboard() {
    local repo_dir="$HOME/.arch-cli/aws-finops-dashboard"
    
    if [ ! -d "$repo_dir" ]; then
        log "ERROR" "Repositório aws-finops-dashboard não encontrado."
        echo "Execute a configuração primeiro."
        return 1
    fi
    
    cd "$repo_dir"
    
    echo "Iniciando o AWS FinOps Dashboard..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "AWS FinOps Dashboard iniciado com sucesso."
        echo "AWS FinOps Dashboard está rodando em: http://localhost:3000"
        echo "Usuário padrão: admin"
        echo "Senha padrão: admin"
    else
        log "ERROR" "Falha ao iniciar o AWS FinOps Dashboard."
        echo "Verifique os logs para mais detalhes."
    fi
    
    cd - > /dev/null
}

# Função para parar o aws-finops-dashboard
stop_finops_dashboard() {
    local repo_dir="$HOME/.arch-cli/aws-finops-dashboard"
    
    if [ ! -d "$repo_dir" ]; then
        log "ERROR" "Repositório aws-finops-dashboard não encontrado."
        echo "Execute a configuração primeiro."
        return 1
    fi
    
    cd "$repo_dir"
    
    echo "Parando o AWS FinOps Dashboard..."
    docker-compose down
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "AWS FinOps Dashboard parado com sucesso."
    else
        log "ERROR" "Falha ao parar o AWS FinOps Dashboard."
        echo "Verifique os logs para mais detalhes."
    fi
    
    cd - > /dev/null
}

# Função para exibir o menu do FinOps
finops_menu() {
    while true; do
        clear
        show_header
        
        echo "Menu FinOps Dashboard:"
        echo "1. Verificar dependências (Git, Docker, Docker Compose)"
        echo "2. Configurar AWS FinOps Dashboard"
        echo "3. Iniciar AWS FinOps Dashboard"
        echo "4. Parar AWS FinOps Dashboard"
        echo "0. Voltar ao menu principal"
        
        echo -n "Escolha uma opção: "
        read -r option
        
        case $option in
            1)
                check_git && check_docker && check_docker_compose && clone_finops_repo
                ;;
            2)
                configure_finops_dashboard
                ;;
            3)
                start_finops_dashboard
                ;;
            4)
                stop_finops_dashboard
                ;;
            0)
                return
                ;;
            *)
                echo "Opção inválida."
                ;;
        esac
        
        echo
        echo "Pressione Enter para continuar..."
        read -r
    done
}
