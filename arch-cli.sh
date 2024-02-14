#!/bin/bash
# INICIO HEADER
echo  "
######################################################################
\e[1;32m
                _                _ _ 
  __ _ _ __ ___| |__         ___| (_)
 / _` | '__/ __| '_ \ _____ / __| | |
| (_| | | | (__| | | |_____| (__| | |
 \__,_|_|  \___|_| |_|      \___|_|_| v1.0\e[0m
" 
echo "Created by: Luiz Machado (@cryptobr)"
echo "######################################################################"
echo ""
# FIM HEADER

######################################################################################### INICIO FUNÇÕES ############################################################################################
# Verifica dependências necessárias
verificar_deps() {
    # AWS-CLI
    if ! type aws > /dev/null 2>&1; then
        echo "AWS CLI não está instalado."
        echo "Deseja instalar ? [1] sim / [2] não"
        read install_resp
        if [ $install_resp -eq 1 ]
        then
            sudo apt-get update
            sudo apt-get install -y awscli
            echo "AWS CLI instalado com sucesso."
        elif [ $install_resp -eq 2 ]
        then
            echo "Saindo do script."
            exit 1
        fi
    else
        echo "AWS CLI já está instalado.[\033[0;32m OK \033[0m]"
    fi
    # PYTHON3
    if ! type python3 > /dev/null 2>&1; then
        echo "Python3 não está instalado."
        echo "Deseja instalar ? [1] sim / [2] não"
        read install_resp
        if [ $install_resp -eq 1 ]
        then
            sudo apt-get update
            sudo apt-get install -y python3
            echo "Python3 instalado com sucesso."
        elif [ $install_resp -eq 2 ]
        then
            echo "a Instalação é necessária....."
            exit 1
        fi
    else
        echo "Python3 já está instalado.[\033[0;32m OK \033[0m]"
    fi
    # PROWLER
    if ! type prowler > /dev/null 2>&1; then
        echo "Prowler não está instalado."
        echo "Deseja instalar ? [1] sim / [2] não"
        read install_resp
        if [ $install_resp -eq 1 ]
        then
            sudo apt-get update
            sudo apt-get install -y python3
            echo "Prowler instalado com sucesso."
        elif [ $install_resp -eq 2 ]
        then
            echo "a Instalação é necessária....."
            exit 1
        fi
    else
        echo "Prowler já está instalado.[\033[0;32m OK \033[0m]"
    fi
}

# Configra novo perfil no AWS CLI
configurar_perfil() {
    echo "Configurando novo perfil no AWS CLI..."
    echo "Qual o nome do profile?"
    read profile_name
    echo "Informe a Access Key"
    read access_key
    echo "Informe a Secret Key"
    read secret_key
    echo "Qual a região?"
    read region
    aws configure set aws_access_key_id $access_key --profile $profile_name
    aws configure set aws_secret_access_key $secret_key --profile $profile_name
    aws configure set region $region --profile $profile_name
    #echo -ne '%s\n%s\n%s\n%s\n'  $access_key $secret_key $region $output | aws configure
    exit 1
}

# Cria um usuário na conta de lab
create_suporte_user() {
    echo "Criando usuário de suporte..."
    python3 ../nuke_faster/create_suporte_user_cf.py $1

}

######################################################################################### FIM FUNÇÕES ###############################################################################################

######################################################################################### INICIO PARAMETROS #########################################################################################

# Parametro "--deps ou -deps" entende que o ambiente já está previamente configurado
if [ "$1" = "--deps" ] || [ "$1" = "-deps" ]
then
    echo "Verificando Dependências..."
    sleep 1
    verificar_deps
    exit 1
fi

# Parametro "--nf ou -nf" inica o nuke_faster 
if [ "$1" = "--nf" ] || [ "$1" = "-nf" ]
then
    echo "Iniciando o \e[1;32mNuke Faster\e[0m......"
    sleep 1
    if [ "$2" = "forCleanUp" ] || [ "$2" = "avaliable" ] || [ "$2" = "manutencao" ] || [ "$2" = "underAnalysis" ]
    then
        cd ../nuke_faster/ && ./nuke-faster.sh $2
        exit 1
    else
        echo "[ERRO] - Status da conta não informado
Informe o tipo de status que deseja executar: forCleanUp, avaliable, manutencao, underAnalysis
ex: --nf forCleanUp"
        exit 1
    fi
fi

# Parametro "--prowler ou -prowler" inica o nuke_faster 
if [ "$1" = "--prowler" ] || [ "$1" = "-prowler" ]
then
    echo "Iniciando o \e[1;32mProwler\e[0m......"
    sleep 1
    echo "Informe o profile do AWS-CLI que deseja utilizar:"
    read profile_for_prowler
    echo "Ao final do script o prowler vai criar um diretorio chamado output vai ficar disponivel o .csv e .html do report"
    ulimit -n 4096 && prowler aws --profile $profile_for_prowler -M csv html
    exit 1
fi

# Parametro "--np ou -np" inica a configuração do novo profile no AWS CLI
if [ "$1" = "--np" ] || [ "$1" = "-np" ]
then
    echo "Configurando um novo profile para o AWS-CLI......"
    sleep 1
    configurar_perfil
    exit 1
fi

# Parametro "--lsu ou -lsu" inica a criação de um usuário adminsitrativo de suporte na conta de lab
if [ "$1" = "--lsu" ] || [ "$1" = "-lsu" ]
then
    if [ "$2" = "--acc" ] || [ "$2" = "-acc" ]
    then
        if [ "$3" = "" ]
        then
            echo "[ERRO] - Account ID não informado"
        else
            echo "Configurando um usuário na conta: "$3
            sleep 1
            create_suporte_user $3
            exit 1
        fi
    else
        echo "[ERRO] - Account ID não informado"
        exit 1
    fi
fi

# Parametro "--help ou -help" para mostrar as opções disponiveis
if [ "$1" = "--help" ] || [ "$1" = "-help" ]
then
echo "
Utilização: sh arch-cli.sh [opção]

Opções disponiveis:
    --deps, -deps           Verifica dependencias necessárias (AWS-CLI, Python3, Prowler)
    --nf, -nf               Inicia o arch-prune
    --prowler, -prowler     Inicia o prowler
    --np, -np               Configura um novo perfil no AWS CLI
    --lsu, -lsu             Cria um usuário administrativo de suporte na conta AWS (use com --acc, -acc)
    --acc, -acc             Informa o Account ID (--acc 123456789)
"
fi
######################################################################################### FIM PARAMETROS #########################################################################################
