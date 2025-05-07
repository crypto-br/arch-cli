"""
Módulo para verificação e instalação de dependências
"""

import os
import sys
import subprocess
import platform
from rich.console import Console
from rich.prompt import Confirm
from .utils import detect_os, log, run_command

console = Console()

def install_aws_cli_v2(os_type):
    """Instala o AWS CLI v2 no sistema"""
    if os_type in ["debian", "ubuntu"]:
        log("INFO", "Instalando dependências para AWS CLI v2...")
        run_command(["sudo", "apt-get", "update"])
        run_command(["sudo", "apt-get", "install", "-y", "unzip", "curl"])
        
        log("INFO", "Baixando AWS CLI v2...")
        run_command(["curl", "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip", "-o", "awscliv2.zip"])
        run_command(["unzip", "-q", "awscliv2.zip"])
        
        log("INFO", "Instalando AWS CLI v2...")
        run_command(["sudo", "./aws/install"])
        
        log("INFO", "Limpando arquivos temporários...")
        run_command(["rm", "-rf", "aws", "awscliv2.zip"])
        
    elif os_type in ["redhat", "amazon-linux"]:
        log("INFO", "Instalando dependências para AWS CLI v2...")
        run_command(["sudo", "yum", "install", "-y", "unzip", "curl"])
        
        log("INFO", "Baixando AWS CLI v2...")
        run_command(["curl", "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip", "-o", "awscliv2.zip"])
        run_command(["unzip", "-q", "awscliv2.zip"])
        
        log("INFO", "Instalando AWS CLI v2...")
        run_command(["sudo", "./aws/install"])
        
        log("INFO", "Limpando arquivos temporários...")
        run_command(["rm", "-rf", "aws", "awscliv2.zip"])
        
    elif os_type == "macos":
        log("INFO", "Instalando AWS CLI v2 via brew...")
        run_command(["brew", "install", "awscli"])
        
    else:
        log("ERROR", "Sistema operacional não suportado para instalação automática do AWS CLI v2.")
        console.print("[red]Por favor, instale o AWS CLI v2 manualmente: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html[/red]")
        return False
        
    return True

