#!/bin/bash
# support_user.sh - Módulo para criação de usuário de suporte
# Parte do Arch CLI

# Função para criar usuário de suporte
create_support_user() {
    local account_id=$1
    log "INFO" "Criando usuário de suporte para a conta: $account_id"
    
    if [ -z "$account_id" ]; then
        log "ERROR" "Account ID não informado."
        echo "Account ID não informado."
        return 1
    fi
    
    # Validar formato do Account ID
    if ! [[ "$account_id" =~ ^[0-9]{12}$ ]]; then
        log "ERROR" "Formato de Account ID inválido: $account_id"
        echo "Formato de Account ID inválido. Deve conter exatamente 12 dígitos numéricos."
        return 1
    fi
    
    # Verificar se o script Python existe
    local script_path="../arch-prune/create_suporte_user_cf.py"
    if [ ! -f "$script_path" ]; then
        log "ERROR" "Script create_suporte_user_cf.py não encontrado."
        echo "Script create_suporte_user_cf.py não encontrado em $script_path"
        return 1
    fi
    
    # Perguntar qual perfil AWS usar
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Criando usuário de suporte para a conta: $account_id usando o perfil: $profile_name"
    
    # Exportar a variável de ambiente para o script Python usar
    export AWS_PROFILE="$profile_name"
    
    # Executar o script Python
    python3 "$script_path" "$account_id"
    script_exit_code=$?
    
    if [ $script_exit_code -eq 0 ]; then
        log "SUCCESS" "Usuário de suporte criado com sucesso."
        echo "Usuário de suporte criado com sucesso."
        
        # Mostrar informações do usuário criado
        echo "Detalhes do usuário de suporte:"
        aws iam get-user --user-name "SupportUser-$account_id" --profile "$profile_name" --query 'User.[UserName,Arn,CreateDate]' --output table
    else
        log "ERROR" "Erro ao criar usuário de suporte (código de saída: $script_exit_code)."
        echo "Erro ao criar usuário de suporte. Verifique o arquivo de log para mais detalhes."
    fi
    
    # Limpar a variável de ambiente
    unset AWS_PROFILE
}
