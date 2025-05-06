#!/bin/bash
# prowler.sh - Módulo para execução do Prowler
# Parte do Arch CLI

# Função para executar o Prowler
run_prowler() {
    log "INFO" "Iniciando execução do Prowler"
    echo "Iniciando o ${GREEN}Prowler${NC}..."
    
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read -r profile_for_prowler
    
    # Verificar se o perfil existe
    if ! aws configure list --profile "$profile_for_prowler" &> /dev/null; then
        log "ERROR" "Perfil '$profile_for_prowler' não encontrado."
        echo "Perfil '$profile_for_prowler' não encontrado. Verifique se o perfil existe."
        return 1
    fi
    
    # Criar diretório para relatórios
    local output_dir="./prowler_reports/$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p "$output_dir"
    
    echo "Executando Prowler com o perfil '$profile_for_prowler'..."
    echo "Os relatórios serão salvos em: $output_dir"
    
    # Mostrar barra de progresso
    echo "Executando Prowler (isso pode levar alguns minutos)..."
    echo -ne '[                    ] (0%)\r'
    
    # Aumentar limite de arquivos abertos e executar o Prowler
    log "INFO" "Executando: prowler aws --profile $profile_for_prowler -M csv html -o $output_dir"
    
    # Executar Prowler em segundo plano para poder mostrar progresso
    (ulimit -n 4096 && prowler aws --profile "$profile_for_prowler" -M csv html -o "$output_dir") &
    prowler_pid=$!
    
    # Mostrar barra de progresso enquanto o Prowler está em execução
    i=0
    while kill -0 $prowler_pid 2>/dev/null; do
        i=$((i+1))
        if [ $i -gt 20 ]; then i=0; fi
        
        # Criar barra de progresso
        bar="["
        for ((j=0; j<i; j++)); do
            bar="${bar}#"
        done
        for ((j=i; j<20; j++)); do
            bar="${bar} "
        done
        bar="${bar}]"
        
        percent=$((i*5))
        echo -ne "${bar} (${percent}%)\r"
        sleep 1
    done
    
    # Verificar se o Prowler foi concluído com sucesso
    wait $prowler_pid
    prowler_exit_code=$?
    
    echo -ne '[####################] (100%)\r'
    echo -e "\n"
    
    if [ $prowler_exit_code -eq 0 ]; then
        log "SUCCESS" "Prowler executado com sucesso. Relatórios disponíveis em: $output_dir"
        echo "Prowler executado com sucesso. Relatórios disponíveis em: $output_dir"
        
        # Mostrar resumo dos resultados
        echo "Resumo dos resultados:"
        if [ -f "$output_dir/prowler-output.csv" ]; then
            echo "Total de verificações: $(grep -v "^#" "$output_dir/prowler-output.csv" | wc -l)"
            echo "Falhas: $(grep -v "^#" "$output_dir/prowler-output.csv" | grep -i "fail" | wc -l)"
            echo "Aprovados: $(grep -v "^#" "$output_dir/prowler-output.csv" | grep -i "pass" | wc -l)"
        fi
        
        # Perguntar se deseja abrir o relatório HTML
        echo "Deseja abrir o relatório HTML? [1] sim / [2] não"
        read -r open_report
        
        if [ "$open_report" -eq 1 ]; then
            if [ -f "$output_dir/prowler-output.html" ]; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    open "$output_dir/prowler-output.html"
                elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                    xdg-open "$output_dir/prowler-output.html"
                else
                    echo "Não foi possível abrir o relatório automaticamente."
                    echo "O relatório está disponível em: $output_dir/prowler-output.html"
                fi
            else
                echo "Relatório HTML não encontrado."
            fi
        fi
    else
        log "ERROR" "Erro ao executar o Prowler."
        echo "Erro ao executar o Prowler. Verifique o arquivo de log para mais detalhes."
    fi
}
