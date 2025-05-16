#!/bin/bash
# cost_optimization.sh - Módulo para otimização de custos
# Parte do Arch CLI

# Função para analisar custos
analyze_costs() {
    log "INFO" "Iniciando análise de custos"
    echo "Analisando custos AWS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha o tipo de análise:"
    echo "[1] Custos do mês atual"
    echo "[2] Custos por serviço"
    echo "[3] Custos por tag"
    echo "[4] Recursos subutilizados"
    echo "[5] Recomendações de economia"
    read -r analysis_type
    
    case $analysis_type in
        1)
            echo "Obtendo custos do mês atual..."
            
            # Obter o primeiro dia do mês atual
            start_date=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
            # Obter a data atual
            end_date=$(date +%Y-%m-%d)
            
            aws ce get-cost-and-usage \
                --profile "$profile_name" \
                --time-period Start="$start_date",End="$end_date" \
                --granularity MONTHLY \
                --metrics "BlendedCost" "UnblendedCost" "UsageQuantity" \
                --group-by Type=DIMENSION,Key=SERVICE \
                --query 'ResultsByTime[*].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
                --output table
            ;;
        2)
            echo "Obtendo custos por serviço..."
            
            # Obter o primeiro dia do mês atual
            start_date=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
            # Obter a data atual
            end_date=$(date +%Y-%m-%d)
            
            aws ce get-cost-and-usage \
                --profile "$profile_name" \
                --time-period Start="$start_date",End="$end_date" \
                --granularity MONTHLY \
                --metrics "BlendedCost" \
                --group-by Type=DIMENSION,Key=SERVICE \
                --query 'ResultsByTime[*].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
                --output table
            ;;
        3)
            echo "Obtendo custos por tag..."
            echo "Informe a chave da tag (ex: Environment, Project):"
            read -r tag_key
            
            # Obter o primeiro dia do mês atual
            start_date=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
            # Obter a data atual
            end_date=$(date +%Y-%m-%d)
            
            aws ce get-cost-and-usage \
                --profile "$profile_name" \
                --time-period Start="$start_date",End="$end_date" \
                --granularity MONTHLY \
                --metrics "BlendedCost" \
                --group-by Type=TAG,Key="$tag_key" \
                --query 'ResultsByTime[*].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
                --output table
            ;;
        4)
            echo "Identificando recursos subutilizados..."
            
            echo "Verificando instâncias EC2 com baixa utilização de CPU..."
            aws cloudwatch get-metric-statistics \
                --profile "$profile_name" \
                --namespace AWS/EC2 \
                --metric-name CPUUtilization \
                --period 86400 \
                --statistics Average \
                --start-time "$(date -d '7 days ago' '+%Y-%m-%dT%H:%M:%S')" \
                --end-time "$(date '+%Y-%m-%dT%H:%M:%S')" \
                --dimensions Name=InstanceId,Value=$(aws ec2 describe-instances --profile "$profile_name" --query 'Reservations[*].Instances[*].InstanceId' --output text) \
                --query 'Datapoints[*].[Timestamp,Average]' \
                --output table
            
            echo "Verificando volumes EBS não anexados..."
            aws ec2 describe-volumes \
                --profile "$profile_name" \
                --filters Name=status,Values=available \
                --query 'Volumes[*].[VolumeId,Size,CreateTime,AvailabilityZone]' \
                --output table
            
            echo "Verificando snapshots EBS antigos..."
            aws ec2 describe-snapshots \
                --profile "$profile_name" \
                --owner-ids self \
                --query 'Snapshots[?StartTime<=`'$(date -d '90 days ago' '+%Y-%m-%d')'`].[SnapshotId,VolumeId,StartTime,VolumeSize]' \
                --output table
            ;;
        5)
            echo "Obtendo recomendações de economia..."
            
            echo "Verificando recomendações do AWS Trusted Advisor..."
            aws support describe-trusted-advisor-checks \
                --profile "$profile_name" \
                --language en \
                --query 'checks[?category==`cost_optimizing`].[id,name,description]' \
                --output table
            
            echo "Para obter recomendações detalhadas, execute o seguinte comando para cada check ID:"
            echo "aws support describe-trusted-advisor-check-result --check-id <check-id> --profile $profile_name"
            
            echo "Verificando recomendações de instâncias reservadas..."
            aws ce get-reservation-purchase-recommendation \
                --profile "$profile_name" \
                --service "Amazon Elastic Compute Cloud - Compute" \
                --query 'Recommendations[*].[RecommendationDetails[0].InstanceDetails.EC2InstanceDetails.InstanceType,RecommendationDetails[0].EstimatedMonthlyOnDemandCost,RecommendationDetails[0].EstimatedMonthlySavingsAmount]' \
                --output table
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Análise de custos concluída."
}

