#!/bin/bash
# containers.sh - Módulo para gerenciamento de containers e Kubernetes
# Parte do Arch CLI

# Função para gerenciar clusters EKS
manage_eks_clusters() {
    log "INFO" "Iniciando gerenciamento de clusters EKS"
    echo "Gerenciando clusters EKS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar clusters EKS"
    echo "[2] Descrever cluster EKS"
    echo "[3] Atualizar kubeconfig para um cluster"
    echo "[4] Listar nodes de um cluster"
    read -r operation
    
    case $operation in
        1)
            echo "Listando clusters EKS..."
            aws eks list-clusters --profile "$profile_name" --query 'clusters' --output table
            ;;
        2)
            echo "Informe o nome do cluster:"
            read -r cluster_name
            
            echo "Descrevendo cluster $cluster_name..."
            aws eks describe-cluster --profile "$profile_name" --name "$cluster_name" --query 'cluster.[name,version,status,platformVersion,endpoint]' --output table
            ;;
        3)
            echo "Informe o nome do cluster:"
            read -r cluster_name
            
            echo "Atualizando kubeconfig para o cluster $cluster_name..."
            aws eks update-kubeconfig --profile "$profile_name" --name "$cluster_name"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Kubeconfig atualizado com sucesso."
                echo "Kubeconfig atualizado com sucesso."
                
                # Verificar se kubectl está instalado
                if command -v kubectl &> /dev/null; then
                    echo "Testando conexão com o cluster..."
                    kubectl get nodes
                else
                    echo "kubectl não está instalado. Instale-o para interagir com o cluster."
                fi
            else
                log "ERROR" "Erro ao atualizar kubeconfig."
                echo "Erro ao atualizar kubeconfig. Verifique o arquivo de log para mais detalhes."
            fi
            ;;
        4)
            echo "Informe o nome do cluster:"
            read -r cluster_name
            
            echo "Listando nodegroups do cluster $cluster_name..."
            aws eks list-nodegroups --profile "$profile_name" --cluster-name "$cluster_name" --query 'nodegroups' --output table
            
            echo "Informe o nome do nodegroup (deixe em branco para listar todos):"
            read -r nodegroup_name
            
            if [ -z "$nodegroup_name" ]; then
                # Listar todos os nodegroups
                nodegroups=$(aws eks list-nodegroups --profile "$profile_name" --cluster-name "$cluster_name" --query 'nodegroups[]' --output text)
                
                for ng in $nodegroups; do
                    echo "Detalhes do nodegroup $ng:"
                    aws eks describe-nodegroup --profile "$profile_name" --cluster-name "$cluster_name" --nodegroup-name "$ng" --query 'nodegroup.[nodegroupName,status,instanceTypes,desiredSize,minSize,maxSize]' --output table
                done
            else
                # Listar nodegroup específico
                aws eks describe-nodegroup --profile "$profile_name" --cluster-name "$cluster_name" --nodegroup-name "$nodegroup_name" --query 'nodegroup.[nodegroupName,status,instanceTypes,desiredSize,minSize,maxSize]' --output table
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

