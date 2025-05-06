#!/bin/bash
# arch_prune.sh - Módulo para execução do Arch Prune
# Parte do Arch CLI

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
    
    # Perguntar qual perfil AWS usar
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    # Exportar a variável de ambiente para o arch-prune usar
    export AWS_PROFILE="$profile_name"
    
    # Executar o arch-prune
    cd ../arch-prune/ && ./arch-prune.sh "$status"
    arch_prune_exit_code=$?
    
    if [ $arch_prune_exit_code -eq 0 ]; then
        log "SUCCESS" "Arch Prune executado com sucesso."
        echo "Arch Prune executado com sucesso."
    else
        log "ERROR" "Erro ao executar o Arch Prune (código de saída: $arch_prune_exit_code)."
        echo "Erro ao executar o Arch Prune. Verifique o arquivo de log para mais detalhes."
    fi
    
    # Voltar ao diretório original
    cd - > /dev/null
    
    # Limpar a variável de ambiente
    unset AWS_PROFILE
}
