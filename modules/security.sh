#!/bin/bash
# security.sh - Módulo para segurança e compliance
# Parte do Arch CLI

# Função para analisar políticas IAM
analyze_iam_policies() {
    log "INFO" "Iniciando análise de políticas IAM"
    echo "Analisando políticas IAM..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha o tipo de análise:"
    echo "[1] Usuários com acesso de administrador"
    echo "[2] Políticas com permissões amplas"
    echo "[3] Credenciais não utilizadas"
    echo "[4] Usuários sem MFA"
    echo "[5] Access Analyzer"
    read -r analysis_type
    
    case $analysis_type in
        1)
            echo "Identificando usuários com acesso de administrador..."
            
            # Listar todos os usuários
            users=$(aws iam list-users --profile "$profile_name" --query 'Users[*].UserName' --output text)
            
            echo "Usuários com acesso de administrador:"
            echo "--------------------------------"
            
            for user in $users; do
                # Verificar políticas anexadas diretamente
                admin_policies=$(aws iam list-attached-user-policies --profile "$profile_name" --user-name "$user" --query "AttachedPolicies[?PolicyName=='AdministratorAccess'].PolicyName" --output text)
                
                # Verificar políticas de grupo
                groups=$(aws iam list-groups-for-user --profile "$profile_name" --user-name "$user" --query 'Groups[*].GroupName' --output text)
                
                for group in $groups; do
                    group_admin_policies=$(aws iam list-attached-group-policies --profile "$profile_name" --group-name "$group" --query "AttachedPolicies[?PolicyName=='AdministratorAccess'].PolicyName" --output text)
                    if [ -n "$group_admin_policies" ]; then
                        admin_policies="$admin_policies $group_admin_policies (via grupo $group)"
                    fi
                done
                
                if [ -n "$admin_policies" ]; then
                    echo "- $user: $admin_policies"
                fi
            done
            ;;
        2)
            echo "Identificando políticas com permissões amplas..."
            
            # Listar políticas gerenciadas pelo cliente
            policies=$(aws iam list-policies --profile "$profile_name" --scope Local --query 'Policies[*].[PolicyName,Arn]' --output text)
            
            echo "Políticas com permissões amplas:"
            echo "--------------------------------"
            
            while read -r policy_name policy_arn; do
                # Obter a versão padrão da política
                policy_version=$(aws iam get-policy --profile "$profile_name" --policy-arn "$policy_arn" --query 'Policy.DefaultVersionId' --output text)
                
                # Obter o documento da política
                policy_document=$(aws iam get-policy-version --profile "$profile_name" --policy-arn "$policy_arn" --version-id "$policy_version" --query 'PolicyVersion.Document' --output json)
                
                # Verificar se a política tem permissões amplas
                if echo "$policy_document" | grep -q '"Effect": "Allow".*"Action": "\*"'; then
                    echo "- $policy_name: Contém permissões de wildcard (*)"
                    echo "  ARN: $policy_arn"
                fi
            done <<< "$policies"
            ;;
        3)
            echo "Identificando credenciais não utilizadas..."
            
            # Listar todos os usuários
            users=$(aws iam list-users --profile "$profile_name" --query 'Users[*].[UserName,PasswordLastUsed]' --output text)
            
            echo "Credenciais não utilizadas nos últimos 90 dias:"
            echo "----------------------------------------------"
            
            while read -r user last_used; do
                if [ "$last_used" = "None" ]; then
                    echo "- $user: Senha nunca utilizada"
                else
                    # Converter a data para timestamp
                    last_used_ts=$(date -d "$last_used" +%s)
                    now_ts=$(date +%s)
                    days_diff=$(( (now_ts - last_used_ts) / 86400 ))
                    
                    if [ $days_diff -gt 90 ]; then
                        echo "- $user: Senha não utilizada há $days_diff dias (última vez: $last_used)"
                    fi
                fi
                
                # Verificar chaves de acesso
                access_keys=$(aws iam list-access-keys --profile "$profile_name" --user-name "$user" --query 'AccessKeyMetadata[*].[AccessKeyId,Status]' --output text)
                
                while read -r key_id key_status; do
                    if [ -n "$key_id" ]; then
                        # Obter a última data de uso da chave
                        key_last_used=$(aws iam get-access-key-last-used --profile "$profile_name" --access-key-id "$key_id" --query 'AccessKeyLastUsed.LastUsedDate' --output text)
                        
                        if [ "$key_last_used" = "None" ] || [ -z "$key_last_used" ]; then
                            echo "  - Chave de acesso $key_id: Nunca utilizada (Status: $key_status)"
                        else
                            # Converter a data para timestamp
                            key_last_used_ts=$(date -d "$key_last_used" +%s)
                            days_diff=$(( (now_ts - key_last_used_ts) / 86400 ))
                            
                            if [ $days_diff -gt 90 ]; then
                                echo "  - Chave de acesso $key_id: Não utilizada há $days_diff dias (última vez: $key_last_used, Status: $key_status)"
                            fi
                        fi
                    fi
                done <<< "$access_keys"
            done <<< "$users"
            ;;
        4)
            echo "Identificando usuários sem MFA..."
            
            # Listar todos os usuários
            users=$(aws iam list-users --profile "$profile_name" --query 'Users[*].UserName' --output text)
            
            echo "Usuários sem MFA ativado:"
            echo "------------------------"
            
            for user in $users; do
                # Verificar se o usuário tem MFA ativado
                mfa_devices=$(aws iam list-mfa-devices --profile "$profile_name" --user-name "$user" --query 'MFADevices[*]' --output text)
                
                if [ -z "$mfa_devices" ]; then
                    echo "- $user"
                fi
            done
            ;;
        5)
            echo "Executando Access Analyzer..."
            
            # Verificar se o Access Analyzer está ativado
            analyzers=$(aws accessanalyzer list-analyzers --profile "$profile_name" --query 'analyzers[*].[name,status]' --output text)
            
            if [ -z "$analyzers" ]; then
                echo "Access Analyzer não está ativado. Deseja ativá-lo? [1] sim / [2] não"
                read -r activate_analyzer
                
                if [ "$activate_analyzer" -eq 1 ]; then
                    echo "Ativando Access Analyzer..."
                    aws accessanalyzer create-analyzer --profile "$profile_name" --analyzer-name "arch-cli-analyzer" --type ACCOUNT
                    
                    if [ $? -eq 0 ]; then
                        log "SUCCESS" "Access Analyzer ativado com sucesso."
                        echo "Access Analyzer ativado com sucesso."
                    else
                        log "ERROR" "Erro ao ativar Access Analyzer."
                        echo "Erro ao ativar Access Analyzer. Verifique o arquivo de log para mais detalhes."
                        return 1
                    fi
                else
                    echo "Operação cancelada."
                    return 0
                fi
            fi
            
            # Listar descobertas do Access Analyzer
            echo "Listando descobertas do Access Analyzer..."
            aws accessanalyzer list-findings --profile "$profile_name" --query 'findings[*].[id,resourceType,resource,status]' --output table
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Análise de segurança concluída."
}

