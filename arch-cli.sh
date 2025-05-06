#!/bin/bash
# arch-cli.sh - Ferramenta para gerenciamento de contas AWS
# Versão 3.0.0
# Autor: Luiz Machado (@cryptobr)

# Carregar módulos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/modules/utils.sh"
source "$SCRIPT_DIR/modules/dependencies.sh"
source "$SCRIPT_DIR/modules/aws_profile.sh"
source "$SCRIPT_DIR/modules/prowler.sh"
source "$SCRIPT_DIR/modules/arch_prune.sh"
source "$SCRIPT_DIR/modules/support_user.sh"
source "$SCRIPT_DIR/modules/aws_resources.sh"

# Carregar módulos adicionais para SRE, Infra e DevOps
source "$SCRIPT_DIR/modules/monitoring.sh"
source "$SCRIPT_DIR/modules/cost_optimization.sh"
source "$SCRIPT_DIR/modules/security.sh"
source "$SCRIPT_DIR/modules/automation.sh"
source "$SCRIPT_DIR/modules/containers.sh"
source "$SCRIPT_DIR/modules/database.sh"

# Configuração inicial
setup_config_dir
show_header

# Função para exibir menu interativo
show_interactive_menu() {
    clear
    show_header
    
    echo "Menu Principal:"
    echo "1. Verificar dependências"
    echo "2. Configurar perfil AWS"
    echo "3. Executar Prowler"
    echo "4. Executar Arch Prune"
    echo "5. Criar usuário de suporte"
    echo "6. Listar recursos AWS"
    echo "7. Monitoramento e Observabilidade"
    echo "8. Otimização de Custos"
    echo "9. Segurança e Compliance"
    echo "10. Automação de Rotinas"
    echo "11. Gerenciamento de Containers"
    echo "12. Gerenciamento de Banco de Dados"
    echo "0. Sair"
    
    echo -n "Escolha uma opção: "
    read -r option
    
    case $option in
        1)
            check_dependencies
            ;;
        2)
            configure_profile
            ;;
        3)
            run_prowler
            ;;
        4)
            echo "Informe o status para o Arch Prune (forCleanUp, available, maintenance, underAnalysis):"
            read -r status
            if [[ "$status" =~ ^(forCleanUp|available|maintenance|underAnalysis)$ ]]; then
                run_arch_prune "$status"
            else
                log "ERROR" "Status inválido: $status"
                echo "[ERRO] - Status inválido: $status"
                echo "Status válidos: forCleanUp, available, maintenance, underAnalysis"
            fi
            ;;
        5)
            echo "Informe o Account ID:"
            read -r account_id
            create_support_user "$account_id"
            ;;
        6)
            list_aws_resources
            ;;
        7)
            monitoring_menu
            ;;
        8)
            cost_optimization_menu
            ;;
        9)
            security_menu
            ;;
        10)
            automation_menu
            ;;
        11)
            containers_menu
            ;;
        12)
            database_menu
            ;;
        0)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida."
            ;;
    esac
    
    echo
    echo "Pressione Enter para continuar..."
    read -r
    show_interactive_menu
}

# Função principal
main() {
    # Verificar se não há argumentos - mostrar menu interativo
    if [ $# -eq 0 ]; then
        show_interactive_menu
        return
    fi
    
    # Processar argumentos de linha de comando
    case "$1" in
        --deps|-deps)
            check_dependencies
            ;;
        --ap|-ap)
            if [ -z "$2" ]; then
                log "ERROR" "Status não informado."
                echo "[ERRO] - Status da conta não informado"
                echo "Informe o tipo de status que deseja executar: forCleanUp, available, maintenance, underAnalysis"
                echo "ex: --ap forCleanUp"
                exit 1
            elif [[ "$2" =~ ^(forCleanUp|available|maintenance|underAnalysis)$ ]]; then
                run_arch_prune "$2"
            else
                log "ERROR" "Status inválido: $2"
                echo "[ERRO] - Status inválido: $2"
                echo "Status válidos: forCleanUp, available, maintenance, underAnalysis"
                exit 1
            fi
            ;;
        --prowler|-prowler)
            run_prowler
            ;;
        --np|-np)
            configure_profile
            ;;
        --lsu|-lsu)
            if [ "$2" = "--acc" ] || [ "$2" = "-acc" ]; then
                if [ -z "$3" ]; then
                    log "ERROR" "Account ID não informado."
                    echo "[ERRO] - Account ID não informado"
                    exit 1
                else
                    create_support_user "$3"
                fi
            else
                log "ERROR" "Parâmetro --acc não informado."
                echo "[ERRO] - Parâmetro --acc não informado"
                echo "Uso correto: --lsu --acc <Account ID>"
                exit 1
            fi
            ;;
        --list|-list)
            list_aws_resources
            ;;
        --monitor|-monitor)
            monitoring_menu
            ;;
        --cost|-cost)
            cost_optimization_menu
            ;;
        --security|-security)
            security_menu
            ;;
        --automation|-automation)
            automation_menu
            ;;
        --containers|-containers)
            containers_menu
            ;;
        --database|-database)
            database_menu
            ;;
        --help|-help|*)
            show_help
            ;;
    esac
}

# Executar função principal
main "$@"