# Função para gerenciar orçamentos
manage_budgets() {
    log "INFO" "Iniciando gerenciamento de orçamentos"
    echo "Gerenciando orçamentos AWS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar orçamentos"
    echo "[2] Criar novo orçamento"
    echo "[3] Excluir orçamento"
    read -r operation
    
    case $operation in
        1)
            echo "Listando orçamentos..."
            aws budgets describe-budgets --profile "$profile_name" --account-id $(aws sts get-caller-identity --profile "$profile_name" --query 'Account' --output text) --query 'Budgets[*].[BudgetName,BudgetLimit.Amount,BudgetLimit.Unit,CalculatedSpend.ActualSpend.Amount]' --output table
            ;;
        2)
            echo "Criando novo orçamento..."
            echo "Nome do orçamento:"
            read -r budget_name
            
            echo "Limite do orçamento (valor numérico):"
            read -r budget_limit
            
            echo "Moeda (USD, BRL, etc):"
            read -r currency
            
            # Criar arquivo temporário com a definição do orçamento
            cat > /tmp/budget.json << EOF
{
    "BudgetName": "$budget_name",
    "BudgetLimit": {
        "Amount": "$budget_limit",
        "Unit": "$currency"
    },
    "BudgetType": "COST",
    "TimeUnit": "MONTHLY"
}
EOF
            
            # Criar orçamento
            aws budgets create-budget \
                --profile "$profile_name" \
                --account-id $(aws sts get-caller-identity --profile "$profile_name" --query 'Account' --output text) \
                --budget file:///tmp/budget.json
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Orçamento '$budget_name' criado com sucesso."
                echo "Orçamento '$budget_name' criado com sucesso."
                
                # Perguntar se deseja criar notificação
                echo "Deseja criar uma notificação para este orçamento? [1] sim / [2] não"
                read -r create_notification
                
                if [ "$create_notification" -eq 1 ]; then
                    echo "Limite para notificação (porcentagem do orçamento, ex: 80):"
                    read -r threshold
                    
                    echo "Email para notificação:"
                    read -r email
                    
                    # Criar arquivo temporário com a definição da notificação
                    cat > /tmp/notification.json << EOF
{
    "Notification": {
        "NotificationType": "ACTUAL",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": $threshold,
        "ThresholdType": "PERCENTAGE",
        "NotificationState": "ALARM"
    },
    "Subscribers": [
        {
            "SubscriptionType": "EMAIL",
            "Address": "$email"
        }
    ]
}
EOF
                    
                    # Criar notificação
                    aws budgets create-notification \
                        --profile "$profile_name" \
                        --account-id $(aws sts get-caller-identity --profile "$profile_name" --query 'Account' --output text) \
                        --budget-name "$budget_name" \
                        --cli-input-json file:///tmp/notification.json
                    
                    if [ $? -eq 0 ]; then
                        log "SUCCESS" "Notificação criada com sucesso."
                        echo "Notificação criada com sucesso."
                    else
                        log "ERROR" "Erro ao criar notificação."
                        echo "Erro ao criar notificação. Verifique o arquivo de log para mais detalhes."
                    fi
                fi
            else
                log "ERROR" "Erro ao criar orçamento."
                echo "Erro ao criar orçamento. Verifique o arquivo de log para mais detalhes."
            fi
            
            # Remover arquivos temporários
            rm -f /tmp/budget.json /tmp/notification.json
            ;;
        3)
            echo "Excluindo orçamento..."
            echo "Nome do orçamento:"
            read -r budget_name
            
            echo "Tem certeza que deseja excluir o orçamento '$budget_name'? [1] sim / [2] não"
            read -r confirm
            
            if [ "$confirm" -eq 1 ]; then
                aws budgets delete-budget \
                    --profile "$profile_name" \
                    --account-id $(aws sts get-caller-identity --profile "$profile_name" --query 'Account' --output text) \
                    --budget-name "$budget_name"
                
                if [ $? -eq 0 ]; then
                    log "SUCCESS" "Orçamento '$budget_name' excluído com sucesso."
                    echo "Orçamento '$budget_name' excluído com sucesso."
                else
                    log "ERROR" "Erro ao excluir orçamento."
                    echo "Erro ao excluir orçamento. Verifique o arquivo de log para mais detalhes."
                fi
            else
                echo "Operação cancelada."
            fi
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Operação concluída com sucesso."
}

# Função principal do módulo de otimização de custos
cost_optimization_menu() {
    log "INFO" "Iniciando menu de otimização de custos"
    echo "Menu de Otimização de Custos"
    
    echo "Escolha a operação:"
    echo "[1] Analisar custos"
    echo "[2] Gerenciar orçamentos"
    echo "[3] Voltar"
    read -r option
    
    case $option in
        1)
            analyze_costs
            ;;
        2)
            manage_budgets
            ;;
        3)
            return 0
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
}