# Função para gerenciar serviços ECS
manage_ecs_services() {
    log "INFO" "Iniciando gerenciamento de serviços ECS"
    echo "Gerenciando serviços ECS..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar clusters ECS"
    echo "[2] Listar serviços de um cluster"
    echo "[3] Descrever serviço"
    echo "[4] Listar tarefas de um serviço"
    echo "[5] Atualizar serviço"
    read -r operation
    
    case $operation in
        1)
            echo "Listando clusters ECS..."
            aws ecs list-clusters --profile "$profile_name" --query 'clusterArns[]' --output table
            ;;
        2)
            echo "Obtendo lista de clusters ECS..."
            clusters=$(aws ecs list-clusters --profile "$profile_name" --query 'clusterArns[]' --output text)
            
            if [ -z "$clusters" ]; then
                echo "Nenhum cluster ECS encontrado."
                return 1
            fi
            
            echo "Clusters ECS disponíveis:"
            i=1
            declare -a cluster_array
            
            for cluster in $clusters; do
                cluster_name=$(echo "$cluster" | awk -F'/' '{print $2}')
                echo "[$i] $cluster_name"
                cluster_array[$i]=$cluster
                ((i++))
            done
            
            echo "Selecione o número do cluster:"
            read -r cluster_idx
            
            if ! [[ "$cluster_idx" =~ ^[0-9]+$ ]] || [ "$cluster_idx" -lt 1 ] || [ "$cluster_idx" -gt $((i-1)) ]; then
                echo "Seleção inválida."
                return 1
            fi
            
            selected_cluster=${cluster_array[$cluster_idx]}
            cluster_name=$(echo "$selected_cluster" | awk -F'/' '{print $2}')
            
            echo "Listando serviços do cluster $cluster_name..."
            aws ecs list-services --profile "$profile_name" --cluster "$selected_cluster" --query 'serviceArns[]' --output table
            ;;
        3)
            echo "Obtendo lista de clusters ECS..."
            clusters=$(aws ecs list-clusters --profile "$profile_name" --query 'clusterArns[]' --output text)
            
            if [ -z "$clusters" ]; then
                echo "Nenhum cluster ECS encontrado."
                return 1
            fi
            
            echo "Clusters ECS disponíveis:"
            i=1
            declare -a cluster_array
            
            for cluster in $clusters; do
                cluster_name=$(echo "$cluster" | awk -F'/' '{print $2}')
                echo "[$i] $cluster_name"
                cluster_array[$i]=$cluster
                ((i++))
            done
            
            echo "Selecione o número do cluster:"
            read -r cluster_idx
            
            if ! [[ "$cluster_idx" =~ ^[0-9]+$ ]] || [ "$cluster_idx" -lt 1 ] || [ "$cluster_idx" -gt $((i-1)) ]; then
                echo "Seleção inválida."
                return 1
            fi
            
            selected_cluster=${cluster_array[$cluster_idx]}
            cluster_name=$(echo "$selected_cluster" | awk -F'/' '{print $2}')
            
            echo "Obtendo lista de serviços do cluster $cluster_name..."
            services=$(aws ecs list-services --profile "$profile_name" --cluster "$selected_cluster" --query 'serviceArns[]' --output text)
            
            if [ -z "$services" ]; then
                echo "Nenhum serviço encontrado no cluster."
                return 1
            fi
            
            echo "Serviços ECS disponíveis:"
            j=1
            declare -a service_array
            
            for service in $services; do
                service_name=$(echo "$service" | awk -F'/' '{print $3}')
                echo "[$j] $service_name"
                service_array[$j]=$service
                ((j++))
            done
            
            echo "Selecione o número do serviço:"
            read -r service_idx
            
            if ! [[ "$service_idx" =~ ^[0-9]+$ ]] || [ "$service_idx" -lt 1 ] || [ "$service_idx" -gt $((j-1)) ]; then
                echo "Seleção inválida."
                return 1
            fi
            
            selected_service=${service_array[$service_idx]}
            service_name=$(echo "$selected_service" | awk -F'/' '{print $3}')
            
            echo "Descrevendo serviço $service_name..."
            aws ecs describe-services --profile "$profile_name" --cluster "$selected_cluster" --services "$service_name" --query 'services[*].[serviceName,status,desiredCount,runningCount,pendingCount,launchType]' --output table
            ;;
        4)
            echo "Obtendo lista de clusters ECS..."
            clusters=$(aws ecs list-clusters --profile "$profile_name" --query 'clusterArns[]' --output text)
            
            if [ -z "$clusters" ]; then
                echo "Nenhum cluster ECS encontrado."
                return 1
            fi
            
            echo "Clusters ECS disponíveis:"
            i=1
            declare -a cluster_array
            
            for cluster in $clusters; do
                cluster_name=$(echo "$cluster" | awk -F'/' '{print $2}')
                echo "[$i] $cluster_name"
                cluster_array[$i]=$cluster
                ((i++))
            done
            
            echo "Selecione o número do cluster:"
            read -r cluster_idx
            
            if ! [[ "$cluster_idx" =~ ^[0-9]+$ ]] || [ "$cluster_idx" -lt 1 ] || [ "$cluster_idx" -gt $((i-1)) ]; then
                echo "Seleção inválida."
                return 1
            fi
            
            selected_cluster=${cluster_array[$cluster_idx]}
            cluster_name=$(echo "$selected_cluster" | awk -F'/' '{print $2}')
            
            echo "Obtendo lista de serviços do cluster $cluster_name..."
            services=$(aws ecs list-services --profile "$profile_name" --cluster "$selected_cluster" --query 'serviceArns[]' --output text)
            
            if [ -z "$services" ]; then
                echo "Nenhum serviço encontrado no cluster."
                return 1
            fi
            
            echo "Serviços ECS disponíveis:"
            j=1
            declare -a service_array
            
            for service in $services; do
                service_name=$(echo "$service" | awk -F'/' '{print $3}')
                echo "[$j] $service_name"
                service_array[$j]=$service
                ((j++))
            done
            
            echo "Selecione o número do serviço:"
            read -r service_idx
            
            if ! [[ "$service_idx" =~ ^[0-9]+$ ]] || [ "$service_idx" -lt 1 ] || [ "$service_idx" -gt $((j-1)) ]; then
                echo "Seleção inválida."
                return 1
            fi
            
            selected_service=${service_array[$service_idx]}
            service_name=$(echo "$selected_service" | awk -F'/' '{print $3}')
            
            echo "Listando tarefas do serviço $service_name..."
            aws ecs list-tasks --profile "$profile_name" --cluster "$selected_cluster" --service-name "$service_name" --query 'taskArns[]' --output table
            ;;
        5)
            echo "Obtendo lista de clusters ECS..."
            clusters=$(aws ecs list-clusters --profile "$profile_name" --query 'clusterArns[]' --output text)
            
            if [ -z "$clusters" ]; then
                echo "Nenhum cluster ECS encontrado."
                return 1
            fi
            
            echo "Clusters ECS disponíveis:"
            i=1
            declare -a cluster_array
            
            for cluster in $clusters; do
                cluster_name=$(echo "$cluster" | awk -F'/' '{print $2}')
                echo "[$i] $cluster_name"
                cluster_array[$i]=$cluster
                ((i++))
            done
            
            echo "Selecione o número do cluster:"
            read -r cluster_idx
            
            if ! [[ "$cluster_idx" =~ ^[0-9]+$ ]] || [ "$cluster_idx" -lt 1 ] || [ "$cluster_idx" -gt $((i-1)) ]; then
                echo "Seleção inválida."
                return 1
            fi
            
            selected_cluster=${cluster_array[$cluster_idx]}
            cluster_name=$(echo "$selected_cluster" | awk -F'/' '{print $2}')
            
            echo "Obtendo lista de serviços do cluster $cluster_name..."
            services=$(aws ecs list-services --profile "$profile_name" --cluster "$selected_cluster" --query 'serviceArns[]' --output text)
            
            if [ -z "$services" ]; then
                echo "Nenhum serviço encontrado no cluster."
                return 1
            fi
            
            echo "Serviços ECS disponíveis:"
            j=1
            declare -a service_array
            
            for service in $services; do
                service_name=$(echo "$service" | awk -F'/' '{print $3}')
                echo "[$j] $service_name"
                service_array[$j]=$service
                ((j++))
            done
            
            echo "Selecione o número do serviço:"
            read -r service_idx
            
            if ! [[ "$service_idx" =~ ^[0-9]+$ ]] || [ "$service_idx" -lt 1 ] || [ "$service_idx" -gt $((j-1)) ]; then
                echo "Seleção inválida."
                return 1
            fi
            
            selected_service=${service_array[$service_idx]}
            service_name=$(echo "$selected_service" | awk -F'/' '{print $3}')
            
            echo "Informe o número desejado de tarefas para o serviço $service_name:"
            read -r desired_count
            
            echo "Atualizando serviço $service_name para $desired_count tarefas..."
            aws ecs update-service --profile "$profile_name" --cluster "$selected_cluster" --service "$service_name" --desired-count "$desired_count"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Serviço atualizado com sucesso."
                echo "Serviço atualizado com sucesso."
            else
                log "ERROR" "Erro ao atualizar serviço."
                echo "Erro ao atualizar serviço. Verifique o arquivo de log para mais detalhes."
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