def check_dependencies():
    """Verifica e instala as dependências necessárias"""
    os_type = detect_os()
    log("INFO", f"Verificando dependências no sistema: {os_type}")
    
    # Verificar AWS CLI
    aws_installed = False
    try:
        result = subprocess.run(["aws", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            aws_version = result.stdout.strip()
            log("SUCCESS", f"AWS CLI já está instalado: {aws_version}")
            console.print(f"[green]AWS CLI já está instalado:[/green] {aws_version}")
            aws_installed = True
    except:
        pass
    
    if not aws_installed:
        log("WARNING", "AWS CLI não está instalado.")
        console.print("[yellow]AWS CLI não está instalado.[/yellow]")
        
        if Confirm.ask("Deseja instalar AWS CLI v2?"):
            if install_aws_cli_v2(os_type):
                log("SUCCESS", "AWS CLI v2 instalado com sucesso.")
                console.print("[green]AWS CLI v2 instalado com sucesso.[/green]")
            else:
                log("ERROR", "Falha ao instalar AWS CLI v2.")
                console.print("[red]Falha ao instalar AWS CLI v2. Tente instalar manualmente.[/red]")
                return False
        else:
            log("ERROR", "AWS CLI é necessário para continuar.")
            console.print("[red]AWS CLI é necessário para continuar.[/red]")
            return False
    
    # Verificar Python3
    python_installed = False
    try:
        result = subprocess.run(["python3", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            python_version = result.stdout.strip()
            log("SUCCESS", f"Python3 já está instalado: {python_version}")
            console.print(f"[green]Python3 já está instalado:[/green] {python_version}")
            python_installed = True
    except:
        pass
    
    if not python_installed:
        log("WARNING", "Python3 não está instalado.")
        console.print("[yellow]Python3 não está instalado.[/yellow]")
        
        if Confirm.ask("Deseja instalar Python3?"):
            if os_type in ["debian", "ubuntu"]:
                run_command(["sudo", "apt-get", "update"])
                run_command(["sudo", "apt-get", "install", "-y", "python3", "python3-pip"])
            elif os_type in ["redhat", "amazon-linux"]:
                run_command(["sudo", "yum", "install", "-y", "python3", "python3-pip"])
            elif os_type == "macos":
                run_command(["brew", "install", "python3"])
            else:
                log("ERROR", "Sistema operacional não suportado para instalação automática.")
                console.print("[red]Por favor, instale o Python3 manualmente.[/red]")
                return False
                
            log("SUCCESS", "Python3 instalado com sucesso.")
            console.print("[green]Python3 instalado com sucesso.[/green]")
        else:
            log("ERROR", "Python3 é necessário para continuar.")
            console.print("[red]Python3 é necessário para continuar.[/red]")
            return False
    
    # Verificar pip3
    pip_installed = False
    try:
        result = subprocess.run(["pip3", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            pip_version = result.stdout.strip()
            log("SUCCESS", f"pip3 já está instalado: {pip_version}")
            console.print(f"[green]pip3 já está instalado:[/green] {pip_version}")
            pip_installed = True
    except:
        pass
    
    if not pip_installed:
        log("WARNING", "pip3 não está instalado.")
        console.print("[yellow]pip3 não está instalado.[/yellow]")
        
        if Confirm.ask("Deseja instalar pip3?"):
            if os_type in ["debian", "ubuntu"]:
                run_command(["sudo", "apt-get", "update"])
                run_command(["sudo", "apt-get", "install", "-y", "python3-pip"])
            elif os_type in ["redhat", "amazon-linux"]:
                run_command(["sudo", "yum", "install", "-y", "python3-pip"])
            elif os_type == "macos":
                run_command(["brew", "install", "python3"])
            else:
                log("ERROR", "Sistema operacional não suportado para instalação automática.")
                console.print("[red]Por favor, instale o pip3 manualmente.[/red]")
                return False
                
            log("SUCCESS", "pip3 instalado com sucesso.")
            console.print("[green]pip3 instalado com sucesso.[/green]")
        else:
            log("ERROR", "pip3 é necessário para continuar.")
            console.print("[red]pip3 é necessário para continuar.[/red]")
            return False
    
    # Verificar Prowler
    prowler_installed = False
    try:
        result = subprocess.run(["prowler", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            prowler_version = result.stdout.strip()
            log("SUCCESS", f"Prowler já está instalado: {prowler_version}")
            console.print(f"[green]Prowler já está instalado:[/green] {prowler_version}")
            prowler_installed = True
    except:
        pass
    
    if not prowler_installed:
        log("WARNING", "Prowler não está instalado.")
        console.print("[yellow]Prowler não está instalado.[/yellow]")
        
        if Confirm.ask("Deseja instalar Prowler?"):
            success, output = run_command(["pip3", "install", "prowler"])
            if success:
                try:
                    result = subprocess.run(["prowler", "--version"], capture_output=True, text=True)
                    prowler_version = result.stdout.strip() if result.returncode == 0 else "Versão desconhecida"
                    log("SUCCESS", f"Prowler instalado com sucesso: {prowler_version}")
                    console.print(f"[green]Prowler instalado com sucesso:[/green] {prowler_version}")
                except:
                    log("SUCCESS", "Prowler instalado com sucesso.")
                    console.print("[green]Prowler instalado com sucesso.[/green]")
            else:
                log("ERROR", "Falha ao instalar o Prowler.")
                console.print("[red]Falha ao instalar o Prowler. Tente instalar manualmente: pip3 install prowler[/red]")
                return False
        else:
            log("ERROR", "Prowler é necessário para continuar.")
            console.print("[red]Prowler é necessário para continuar.[/red]")
            return False
    
    # Verificar jq
    jq_installed = False
    try:
        result = subprocess.run(["jq", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            jq_version = result.stdout.strip()
            log("SUCCESS", f"jq já está instalado: {jq_version}")
            console.print(f"[green]jq já está instalado:[/green] {jq_version}")
            jq_installed = True
    except:
        pass
    
    if not jq_installed:
        log("WARNING", "jq não está instalado (útil para processamento de JSON).")
        console.print("[yellow]jq não está instalado (útil para processamento de JSON).[/yellow]")
        
        if Confirm.ask("Deseja instalar jq?"):
            if os_type in ["debian", "ubuntu"]:
                run_command(["sudo", "apt-get", "update"])
                run_command(["sudo", "apt-get", "install", "-y", "jq"])
            elif os_type in ["redhat", "amazon-linux"]:
                run_command(["sudo", "yum", "install", "-y", "jq"])
            elif os_type == "macos":
                run_command(["brew", "install", "jq"])
            else:
                log("ERROR", "Sistema operacional não suportado para instalação automática.")
                console.print("[red]Por favor, instale o jq manualmente.[/red]")
            
            try:
                result = subprocess.run(["jq", "--version"], capture_output=True, text=True)
                if result.returncode == 0:
                    jq_version = result.stdout.strip()
                    log("SUCCESS", f"jq instalado com sucesso: {jq_version}")
                    console.print(f"[green]jq instalado com sucesso:[/green] {jq_version}")
                else:
                    log("WARNING", "Falha ao instalar jq, mas o script pode continuar sem ele.")
                    console.print("[yellow]Falha ao instalar jq, mas o script pode continuar sem ele.[/yellow]")
            except:
                log("WARNING", "Falha ao instalar jq, mas o script pode continuar sem ele.")
                console.print("[yellow]Falha ao instalar jq, mas o script pode continuar sem ele.[/yellow]")
        else:
            log("WARNING", "Continuando sem jq. Algumas funcionalidades podem ser limitadas.")
            console.print("[yellow]Continuando sem jq. Algumas funcionalidades podem ser limitadas.[/yellow]")
    
    log("SUCCESS", "Todas as dependências necessárias estão instaladas.")
    console.print("[green]Todas as dependências necessárias estão instaladas.[/green]")
    return True