# Função para verificar conformidade
check_compliance() {
    log "INFO" "Iniciando verificação de conformidade"
    echo "Verificando conformidade..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha o framework de conformidade:"
    echo "[1] CIS AWS Foundations Benchmark"
    echo "[2] PCI DSS"
    echo "[3] HIPAA"
    echo "[4] NIST 800-53"
    echo "[5] AWS Config Rules"
    read -r framework
    
    case $framework in
        1|2|3|4)
            echo "Para verificar conformidade com frameworks como CIS, PCI DSS, HIPAA ou NIST, recomendamos usar o Prowler com flags específicas."
            echo "Deseja executar o Prowler com o framework selecionado? [1] sim / [2] não"
            read -r run_prowler
            
            if [ "$run_prowler" -eq 1 ]; then
                case $framework in
                    1)
                        framework_name="cis"
                        ;;
                    2)
                        framework_name="pci"
                        ;;
                    3)
                        framework_name="hipaa"
                        ;;
                    4)
                        framework_name="nist"
                        ;;
                esac
                
                # Criar diretório para relatórios
                local output_dir="./prowler_reports/$(date +%Y-%m-%d_%H-%M-%S)_$framework_name"
                mkdir -p "$output_dir"
                
                echo "Executando Prowler com o framework $framework_name..."
                echo "Os relatórios serão salvos em: $output_dir"
                
                # Executar Prowler com o framework específico
                ulimit -n 4096 && prowler aws --profile "$profile_name" --compliance "$framework_name" -M csv html -o "$output_dir"
                
                if [ $? -eq 0 ]; then
                    log "SUCCESS" "Verificação de conformidade concluída com sucesso. Relatórios disponíveis em: $output_dir"
                    echo "Verificação de conformidade concluída com sucesso. Relatórios disponíveis em: $output_dir"
                else
                    log "ERROR" "Erro ao executar verificação de conformidade."
                    echo "Erro ao executar verificação de conformidade. Verifique o arquivo de log para mais detalhes."
                fi
            else
                echo "Operação cancelada."
            fi
            ;;
        5)
            echo "Verificando regras do AWS Config..."
            
            # Verificar se o AWS Config está ativado
            config_status=$(aws configservice describe-configuration-recorders --profile "$profile_name" --query 'ConfigurationRecorders[*]' --output text)
            
            if [ -z "$config_status" ]; then
                echo "AWS Config não está ativado. Para verificar conformidade, é necessário ativar o AWS Config."
                return 1
            fi
            
            # Listar regras do AWS Config
            echo "Listando regras do AWS Config..."
            aws configservice describe-config-rules --profile "$profile_name" --query 'ConfigRules[*].[ConfigRuleName,ConfigRuleState]' --output table
            
            # Listar resultados de conformidade
            echo "Listando resultados de conformidade..."
            aws configservice describe-compliance-by-config-rule --profile "$profile_name" --query 'ComplianceByConfigRules[*].[ConfigRuleName,Compliance.ComplianceType]' --output table
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Verificação de conformidade concluída."
}

