#!/bin/bash
# monitoring.sh - Módulo para monitoramento e observabilidade
# Parte do Arch CLI

# Função para gerenciar alarmes do CloudWatch
manage_cloudwatch_alarms() {
    log "INFO" "Iniciando gerenciamento de alarmes CloudWatch"
    echo "Gerenciando alarmes CloudWatch..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar alarmes"
    echo "[2] Criar novo alarme"
    echo "[3] Desativar alarme"
    echo "[4] Ativar alarme"
    echo "[5] Excluir alarme"
    read -r operation
    
    case $operation in
        1)
            echo "Listando alarmes CloudWatch..."
            aws cloudwatch describe-alarms --profile "$profile_name" --query 'MetricAlarms[*].[AlarmName,StateValue,MetricName,Namespace]' --output table
            ;;
        2)
            echo "Criando novo alarme..."
            echo "Nome do alarme:"
            read -r alarm_name
            
            echo "Namespace da métrica (ex: AWS/EC2, AWS/RDS):"
            read -r namespace
            
            echo "Nome da métrica (ex: CPUUtilization):"
            read -r metric_name
            
            echo "Estatística (Average, Sum, Minimum, Maximum):"
            read -r statistic
            
            echo "Período em segundos (60, 300, 3600):"
            read -r period
            
            echo "Limite (threshold):"
            read -r threshold
            
            echo "Operador de comparação (GreaterThanThreshold, LessThanThreshold, etc):"
            read -r comparison_operator
            
            echo "Número de períodos para avaliação:"
            read -r evaluation_periods
            
            aws cloudwatch put-metric-alarm \
                --profile "$profile_name" \
                --alarm-name "$alarm_name" \
                --namespace "$namespace" \
                --metric-name "$metric_name" \
                --statistic "$statistic" \
                --period "$period" \
                --threshold "$threshold" \
                --comparison-operator "$comparison_operator" \
                --evaluation-periods "$evaluation_periods" \
                --alarm-description "Alarme criado via Arch CLI"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Alarme '$alarm_name' criado com sucesso."
                echo "Alarme '$alarm_name' criado com sucesso."
            else
                log "ERROR" "Erro ao criar alarme."
                echo "Erro ao criar alarme. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        3)
            echo "Desativando alarme..."
            echo "Nome do alarme:"
            read -r alarm_name
            
            aws cloudwatch disable-alarm-actions --profile "$profile_name" --alarm-names "$alarm_name"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Alarme '$alarm_name' desativado com sucesso."
                echo "Alarme '$alarm_name' desativado com sucesso."
            else
                log "ERROR" "Erro ao desativar alarme."
                echo "Erro ao desativar alarme. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        4)
            echo "Ativando alarme..."
            echo "Nome do alarme:"
            read -r alarm_name
            
            aws cloudwatch enable-alarm-actions --profile "$profile_name" --alarm-names "$alarm_name"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Alarme '$alarm_name' ativado com sucesso."
                echo "Alarme '$alarm_name' ativado com sucesso."
            else
                log "ERROR" "Erro ao ativar alarme."
                echo "Erro ao ativar alarme. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        5)
            echo "Excluindo alarme..."
            echo "Nome do alarme:"
            read -r alarm_name
            
            echo "Tem certeza que deseja excluir o alarme '$alarm_name'? [1] sim / [2] não"
            read -r confirm
            
            if [ "$confirm" -eq 1 ]; then
                aws cloudwatch delete-alarms --profile "$profile_name" --alarm-names "$alarm_name"
                
                if [ $? -eq 0 ]; then
                    log "SUCCESS" "Alarme '$alarm_name' excluído com sucesso."
                    echo "Alarme '$alarm_name' excluído com sucesso."
                else
                    log "ERROR" "Erro ao excluir alarme."
                    echo "Erro ao excluir alarme. Verifique o arquivo de log para mais detalhes."
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

