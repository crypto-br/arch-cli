#!/bin/bash
# database.sh - Módulo para gerenciamento de bancos de dados
# Parte do Arch CLI

# Função para gerenciar instâncias RDS
manage_rds_instances() {
    log "INFO" "Iniciando gerenciamento de instâncias RDS"
    echo "Gerenciando instâncias RDS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar instâncias RDS"
    echo "[2] Descrever instância RDS"
    echo "[3] Iniciar/Parar instância RDS"
    echo "[4] Criar snapshot"
    echo "[5] Restaurar a partir de snapshot"
    echo "[6] Monitorar métricas de performance"
    read -r operation
    
    case $operation in
        1)
            echo "Listando instâncias RDS..."
            aws rds describe-db-instances --profile "$profile_name" --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus,EngineVersion,DBInstanceClass]' --output table
            ;;
        2)
            echo "Informe o identificador da instância RDS:"
            read -r db_instance_id
            
            echo "Descrevendo instância $db_instance_id..."
            aws rds describe-db-instances --profile "$profile_name" --db-instance-identifier "$db_instance_id" --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus,EngineVersion,DBInstanceClass,AllocatedStorage,Endpoint.Address,Endpoint.Port,MultiAZ]' --output table
            ;;
        3)
            echo "Informe o identificador da instância RDS:"
            read -r db_instance_id
            
            # Verificar status atual
            status=$(aws rds describe-db-instances --profile "$profile_name" --db-instance-identifier "$db_instance_id" --query 'DBInstances[0].DBInstanceStatus' --output text)
            
            echo "Status atual: $status"
            
            if [ "$status" = "available" ]; then
                echo "Deseja parar a instância? [1] sim / [2] não"
                read -r stop_instance
                
                if [ "$stop_instance" -eq 1 ]; then
                    echo "Parando instância $db_instance_id..."
                    aws rds stop-db-instance --profile "$profile_name" --db-instance-identifier "$db_instance_id"
                    
                    if [ $? -eq 0 ]; then
                        log "SUCCESS" "Comando para parar a instância enviado com sucesso."
                        echo "Comando para parar a instância enviado com sucesso."
                    else
                        log "ERROR" "Erro ao parar a instância."
                        echo "Erro ao parar a instância. Verifique o arquivo de log para mais detalhes."
                    fi
                fi
            elif [ "$status" = "stopped" ]; then
                echo "Deseja iniciar a instância? [1] sim / [2] não"
                read -r start_instance
                
                if [ "$start_instance" -eq 1 ]; then
                    echo "Iniciando instância $db_instance_id..."
                    aws rds start-db-instance --profile "$profile_name" --db-instance-identifier "$db_instance_id"
                    
                    if [ $? -eq 0 ]; then
                        log "SUCCESS" "Comando para iniciar a instância enviado com sucesso."
                        echo "Comando para iniciar a instância enviado com sucesso."
                    else
                        log "ERROR" "Erro ao iniciar a instância."
                        echo "Erro ao iniciar a instância. Verifique o arquivo de log para mais detalhes."
                    fi
                fi
            else
                echo "A instância está em um estado que não permite iniciar ou parar: $status"
            fi
            ;;
        4)
            echo "Informe o identificador da instância RDS:"
            read -r db_instance_id
            
            # Criar identificador do snapshot com data
            snapshot_id="$db_instance_id-snapshot-$(date +%Y-%m-%d-%H-%M)"
            
            echo "Criando snapshot $snapshot_id..."
            aws rds create-db-snapshot --profile "$profile_name" --db-instance-identifier "$db_instance_id" --db-snapshot-identifier "$snapshot_id"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Comando para criar snapshot enviado com sucesso."
                echo "Comando para criar snapshot enviado com sucesso."
            else
                log "ERROR" "Erro ao criar snapshot."
                echo "Erro ao criar snapshot. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        5)
            echo "Listando snapshots disponíveis..."
            aws rds describe-db-snapshots --profile "$profile_name" --query 'DBSnapshots[*].[DBSnapshotIdentifier,DBInstanceIdentifier,SnapshotCreateTime,Status]' --output table
            
            echo "Informe o identificador do snapshot:"
            read -r snapshot_id
            
            echo "Informe o identificador da nova instância RDS:"
            read -r new_db_instance_id
            
            echo "Informe a classe da instância (ex: db.t3.micro):"
            read -r db_instance_class
            
            echo "Restaurando snapshot $snapshot_id para nova instância $new_db_instance_id..."
            aws rds restore-db-instance-from-db-snapshot --profile "$profile_name" --db-instance-identifier "$new_db_instance_id" --db-snapshot-identifier "$snapshot_id" --db-instance-class "$db_instance_class"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Comando para restaurar snapshot enviado com sucesso."
                echo "Comando para restaurar snapshot enviado com sucesso."
            else
                log "ERROR" "Erro ao restaurar snapshot."
                echo "Erro ao restaurar snapshot. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        6)
            echo "Informe o identificador da instância RDS:"
            read -r db_instance_id
            
            echo "Escolha a métrica para monitorar:"
            echo "[1] CPU Utilization"
            echo "[2] Free Memory"
            echo "[3] Free Storage Space"
            echo "[4] Database Connections"
            echo "[5] Read IOPS"
            echo "[6] Write IOPS"
            read -r metric_choice
            
            case $metric_choice in
                1)
                    metric_name="CPUUtilization"
                    ;;
                2)
                    metric_name="FreeableMemory"
                    ;;
                3)
                    metric_name="FreeStorageSpace"
                    ;;
                4)
                    metric_name="DatabaseConnections"
                    ;;
                5)
                    metric_name="ReadIOPS"
                    ;;
                6)
                    metric_name="WriteIOPS"
                    ;;
                *)
                    log "ERROR" "Opção inválida."
                    echo "Opção inválida."
                    return 1
                    ;;
            esac
            
            echo "Obtendo métricas de $metric_name para $db_instance_id nas últimas 3 horas..."
            aws cloudwatch get-metric-statistics --profile "$profile_name" \
                --namespace AWS/RDS \
                --metric-name "$metric_name" \
                --dimensions Name=DBInstanceIdentifier,Value="$db_instance_id" \
                --start-time "$(date -d '3 hours ago' '+%Y-%m-%dT%H:%M:%S')" \
                --end-time "$(date '+%Y-%m-%dT%H:%M:%S')" \
                --period 300 \
                --statistics Average \
                --query 'Datapoints[*].[Timestamp,Average]' \
                --output table
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Operação concluída com sucesso."
}

