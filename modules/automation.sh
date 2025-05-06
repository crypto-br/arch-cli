#!/bin/bash
# automation.sh - Módulo para automação de rotinas
# Parte do Arch CLI

# Função para gerenciar backups
manage_backups() {
    log "INFO" "Iniciando gerenciamento de backups"
    echo "Gerenciando backups..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha o tipo de backup:"
    echo "[1] Snapshots de volumes EBS"
    echo "[2] Snapshots de instâncias RDS"
    echo "[3] Backup de tabelas DynamoDB"
    echo "[4] Listar backups existentes"
    read -r backup_type
    
    case $backup_type in
        1)
            echo "Criando snapshots de volumes EBS..."
            
            # Listar volumes EBS
            echo "Listando volumes EBS..."
            aws ec2 describe-volumes --profile "$profile_name" --query 'Volumes[*].[VolumeId,Size,State,AvailabilityZone]' --output table
            
            echo "Informe o ID do volume (ou 'all' para todos os volumes):"
            read -r volume_id
            
            if [ "$volume_id" = "all" ]; then
                # Obter todos os volumes
                volumes=$(aws ec2 describe-volumes --profile "$profile_name" --query 'Volumes[*].VolumeId' --output text)
                
                for vol in $volumes; do
                    # Criar descrição com data
                    description="Backup automático via Arch CLI - $(date +%Y-%m-%d)"
                    
                    echo "Criando snapshot do volume $vol..."
                    aws ec2 create-snapshot --profile "$profile_name" --volume-id "$vol" --description "$description"
                done
            else
                # Criar descrição com data
                description="Backup automático via Arch CLI - $(date +%Y-%m-%d)"
                
                echo "Criando snapshot do volume $volume_id..."
                aws ec2 create-snapshot --profile "$profile_name" --volume-id "$volume_id" --description "$description"
            fi
            ;;
        2)
            echo "Criando snapshots de instâncias RDS..."
            
            # Listar instâncias RDS
            echo "Listando instâncias RDS..."
            aws rds describe-db-instances --profile "$profile_name" --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]' --output table
            
            echo "Informe o identificador da instância RDS:"
            read -r db_instance_id
            
            # Criar identificador do snapshot com data
            snapshot_id="$db_instance_id-snapshot-$(date +%Y-%m-%d-%H-%M)"
            
            echo "Criando snapshot $snapshot_id..."
            aws rds create-db-snapshot --profile "$profile_name" --db-instance-identifier "$db_instance_id" --db-snapshot-identifier "$snapshot_id"
            ;;
        3)
            echo "Criando backup de tabelas DynamoDB..."
            
            # Listar tabelas DynamoDB
            echo "Listando tabelas DynamoDB..."
            aws dynamodb list-tables --profile "$profile_name" --query 'TableNames' --output table
            
            echo "Informe o nome da tabela:"
            read -r table_name
            
            # Criar nome do backup com data
            backup_name="$table_name-backup-$(date +%Y-%m-%d-%H-%M)"
            
            echo "Criando backup $backup_name..."
            aws dynamodb create-backup --profile "$profile_name" --table-name "$table_name" --backup-name "$backup_name"
            ;;
        4)
            echo "Listando backups existentes..."
            
            echo "Escolha o tipo de backup para listar:"
            echo "[1] Snapshots de volumes EBS"
            echo "[2] Snapshots de instâncias RDS"
            echo "[3] Backups de tabelas DynamoDB"
            read -r list_type
            
            case $list_type in
                1)
                    echo "Listando snapshots de volumes EBS..."
                    aws ec2 describe-snapshots --profile "$profile_name" --owner-ids self --query 'Snapshots[*].[SnapshotId,VolumeId,StartTime,Description]' --output table
                    ;;
                2)
                    echo "Listando snapshots de instâncias RDS..."
                    aws rds describe-db-snapshots --profile "$profile_name" --query 'DBSnapshots[*].[DBSnapshotIdentifier,DBInstanceIdentifier,SnapshotCreateTime,Status]' --output table
                    ;;
                3)
                    echo "Listando backups de tabelas DynamoDB..."
                    aws dynamodb list-backups --profile "$profile_name" --query 'BackupSummaries[*].[BackupName,TableName,BackupCreationDateTime,BackupStatus]' --output table
                    ;;
                *)
                    log "ERROR" "Opção inválida."
                    echo "Opção inválida."
                    return 1
                    ;;
            esac
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Operação de backup concluída com sucesso."
}

# Função para agendar tarefas
schedule_tasks() {
    log "INFO" "Iniciando agendamento de tarefas"
    echo "Agendando tarefas..."
    
    echo "Esta função permite criar entradas no crontab para executar tarefas automaticamente."
    echo "Escolha o tipo de tarefa:"
    echo "[1] Backup automático"
    echo "[2] Verificação de saúde"
    echo "[3] Rotação de logs"
    echo "[4] Tarefa personalizada"
    read -r task_type
    
    case $task_type in
        1)
            echo "Configurando backup automático..."
            
            echo "Informe o profile do AWS-CLI a ser usado:"
            read -r profile_name
            
            echo "Escolha a frequência:"
            echo "[1] Diária"
            echo "[2] Semanal"
            echo "[3] Mensal"
            read -r frequency
            
            case $frequency in
                1)
                    # Diária - executar às 2h da manhã
                    cron_time="0 2 * * *"
                    ;;
                2)
                    # Semanal - executar aos domingos às 2h da manhã
                    cron_time="0 2 * * 0"
                    ;;
                3)
                    # Mensal - executar no primeiro dia do mês às 2h da manhã
                    cron_time="0 2 1 * *"
                    ;;
                *)
                    log "ERROR" "Opção inválida."
                    echo "Opção inválida."
                    return 1
                    ;;
            esac
            
            # Criar script temporário para o backup
            backup_script="$HOME/.arch-cli/backup_script.sh"
            mkdir -p "$HOME/.arch-cli"
            
            cat > "$backup_script" << EOF