# Função para gerenciar rotação de credenciais
manage_credential_rotation() {
    log "INFO" "Iniciando gerenciamento de rotação de credenciais"
    echo "Gerenciando rotação de credenciais..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar chaves de acesso antigas"
    echo "[2] Rotacionar chaves de acesso"
    echo "[3] Verificar segredos no Secrets Manager"
    read -r operation
    
    case $operation in
        1)
            echo "Listando chaves de acesso com mais de 90 dias..."
            
            # Listar todos os usuários
            users=$(aws iam list-users --profile "$profile_name" --query 'Users[*].UserName' --output text)
            
            echo "Chaves de acesso antigas:"
            echo "------------------------"
            
            for user in $users; do
                # Listar chaves de acesso
                access_keys=$(aws iam list-access-keys --profile "$profile_name" --user-name "$user" --query 'AccessKeyMetadata[*].[AccessKeyId,CreateDate,Status]' --output text)
                
                while read -r key_id create_date key_status; do
                    if [ -n "$key_id" ]; then
                        # Converter a data para timestamp
                        create_date_ts=$(date -d "$create_date" +%s)
                        now_ts=$(date +%s)
                        days_diff=$(( (now_ts - create_date_ts) / 86400 ))
                        
                        if [ $days_diff -gt 90 ]; then
                            echo "- $user: Chave $key_id criada há $days_diff dias (Status: $key_status)"
                        fi
                    fi
                done <<< "$access_keys"
            done
            ;;
        2)
            echo "Rotacionando chaves de acesso..."
            echo "Informe o nome do usuário:"
            read -r username
            
            # Verificar se o usuário existe
            if ! aws iam get-user --profile "$profile_name" --user-name "$username" &> /dev/null; then
                log "ERROR" "Usuário '$username' não encontrado."
                echo "Usuário '$username' não encontrado."
                return 1
            fi
            
            # Listar chaves de acesso existentes
            access_keys=$(aws iam list-access-keys --profile "$profile_name" --user-name "$username" --query 'AccessKeyMetadata[*].[AccessKeyId,Status]' --output text)
            
            echo "Chaves de acesso existentes para $username:"
            echo "-------------------------------------------"
            
            while read -r key_id key_status; do
                if [ -n "$key_id" ]; then
                    echo "- $key_id (Status: $key_status)"
                fi
            done <<< "$access_keys"
            
            # Verificar se já existem duas chaves
            key_count=$(echo "$access_keys" | wc -l)
            
            if [ "$key_count" -ge 2 ]; then
                echo "O usuário já possui o número máximo de chaves de acesso (2). É necessário excluir uma chave antes de criar uma nova."
                echo "Informe o ID da chave a ser excluída:"
                read -r key_to_delete
                
                # Verificar se a chave existe
                if ! echo "$access_keys" | grep -q "$key_to_delete"; then
                    log "ERROR" "Chave '$key_to_delete' não encontrada."
                    echo "Chave '$key_to_delete' não encontrada."
                    return 1
                fi
                
                # Excluir a chave
                aws iam delete-access-key --profile "$profile_name" --user-name "$username" --access-key-id "$key_to_delete"
                
                if [ $? -ne 0 ]; then
                    log "ERROR" "Erro ao excluir chave de acesso."
                    echo "Erro ao excluir chave de acesso. Verifique o arquivo de log para mais detalhes."
                    return 1
                fi
                
                echo "Chave $key_to_delete excluída com sucesso."
            fi
            
            # Criar nova chave
            echo "Criando nova chave de acesso..."
            new_key=$(aws iam create-access-key --profile "$profile_name" --user-name "$username" --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Nova chave de acesso criada com sucesso."
                echo "Nova chave de acesso criada com sucesso:"
                echo "$new_key"
                
                # Salvar a chave em um arquivo
                echo "Deseja salvar a chave em um arquivo? [1] sim / [2] não"
                read -r save_key
                
                if [ "$save_key" -eq 1 ]; then
                    echo "$new_key" > "$username-new-access-key.txt"
                    echo "Chave salva em $username-new-access-key.txt"
                    echo "IMPORTANTE: Guarde esta chave em um local seguro. Ela não poderá ser recuperada novamente."
                fi
            else
                log "ERROR" "Erro ao criar nova chave de acesso."
                echo "Erro ao criar nova chave de acesso. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        3)
            echo "Verificando segredos no Secrets Manager..."
            
            # Listar segredos
            secrets=$(aws secretsmanager list-secrets --profile "$profile_name" --query 'SecretList[*].[Name,LastRotatedDate,RotationEnabled]' --output text)
            
            echo "Segredos no Secrets Manager:"
            echo "---------------------------"
            
            while read -r secret_name last_rotated rotation_enabled; do
                if [ -n "$secret_name" ]; then
                    echo "- $secret_name"
                    
                    if [ "$rotation_enabled" = "True" ]; then
                        echo "  Rotação automática: Ativada"
                        echo "  Última rotação: $last_rotated"
                    else
                        echo "  Rotação automática: Desativada"
                        
                        # Verificar se o segredo nunca foi rotacionado ou se foi rotacionado há mais de 90 dias
                        if [ -z "$last_rotated" ] || [ "$last_rotated" = "None" ]; then
                            echo "  Alerta: Segredo nunca foi rotacionado"
                        else
                            # Converter a data para timestamp
                            last_rotated_ts=$(date -d "$last_rotated" +%s)
                            now_ts=$(date +%s)
                            days_diff=$(( (now_ts - last_rotated_ts) / 86400 ))
                            
                            if [ $days_diff -gt 90 ]; then
                                echo "  Alerta: Segredo não rotacionado há $days_diff dias"
                            fi
                        fi
                    fi
                fi
            done <<< "$secrets"
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Operação concluída com sucesso."
}

# Função principal do módulo de segurança
security_menu() {
    log "INFO" "Iniciando menu de segurança"
    echo "Menu de Segurança e Compliance"
    
    echo "Escolha a operação:"
    echo "[1] Analisar políticas IAM"
    echo "[2] Verificar conformidade"
    echo "[3] Gerenciar rotação de credenciais"
    echo "[4] Voltar"
    read -r option
    
    case $option in
        1)
            analyze_iam_policies
            ;;
        2)
            check_compliance
            ;;
        3)
            manage_credential_rotation
            ;;
        4)
            return 0
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
}
