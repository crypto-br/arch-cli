#!/usr/bin/env python3
"""
Módulo principal do Arch CLI que serve como ponto de entrada para o comando arch-cli
"""

import os
import sys
import subprocess
import click
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from .dependencies import check_dependencies as check_deps_py

console = Console()

# Caminho para o diretório do script bash
SCRIPT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASH_SCRIPT = os.path.join(SCRIPT_DIR, "arch-cli.sh")

def show_header():
    """Exibe o cabeçalho do Arch CLI"""
    header = Text()
    header.append("\n")
    header.append("                _                _ _ \n", style="green")
    header.append("  __ _ _ __ ___| |__         ___| (_)\n", style="green")
    header.append(" / _` | '__/ __| '_ \\ _____ / __| | |\n", style="green")
    header.append("| (_| | | | (__| | | |_____| (__| | |\n", style="green")
    header.append(" \\__,_|_|  \\___|_| |_|      \\___|_|_| v3.0\n", style="green")
    header.append("\n")
    header.append("Created by: Luiz Machado (@cryptobr)\n")
    
    console.print(Panel(header, border_style="blue"))

@click.group(invoke_without_command=True)
@click.pass_context
@click.version_option(version="3.0.0")
def main(ctx):
    """Arch CLI - Ferramenta para gerenciamento de times de Arquitetura, SRE e DevOps com foco em AWS"""
    if ctx.invoked_subcommand is None:
        show_header()
        # Executar o script bash sem argumentos (menu interativo)
        subprocess.run(["/bin/bash", BASH_SCRIPT])

@main.command()
@click.option("--python", is_flag=True, help="Usar a implementação Python para verificar dependências")
def deps(python):
    """Verifica dependências necessárias (AWS-CLI, Python3, Prowler)"""
    if python:
        # Usar a implementação Python
        check_deps_py()
    else:
        # Usar a implementação Bash
        subprocess.run(["/bin/bash", BASH_SCRIPT, "--deps"])

@main.command()
@click.argument("status", type=click.Choice(["forCleanUp", "available", "maintenance", "underAnalysis"]))
def ap(status):
    """Inicia o Arch Prune com o status especificado"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--ap", status])

@main.command()
def prowler():
    """Inicia o Prowler para auditoria de segurança"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--prowler"])

@main.command()
def np():
    """Configura um novo perfil no AWS CLI"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--np"])

@main.command()
@click.option("--acc", required=True, help="Account ID para criar o usuário de suporte")
def lsu(acc):
    """Cria um usuário administrativo de suporte na conta AWS"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--lsu", "--acc", acc])

@main.command()
def list():
    """Lista recursos AWS (EC2, S3, RDS, Lambda, IAM, CloudFormation)"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--list"])

@main.command()
def monitor():
    """Acessa o menu de monitoramento e observabilidade"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--monitor"])

@main.command()
def cost():
    """Acessa o menu de otimização de custos"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--cost"])

@main.command()
def security():
    """Acessa o menu de segurança e compliance"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--security"])

@main.command()
def automation():
    """Acessa o menu de automação de rotinas"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--automation"])

@main.command()
def containers():
    """Acessa o menu de gerenciamento de containers"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--containers"])

@main.command()
def database():
    """Acessa o menu de gerenciamento de banco de dados"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--database"])

@main.command()
def finops():
    """Acessa o menu do AWS FinOps Dashboard"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--finops"])

if __name__ == "__main__":
    main()