# Função para gerenciar tabelas DynamoDB
manage_dynamodb_tables() {
    log "INFO" "Iniciando gerenciamento de tabelas DynamoDB"
    echo "Gerenciando tabelas DynamoDB..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar tabelas DynamoDB"
    echo "[2] Descrever tabela"
    echo "[3] Ajustar capacidade de leitura/escrita"
    echo "[4] Criar backup"
    echo "[5] Restaurar a partir de backup"
    echo "[6] Habilitar/Desabilitar Point-in-Time Recovery"
    read -r operation
    
    case $operation in
        1)
            echo "Listando tabelas DynamoDB..."
            aws dynamodb list-tables --profile "$profile_name" --query 'TableNames' --output table
            ;;
        2)
            echo "Informe o nome da tabela:"
            read -r table_name
            
            echo "Descrevendo tabela $table_name..."
            aws dynamodb describe-table --profile "$profile_name" --table-name "$table_name" --query 'Table.[TableName,TableStatus,ProvisionedThroughput.ReadCapacityUnits,ProvisionedThroughput.WriteCapacityUnits,TableSizeBytes,ItemCount]' --output table
            ;;
        3)
            echo "Informe o nome da tabela:"
            read -r table_name
            
            # Obter capacidade atual
            read_capacity=$(aws dynamodb describe-table --profile "$profile_name" --table-name "$table_name" --query 'Table.ProvisionedThroughput.ReadCapacityUnits' --output text)
            write_capacity=$(aws dynamodb describe-table --profile "$profile_name" --table-name "$table_name" --query 'Table.ProvisionedThroughput.WriteCapacityUnits' --output text)
            
            echo "Capacidade atual: Read=$read_capacity, Write=$write_capacity"
            
            echo "Informe a nova capacidade de leitura (RCU):"
            read -r new_read_capacity
            
            echo "Informe a nova capacidade de escrita (WCU):"
            read -r new_write_capacity
            
            echo "Atualizando capacidade da tabela $table_name..."
            aws dynamodb update-table --profile "$profile_name" --table-name "$table_name" --provisioned-throughput ReadCapacityUnits="$new_read_capacity",WriteCapacityUnits="$new_write_capacity"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Capacidade da tabela atualizada com sucesso."
                echo "Capacidade da tabela atualizada com sucesso."
            else
                log "ERROR" "Erro ao atualizar capacidade da tabela."
                echo "Erro ao atualizar capacidade da tabela. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        4)
            echo "Informe o nome da tabela:"
            read -r table_name
            
            # Criar nome do backup com data
            backup_name="$table_name-backup-$(date +%Y-%m-%d-%H-%M)"
            
            echo "Criando backup $backup_name..."
            aws dynamodb create-backup --profile "$profile_name" --table-name "$table_name" --backup-name "$backup_name"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Backup criado com sucesso."
                echo "Backup criado com sucesso."
            else
                log "ERROR" "Erro ao criar backup."
                echo "Erro ao criar backup. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        5)
            echo "Listando backups disponíveis..."
            aws dynamodb list-backups --profile "$profile_name" --query 'BackupSummaries[*].[BackupName,TableName,BackupCreationDateTime,BackupStatus]' --output table
            
            echo "Informe o ARN do backup:"
            read -r backup_arn
            
            echo "Informe o nome da nova tabela:"
            read -r new_table_name
            
            echo "Restaurando backup para nova tabela $new_table_name..."
            aws dynamodb restore-table-from-backup --profile "$profile_name" --target-table-name "$new_table_name" --backup-arn "$backup_arn"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Comando para restaurar backup enviado com sucesso."
                echo "Comando para restaurar backup enviado com sucesso."
            else
                log "ERROR" "Erro ao restaurar backup."
                echo "Erro ao restaurar backup. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        6)
            echo "Informe o nome da tabela:"
            read -r table_name
            
            # Verificar status atual do PITR
            pitr_status=$(aws dynamodb describe-continuous-backups --profile "$profile_name" --table-name "$table_name" --query 'ContinuousBackupsDescription.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus' --output text)
            
            echo "Status atual do Point-in-Time Recovery: $pitr_status"
            
            if [ "$pitr_status" = "ENABLED" ]; then
                echo "Deseja desabilitar o Point-in-Time Recovery? [1] sim / [2] não"
                read -r disable_pitr
                
                if [ "$disable_pitr" -eq 1 ]; then
                    echo "Desabilitando Point-in-Time Recovery para a tabela $table_name..."
                    aws dynamodb update-continuous-backups --profile "$profile_name" --table-name "$table_name" --point-in-time-recovery-specification PointInTimeRecoveryEnabled=false
                    
                    if [ $? -eq 0 ]; then
                        log "SUCCESS" "Point-in-Time Recovery desabilitado com sucesso."
                        echo "Point-in-Time Recovery desabilitado com sucesso."
                    else
                        log "ERROR" "Erro ao desabilitar Point-in-Time Recovery."
                        echo "Erro ao desabilitar Point-in-Time Recovery. Verifique o arquivo de log para mais detalhes."
                    fi
                fi
            else
                echo "Deseja habilitar o Point-in-Time Recovery? [1] sim / [2] não"
                read -r enable_pitr
                
                if [ "$enable_pitr" -eq 1 ]; then
                    echo "Habilitando Point-in-Time Recovery para a tabela $table_name..."
                    aws dynamodb update-continuous-backups --profile "$profile_name" --table-name "$table_name" --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
                    
                    if [ $? -eq 0 ]; then
                        log "SUCCESS" "Point-in-Time Recovery habilitado com sucesso."
                        echo "Point-in-Time Recovery habilitado com sucesso."
                    else
                        log "ERROR" "Erro ao habilitar Point-in-Time Recovery."
                        echo "Erro ao habilitar Point-in-Time Recovery. Verifique o arquivo de log para mais detalhes."
                    fi
                fi
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

# Função principal do módulo de banco de dados
database_menu() {
    log "INFO" "Iniciando menu de banco de dados"
    echo "Menu de Gerenciamento de Banco de Dados"
    
    echo "Escolha a operação:"
    echo "[1] Gerenciar instâncias RDS"
    echo "[2] Gerenciar tabelas DynamoDB"
    echo "[3] Voltar"
    read -r option
    
    case $option in
        1)
            manage_rds_instances
            ;;
        2)
            manage_dynamodb_tables
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
