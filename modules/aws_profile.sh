#!/bin/bash
# aws_profile.sh - Módulo para gerenciamento de perfis AWS
# Parte do Arch CLI

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
    
    # Perguntar se deseja definir como perfil ativo
    echo "Deseja definir este perfil como ativo? [s/n]"
    read -r set_active
    
    if [[ "$set_active" =~ ^[Ss]$ ]]; then
        set_active_profile "$profile_name"
    fi
}