# Função para gerenciar imagens ECR
manage_ecr_images() {
    log "INFO" "Iniciando gerenciamento de imagens ECR"
    echo "Gerenciando imagens ECR..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_name
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_name" &> /dev/null; then
        log "ERROR" "Perfil '$profile_name' não encontrado."
        echo "Perfil '$profile_name' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    echo "Escolha a operação:"
    echo "[1] Listar repositórios ECR"
    echo "[2] Listar imagens de um repositório"
    echo "[3] Excluir imagens antigas"
    echo "[4] Autenticar Docker com ECR"
    read -r operation
    
    case $operation in
        1)
            echo "Listando repositórios ECR..."
            aws ecr describe-repositories --profile "$profile_name" --query 'repositories[*].[repositoryName,repositoryUri,createdAt]' --output table
            ;;
        2)
            echo "Informe o nome do repositório:"
            read -r repo_name
            
            echo "Listando imagens do repositório $repo_name..."
            aws ecr list-images --profile "$profile_name" --repository-name "$repo_name" --query 'imageIds[*].[imageTag,imageDigest]' --output table
            ;;
        3)
            echo "Informe o nome do repositório:"
            read -r repo_name
            
            echo "Informe o número de imagens mais recentes a manter:"
            read -r keep_count
            
            echo "Listando imagens do repositório $repo_name..."
            images=$(aws ecr describe-images --profile "$profile_name" --repository-name "$repo_name" --query 'sort_by(imageDetails,& imagePushedAt)[*].[imageDigest,imageTags[0],imagePushedAt]' --output text)
            
            # Contar o número total de imagens
            total_images=$(echo "$images" | wc -l)
            
            # Calcular o número de imagens a excluir
            delete_count=$((total_images - keep_count))
            
            if [ $delete_count -le 0 ]; then
                echo "Não há imagens suficientes para excluir. Mantendo todas as $total_images imagens."
            else
                echo "Excluindo $delete_count imagens mais antigas, mantendo as $keep_count mais recentes..."
                
                # Obter as imagens mais antigas para excluir
                images_to_delete=$(echo "$images" | head -n $delete_count | awk '{print $1}')
                
                # Criar arquivo temporário com a lista de imagens a excluir
                echo '{"imageIds":[' > /tmp/images_to_delete.json
                first=true
                for digest in $images_to_delete; do
                    if [ "$first" = true ]; then
                        first=false
                    else
                        echo ',' >> /tmp/images_to_delete.json
                    fi
                    echo '{"imageDigest":"'"$digest"'"}' >> /tmp/images_to_delete.json
                done
                echo ']}' >> /tmp/images_to_delete.json
                
                # Excluir imagens
                aws ecr batch-delete-image --profile "$profile_name" --repository-name "$repo_name" --cli-input-json file:///tmp/images_to_delete.json
                
                if [ $? -eq 0 ]; then
                    log "SUCCESS" "Imagens excluídas com sucesso."
                    echo "Imagens excluídas com sucesso."
                else
                    log "ERROR" "Erro ao excluir imagens."
                    echo "Erro ao excluir imagens. Verifique o arquivo de log para mais detalhes."
                fi
                
                # Remover arquivo temporário
                rm -f /tmp/images_to_delete.json
            fi
            ;;
        4)
            echo "Autenticando Docker com ECR..."
            
            # Obter região da configuração do perfil
            region=$(aws configure get region --profile "$profile_name")
            
            # Obter ID da conta
            account_id=$(aws sts get-caller-identity --profile "$profile_name" --query 'Account' --output text)
            
            # Executar comando de autenticação
            aws ecr get-login-password --profile "$profile_name" | docker login --username AWS --password-stdin "$account_id.dkr.ecr.$region.amazonaws.com"
            
            if [ $? -eq 0 ]; then
                log "SUCCESS" "Docker autenticado com ECR com sucesso."
                echo "Docker autenticado com ECR com sucesso."
            else
                log "ERROR" "Erro ao autenticar Docker com ECR."
                echo "Erro ao autenticar Docker com ECR. Verifique o arquivo de log para mais detalhes."
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

# Função principal do módulo de containers
containers_menu() {
    log "INFO" "Iniciando menu de containers"
    echo "Menu de Gerenciamento de Containers e Kubernetes"
    
    echo "Escolha a operação:"
    echo "[1] Gerenciar clusters EKS"
    echo "[2] Gerenciar serviços ECS"
    echo "[3] Gerenciar imagens ECR"
    echo "[4] Voltar"
    read -r option
    
    case $option in
        1)
            manage_eks_clusters
            ;;
        2)
            manage_ecs_services
            ;;
        3)
            manage_ecr_images
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
