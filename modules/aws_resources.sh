#!/bin/bash
# aws_resources.sh - Módulo para listar recursos AWS
# Parte do Arch CLI

# Função para listar recursos AWS
list_aws_resources() {
    log "INFO" "Listando recursos AWS"
    echo "Listando recursos AWS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha o tipo de recurso para listar:"
    echo "[1] EC2 Instances"
    echo "[2] S3 Buckets"
    echo "[3] RDS Instances"
    echo "[4] Lambda Functions"
    echo "[5] IAM Users"
    echo "[6] CloudFormation Stacks"
    echo "[7] Todos os recursos acima"
    read -r resource_type
    
    case $resource_type in
        1)
            echo "Listando instâncias EC2..."
            aws ec2 describe-instances --profile "$profile_name" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table
            ;;
        2)
            echo "Listando buckets S3..."
            aws s3 ls --profile "$profile_name"
            ;;
        3)
            echo "Listando instâncias RDS..."
            aws rds describe-db-instances --profile "$profile_name" --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]' --output table
            ;;
        4)
            echo "Listando funções Lambda..."
            aws lambda list-functions --profile "$profile_name" --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table
            ;;
        5)
            echo "Listando usuários IAM..."
            aws iam list-users --profile "$profile_name" --query 'Users[*].[UserName,CreateDate]' --output table
            ;;
        6)
            echo "Listando CloudFormation Stacks..."
            aws cloudformation list-stacks --profile "$profile_name" --query 'StackSummaries[*].[StackName,StackStatus,CreationTime]' --output table
            ;;
        7)
            echo "Listando instâncias EC2..."
            aws ec2 describe-instances --profile "$profile_name" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table
            
            echo "Listando buckets S3..."
            aws s3 ls --profile "$profile_name"
            
            echo "Listando instâncias RDS..."
            aws rds describe-db-instances --profile "$profile_name" --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]' --output table
            
            echo "Listando funções Lambda..."
            aws lambda list-functions --profile "$profile_name" --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table
            
            echo "Listando usuários IAM..."
            aws iam list-users --profile "$profile_name" --query 'Users[*].[UserName,CreateDate]' --output table
            
            echo "Listando CloudFormation Stacks..."
            aws cloudformation list-stacks --profile "$profile_name" --query 'StackSummaries[*].[StackName,StackStatus,CreationTime]' --output table
            ;;
        *)
            log "ERROR" "Opção inválida."
            echo "Opção inválida."
            return 1
            ;;
    esac
    
    log "SUCCESS" "Recursos listados com sucesso."
    
    # Perguntar se deseja exportar os resultados para um arquivo
    echo "Deseja exportar os resultados para um arquivo? [1] sim / [2] não"
    read -r export_results
    
    if [ "$export_results" -eq 1 ]; then
        local output_dir="./aws_resources/$(date +%Y-%m-%d_%H-%M-%S)"
        mkdir -p "$output_dir"
        
        case $resource_type in
            1)
                aws ec2 describe-instances --profile "$profile_name" --output json > "$output_dir/ec2_instances.json"
                ;;
            2)
                aws s3api list-buckets --profile "$profile_name" --output json > "$output_dir/s3_buckets.json"
                ;;
            3)
                aws rds describe-db-instances --profile "$profile_name" --output json > "$output_dir/rds_instances.json"
                ;;
            4)
                aws lambda list-functions --profile "$profile_name" --output json > "$output_dir/lambda_functions.json"
                ;;
            5)
                aws iam list-users --profile "$profile_name" --output json > "$output_dir/iam_users.json"
                ;;
            6)
                aws cloudformation list-stacks --profile "$profile_name" --output json > "$output_dir/cloudformation_stacks.json"
                ;;
            7)
                aws ec2 describe-instances --profile "$profile_name" --output json > "$output_dir/ec2_instances.json"
                aws s3api list-buckets --profile "$profile_name" --output json > "$output_dir/s3_buckets.json"
                aws rds describe-db-instances --profile "$profile_name" --output json > "$output_dir/rds_instances.json"
                aws lambda list-functions --profile "$profile_name" --output json > "$output_dir/lambda_functions.json"
                aws iam list-users --profile "$profile_name" --output json > "$output_dir/iam_users.json"
                aws cloudformation list-stacks --profile "$profile_name" --output json > "$output_dir/cloudformation_stacks.json"
                ;;
        esac
        
        echo "Resultados exportados para: $output_dir"
        log "SUCCESS" "Resultados exportados para: $output_dir"
    fi
}