# Função para visualizar logs do CloudWatch
view_cloudwatch_logs() {
    log "INFO" "Iniciando visualização de logs CloudWatch"
    echo "Visualizando logs CloudWatch..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    # Listar grupos de logs
    echo "Listando grupos de logs..."
    aws logs describe-log-groups --profile "$profile_name" --query 'logGroups[*].logGroupName' --output table
    
    echo "Informe o nome do grupo de logs:"
    read -r log_group_name
    
    # Listar streams de logs
    echo "Listando streams de logs para o grupo '$log_group_name'..."
    aws logs describe-log-streams --profile "$profile_name" --log-group-name "$log_group_name" --query 'logStreams[*].logStreamName' --output table
    
    echo "Informe o nome do stream de logs (deixe em branco para ver todos):"
    read -r log_stream_name
    
    echo "Número de eventos a serem exibidos (padrão: 20):"
    read -r limit
    limit=${limit:-20}
    
    # Obter logs
    if [ -z "$log_stream_name" ]; then
        echo "Obtendo logs do grupo '$log_group_name'..."
        aws logs filter-log-events --profile "$profile_name" --log-group-name "$log_group_name" --limit "$limit" --query 'events[*].[timestamp,message]' --output table
    else
        echo "Obtendo logs do stream '$log_stream_name' no grupo '$log_group_name'..."
        aws logs get-log-events --profile "$profile_name" --log-group-name "$log_group_name" --log-stream-name "$log_stream_name" --limit "$limit" --query 'events[*].[timestamp,message]' --output table
    fi
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Logs exibidos com sucesso."
    else
        log "ERROR" "Erro ao obter logs."
        echo "Erro ao obter logs. Verifique o arquivo de log para mais detalhes."
    fi
    
    # Perguntar se deseja exportar os logs
    echo "Deseja exportar os logs para um arquivo? [1] sim / [2] não"
    read -r export_logs
    
    if [ "$export_logs" -eq 1 ]; then
        local output_dir="./cloudwatch_logs/$(date +%Y-%m-%d_%H-%M-%S)"
        mkdir -p "$output_dir"
        
        if [ -z "$log_stream_name" ]; then
            aws logs filter-log-events --profile "$profile_name" --log-group-name "$log_group_name" --limit "$limit" --output json > "$output_dir/logs.json"
        else
            aws logs get-log-events --profile "$profile_name" --log-group-name "$log_group_name" --log-stream-name "$log_stream_name" --limit "$limit" --output json > "$output_dir/logs.json"
        fi
        
        echo "Logs exportados para: $output_dir/logs.json"
        log "SUCCESS" "Logs exportados para: $output_dir/logs.json"
    fi
}

# Função para verificar saúde de serviços
check_service_health() {
    log "INFO" "Iniciando verificação de saúde de serviços"
    echo "Verificando saúde de serviços AWS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha o serviço para verificar:"
    echo "[1] EC2"
    echo "[2] RDS"
    echo "[3] ELB"
    echo "[4] Lambda"
    echo "[5] Status geral dos serviços AWS"
    read -r service
    
    case $service in
        1)
            echo "Verificando saúde das instâncias EC2..."
            aws ec2 describe-instance-status --profile "$profile_name" --query 'InstanceStatuses[*].[InstanceId,InstanceStatus.Status,SystemStatus.Status]' --output table
            ;;
        2)
            echo "Verificando saúde das instâncias RDS..."
            aws rds describe-db-instances --profile "$profile_name" --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,DBInstanceClass]' --output table
            ;;
        3)
            echo "Verificando saúde dos balanceadores de carga..."
            echo "Tipo de balanceador: [1] Application Load Balancer / [2] Network Load Balancer / [3] Classic Load Balancer"
            read -r lb_type
            
            if [ "$lb_type" -eq 1 ]; then
                aws elbv2 describe-load-balancers --profile "$profile_name" --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]' --output table
                aws elbv2 describe-target-groups --profile "$profile_name" --query 'TargetGroups[*].[TargetGroupName,TargetType]' --output table
            elif [ "$lb_type" -eq 2 ]; then
                aws elbv2 describe-load-balancers --profile "$profile_name" --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]' --output table
                aws elbv2 describe-target-groups --profile "$profile_name" --query 'TargetGroups[*].[TargetGroupName,TargetType]' --output table
            elif [ "$lb_type" -eq 3 ]; then
                aws elb describe-load-balancers --profile "$profile_name" --query 'LoadBalancerDescriptions[*].[LoadBalancerName,DNSName]' --output table
                aws elb describe-instance-health --profile "$profile_name" --load-balancer-name $(aws elb describe-load-balancers --profile "$profile_name" --query 'LoadBalancerDescriptions[0].LoadBalancerName' --output text) --query 'InstanceStates[*].[InstanceId,State]' --output table
            else
                echo "Opção inválida."
            fi
            ;;
        4)
            echo "Verificando saúde das funções Lambda..."
            aws lambda list-functions --profile "$profile_name" --query 'Functions[*].[FunctionName,Runtime,LastUpdateStatus]' --output table
            ;;
        5)
            echo "Verificando status geral dos serviços AWS..."
            echo "Esta informação não está disponível via AWS CLI. Por favor, verifique o AWS Service Health Dashboard em: https://status.aws.amazon.com/"
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Verificação de saúde concluída."
}

# Função principal do módulo de monitoramento
monitoring_menu() {
    log "INFO" "Iniciando menu de monitoramento"
    echo "Menu de Monitoramento e Observabilidade"
    
    echo "Escolha a operação:"
    echo "[1] Gerenciar alarmes CloudWatch"
    echo "[2] Visualizar logs CloudWatch"
    echo "[3] Verificar saúde de serviços"
    echo "[4] Voltar"
    read -r option
    
    case $option in
        1)
            manage_cloudwatch_alarms
            ;;
        2)
            view_cloudwatch_logs
            ;;
        3)
            check_service_health
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
