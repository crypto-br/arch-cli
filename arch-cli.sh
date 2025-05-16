#!/bin/bash
# arch-cli.sh - Ferramenta para gerenciamento de contas AWS
# Versão 3.2.0
# Autor: Luiz Machado (@cryptobr)

# Carregar módulos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/modules/utils.sh"
source "$SCRIPT_DIR/modules/dependencies.sh"
source "$SCRIPT_DIR/modules/aws_profile.sh"
source "$SCRIPT_DIR/modules/prowler.sh"
source "$SCRIPT_DIR/modules/support_user.sh"
source "$SCRIPT_DIR/modules/aws_resources.sh"

# Carregar módulos adicionais para SRE, Infra e DevOps
source "$SCRIPT_DIR/modules/monitoring.sh"
source "$SCRIPT_DIR/modules/cost_optimization.sh"
source "$SCRIPT_DIR/modules/security.sh"
source "$SCRIPT_DIR/modules/automation.sh"
source "$SCRIPT_DIR/modules/containers.sh"
source "$SCRIPT_DIR/modules/database.sh"
source "$SCRIPT_DIR/modules/finops.sh"

# Configuração inicial
setup_config_dir
show_header

# Função para exibir menu interativo
show_interactive_menu() {
    clear
    show_header
    
    local active_profile=$(get_active_profile)
    echo -e "${BLUE}Perfil AWS ativo:${NC} $active_profile"
    echo
    
    echo "Menu Principal:"
    echo "1. Verificar dependências"
    echo "2. Configurar perfil AWS"
    echo "3. Executar Prowler"
    echo "4. Criar usuário de suporte"
    echo "5. Listar recursos AWS"
    echo "6. Monitoramento e Observabilidade"
    echo "7. Otimização de Custos"
    echo "8. Segurança e Compliance"
    echo "9. Automação de Rotinas"
    echo "10. Gerenciamento de Containers"
    echo "11. Gerenciamento de Banco de Dados"
    echo "12. AWS FinOps Dashboard"
    echo "13. Trocar perfil AWS ativo"
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
            echo "Informe o Account ID:"
            read -r account_id
            create_support_user "$account_id"
            ;;
        5)
            list_aws_resources
            ;;
        6)
            monitoring_menu
            ;;
        7)
            cost_optimization_menu
            ;;
        8)
            security_menu
            ;;
        9)
            automation_menu
            ;;
        10)
            containers_menu
            ;;
        11)
            database_menu
            ;;
        12)
            finops_menu
            ;;
        13)
            switch_profile_menu
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
        --finops|-finops)
            finops_menu
            ;;
        --profile|-profile)
            if [ -z "$2" ]; then
                switch_profile_menu
            else
                # Verificar se o perfil existe
                if aws configure list --profile "$2" &> /dev/null; then
                    set_active_profile "$2"
                else
                    log "ERROR" "Perfil '$2' não encontrado."
                    echo "Perfil '$2' não encontrado. Verifique se o perfil existe."
                    exit 1
                fi
            fi
            ;;
        --help|-help|*)
            show_help
            ;;
    esac
}

# Executar função principal
main "$@"