#!/bin/bash
# Script de backup automático criado pelo Arch CLI
export AWS_PROFILE=$profile_name
aws ec2 describe-volumes --query 'Volumes[*].VolumeId' --output text | while read vol; do
    aws ec2 create-snapshot --volume-id "\$vol" --description "Backup automático - \$(date +%Y-%m-%d)"
done
EOF
            
            chmod +x "$backup_script"
            
            # Adicionar ao crontab
            (crontab -l 2>/dev/null || echo "") | grep -v "$backup_script" | { cat; echo "$cron_time $backup_script"; } | crontab -
            
            echo "Backup automático configurado com sucesso."
            echo "Será executado: $cron_time"
            ;;
        2)
            echo "Configurando verificação de saúde..."
            
            echo "Informe o profile do AWS-CLI a ser usado:"
            read -r profile_name
            
            echo "Informe o endereço de email para receber alertas:"
            read -r email
            
            # Criar script temporário para verificação de saúde
            health_script="$HOME/.arch-cli/health_check.sh"
            mkdir -p "$HOME/.arch-cli"
            
            cat > "$health_script" << EOF
#!/bin/bash
# Script de verificação de saúde criado pelo Arch CLI
export AWS_PROFILE=$profile_name

# Verificar instâncias EC2 paradas
stopped_instances=\$(aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped --query 'Reservations[*].Instances[*].[InstanceId]' --output text)

# Verificar instâncias RDS com problemas
rds_issues=\$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus!=`available`].[DBInstanceIdentifier,DBInstanceStatus]' --output text)

# Enviar email se houver problemas
if [ -n "\$stopped_instances" ] || [ -n "\$rds_issues" ]; then
    echo "Alerta de saúde da AWS - \$(date)" > /tmp/health_alert.txt
    
    if [ -n "\$stopped_instances" ]; then
        echo -e "\nInstâncias EC2 paradas:" >> /tmp/health_alert.txt
        echo "\$stopped_instances" >> /tmp/health_alert.txt
    fi
    
    if [ -n "\$rds_issues" ]; then
        echo -e "\nProblemas com instâncias RDS:" >> /tmp/health_alert.txt
        echo "\$rds_issues" >> /tmp/health_alert.txt
    fi
    
    mail -s "Alerta de saúde AWS" $email < /tmp/health_alert.txt
fi
EOF
            
            chmod +x "$health_script"
            
            # Adicionar ao crontab para executar a cada hora
            (crontab -l 2>/dev/null || echo "") | grep -v "$health_script" | { cat; echo "0 * * * * $health_script"; } | crontab -
            
            echo "Verificação de saúde configurada com sucesso."
            echo "Será executada a cada hora."
            ;;
        3)
            echo "Configurando rotação de logs..."
            
            echo "Informe o diretório de logs a ser rotacionado:"
            read -r log_dir
            
            # Criar script temporário para rotação de logs
            log_script="$HOME/.arch-cli/log_rotation.sh"
            mkdir -p "$HOME/.arch-cli"
            
            cat > "$log_script" << EOF
#!/bin/bash
# Script de rotação de logs criado pelo Arch CLI

# Comprimir logs com mais de 7 dias
find $log_dir -name "*.log" -type f -mtime +7 -exec gzip {} \;

# Remover logs comprimidos com mais de 30 dias
find $log_dir -name "*.gz" -type f -mtime +30 -delete
EOF
            
            chmod +x "$log_script"
            
            # Adicionar ao crontab para executar diariamente à meia-noite
            (crontab -l 2>/dev/null || echo "") | grep -v "$log_script" | { cat; echo "0 0 * * * $log_script"; } | crontab -
            
            echo "Rotação de logs configurada com sucesso."
            echo "Será executada diariamente à meia-noite."
            ;;
        4)
            echo "Configurando tarefa personalizada..."
            
            echo "Informe o comando a ser executado:"
            read -r custom_command
            
            echo "Informe o agendamento no formato crontab (ex: '0 2 * * *' para diariamente às 2h):"
            read -r custom_schedule
            
            # Adicionar ao crontab
            (crontab -l 2>/dev/null || echo "") | { cat; echo "$custom_schedule $custom_command"; } | crontab -
            
            echo "Tarefa personalizada configurada com sucesso."
            echo "Será executada: $custom_schedule"
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Agendamento de tarefas concluído com sucesso."
}

# Função principal do módulo de automação
automation_menu() {
    log "INFO" "Iniciando menu de automação"
    echo "Menu de Automação de Rotinas"
    
    echo "Escolha a operação:"
    echo "[1] Gerenciar backups"
    echo "[2] Agendar tarefas"
    echo "[3] Voltar"
    read -r option
    
    case $option in
        1)
            manage_backups
            ;;
        2)
            schedule_tasks
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
