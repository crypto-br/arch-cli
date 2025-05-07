"""
Módulo para integração com aws-finops-dashboard
"""

import os
import sys
import subprocess
import platform
from rich.console import Console
from rich.prompt import Confirm, Prompt
from .utils import detect_os, log, run_command

console = Console()
REPO_DIR = os.path.expanduser("~/.arch-cli/aws-finops-dashboard")

def check_git():
    """Verifica se o Git está instalado"""
    try:
        result = subprocess.run(["git", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            git_version = result.stdout.strip()
            log("SUCCESS", f"Git já está instalado: {git_version}")
            console.print(f"[green]Git já está instalado:[/green] {git_version}")
            return True
    except:
        pass
    
    log("WARNING", "Git não está instalado.")
    console.print("[yellow]Git não está instalado.[/yellow]")
    
    if Confirm.ask("Deseja instalar Git?"):
        os_type = detect_os()
        if os_type in ["debian", "ubuntu"]:
            run_command(["sudo", "apt-get", "update"])
            run_command(["sudo", "apt-get", "install", "-y", "git"])
        elif os_type in ["redhat", "amazon-linux"]:
            run_command(["sudo", "yum", "install", "-y", "git"])
        elif os_type == "macos":
            run_command(["brew", "install", "git"])
        else:
            log("ERROR", "Sistema operacional não suportado para instalação automática.")
            console.print("[red]Por favor, instale o Git manualmente.[/red]")
            return False
            
        try:
            result = subprocess.run(["git", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                git_version = result.stdout.strip()
                log("SUCCESS", f"Git instalado com sucesso: {git_version}")
                console.print(f"[green]Git instalado com sucesso:[/green] {git_version}")
                return True
        except:
            log("ERROR", "Falha ao instalar Git.")
            console.print("[red]Falha ao instalar Git.[/red]")
            return False
    else:
        log("ERROR", "Git é necessário para continuar.")
        console.print("[red]Git é necessário para continuar.[/red]")
        return False

def check_docker():
    """Verifica se o Docker está instalado"""
    try:
        result = subprocess.run(["docker", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            docker_version = result.stdout.strip()
            log("SUCCESS", f"Docker já está instalado: {docker_version}")
            console.print(f"[green]Docker já está instalado:[/green] {docker_version}")
            return True
    except:
        pass
    
    log("WARNING", "Docker não está instalado.")
    console.print("[yellow]Docker não está instalado.[/yellow]")
    
    if Confirm.ask("Deseja instalar Docker?"):
        os_type = detect_os()
        if os_type in ["debian", "ubuntu"]:
            run_command(["sudo", "apt-get", "update"])
            run_command(["sudo", "apt-get", "install", "-y", "apt-transport-https", "ca-certificates", "curl", "software-properties-common"])
            run_command(["curl", "-fsSL", "https://download.docker.com/linux/ubuntu/gpg", "|", "sudo", "apt-key", "add", "-"], shell=True)
            run_command([f'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'], shell=True)
            run_command(["sudo", "apt-get", "update"])
            run_command(["sudo", "apt-get", "install", "-y", "docker-ce", "docker-ce-cli", "containerd.io"])
            run_command([f"sudo usermod -aG docker {os.getenv('USER')}"], shell=True)
        elif os_type in ["redhat", "amazon-linux"]:
            run_command(["sudo", "yum", "install", "-y", "yum-utils"])
            run_command(["sudo", "yum-config-manager", "--add-repo", "https://download.docker.com/linux/centos/docker-ce.repo"])
            run_command(["sudo", "yum", "install", "-y", "docker-ce", "docker-ce-cli", "containerd.io"])
            run_command(["sudo", "systemctl", "start", "docker"])
            run_command(["sudo", "systemctl", "enable", "docker"])
            run_command([f"sudo usermod -aG docker {os.getenv('USER')}"], shell=True)
        elif os_type == "macos":
            log("INFO", "Para macOS, por favor instale o Docker Desktop manualmente.")
            console.print("[yellow]Por favor, baixe e instale o Docker Desktop de: https://www.docker.com/products/docker-desktop[/yellow]")
            return False
        else:
            log("ERROR", "Sistema operacional não suportado para instalação automática.")
            console.print("[red]Por favor, instale o Docker manualmente.[/red]")
            return False
            
        try:
            result = subprocess.run(["docker", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                docker_version = result.stdout.strip()
                log("SUCCESS", f"Docker instalado com sucesso: {docker_version}")
                console.print(f"[green]Docker instalado com sucesso:[/green] {docker_version}")
                console.print("[yellow]Pode ser necessário reiniciar o terminal ou o sistema.[/yellow]")
                return True
        except:
            log("ERROR", "Falha ao instalar Docker.")
            console.print("[red]Falha ao instalar Docker.[/red]")
            return False
    else:
        log("ERROR", "Docker é necessário para continuar.")
        console.print("[red]Docker é necessário para continuar.[/red]")
        return False

def check_docker_compose():
    """Verifica se o Docker Compose está instalado"""
    try:
        result = subprocess.run(["docker-compose", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            compose_version = result.stdout.strip()
            log("SUCCESS", f"Docker Compose já está instalado: {compose_version}")
            console.print(f"[green]Docker Compose já está instalado:[/green] {compose_version}")
            return True
    except:
        pass
    
    log("WARNING", "Docker Compose não está instalado.")
    console.print("[yellow]Docker Compose não está instalado.[/yellow]")
    
    if Confirm.ask("Deseja instalar Docker Compose?"):
        os_type = detect_os()
        if os_type in ["debian", "ubuntu", "redhat", "amazon-linux"]:
            run_command(['sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'], shell=True)
            run_command(["sudo", "chmod", "+x", "/usr/local/bin/docker-compose"])
        elif os_type == "macos":
            log("INFO", "Para macOS, o Docker Compose já vem com o Docker Desktop.")
            console.print("[yellow]Se você instalou o Docker Desktop, o Docker Compose já deve estar disponível.[/yellow]")
        else:
            log("ERROR", "Sistema operacional não suportado para instalação automática.")
            console.print("[red]Por favor, instale o Docker Compose manualmente.[/red]")
            return False
            
        try:
            result = subprocess.run(["docker-compose", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                compose_version = result.stdout.strip()
                log("SUCCESS", f"Docker Compose instalado com sucesso: {compose_version}")
                console.print(f"[green]Docker Compose instalado com sucesso:[/green] {compose_version}")
                return True
        except:
            log("ERROR", "Falha ao instalar Docker Compose.")
            console.print("[red]Falha ao instalar Docker Compose.[/red]")
            return False
    else:
        log("ERROR", "Docker Compose é necessário para continuar.")
        console.print("[red]Docker Compose é necessário para continuar.[/red]")
        return False

def clone_finops_repo():
    """Clona o repositório aws-finops-dashboard"""
    if os.path.exists(REPO_DIR):
        log("INFO", "Repositório aws-finops-dashboard já existe. Atualizando...")
        console.print("[blue]Repositório aws-finops-dashboard já existe. Atualizando...[/blue]")
        
        os.chdir(REPO_DIR)
        run_command(["git", "pull"])
    else:
        log("INFO", "Clonando repositório aws-finops-dashboard...")
        console.print("[blue]Clonando repositório aws-finops-dashboard...[/blue]")
        
        os.makedirs(os.path.dirname(REPO_DIR), exist_ok=True)
        success, output = run_command(["git", "clone", "https://github.com/ravikiranvm/aws-finops-dashboard.git", REPO_DIR])
        
        if not success:
            log("ERROR", "Falha ao clonar o repositório aws-finops-dashboard.")
            console.print("[red]Falha ao clonar o repositório aws-finops-dashboard.[/red]")
            return False
    
    log("SUCCESS", "Repositório aws-finops-dashboard clonado/atualizado com sucesso.")
    console.print("[green]Repositório aws-finops-dashboard clonado/atualizado com sucesso.[/green]")
    return True

def configure_finops_dashboard():
    """Configura o aws-finops-dashboard"""
    if not os.path.exists(REPO_DIR):
        log("ERROR", "Repositório aws-finops-dashboard não encontrado.")
        console.print("[red]Repositório aws-finops-dashboard não encontrado.[/red]")
        console.print("[yellow]Execute a verificação de dependências primeiro.[/yellow]")
        return False
    
    console.print("[blue]Configurando o AWS FinOps Dashboard...[/blue]")
    
    # Obter perfis AWS disponíveis
    success, output = run_command(["aws", "configure", "list-profiles"])
    if not success or not output.strip():
        log("ERROR", "Nenhum perfil AWS encontrado.")
        console.print("[red]Nenhum perfil AWS encontrado.[/red]")
        console.print("[yellow]Configure um perfil AWS primeiro usando 'arch-cli np'.[/yellow]")
        return False
    
    profiles = output.strip().split('\n')
    console.print("[blue]Perfis AWS disponíveis:[/blue]")
    for i, profile in enumerate(profiles, 1):
        console.print(f"  {i}. {profile}")
    
    profile_idx = Prompt.ask("Selecione o número do perfil", default="1")
    try:
        profile_idx = int(profile_idx) - 1
        if profile_idx < 0 or profile_idx >= len(profiles):
            raise ValueError("Índice fora do intervalo")
        profile_name = profiles[profile_idx]
    except:
        log("ERROR", "Seleção inválida.")
        console.print("[red]Seleção inválida.[/red]")
        return False
    
    # Verificar se o perfil existe
    success, _ = run_command(["aws", "configure", "list", "--profile", profile_name])
    if not success:
        log("ERROR", f"Perfil '{profile_name}' não encontrado.")
        console.print(f"[red]Perfil '{profile_name}' não encontrado.[/red]")
        return False
    
    # Configurar variáveis de ambiente
    os.chdir(REPO_DIR)
    
    # Verificar se o arquivo .env existe
    if not os.path.exists(os.path.join(REPO_DIR, ".env")):
        log("INFO", "Criando arquivo .env...")
        if os.path.exists(os.path.join(REPO_DIR, ".env.example")):
            run_command(["cp", ".env.example", ".env"])
        else:
            # Criar um arquivo .env básico se .env.example não existir
            with open(os.path.join(REPO_DIR, ".env"), "w") as f:
                f.write("AWS_PROFILE=default\n")
                f.write("AWS_REGION=us-east-1\n")
    
    # Editar o arquivo .env
    console.print("[blue]Configurando variáveis de ambiente...[/blue]")
    aws_region = Prompt.ask("Informe a região AWS", default="us-east-1")
    
    # Atualizar o arquivo .env
    env_file = os.path.join(REPO_DIR, ".env")
    with open(env_file, "r") as f:
        env_content = f.read()
    
    # Substituir ou adicionar as variáveis
    if "AWS_PROFILE=" in env_content:
        env_content = env_content.replace(f"AWS_PROFILE=", f"AWS_PROFILE={profile_name}")
    else:
        env_content += f"\nAWS_PROFILE={profile_name}\n"
    
    if "AWS_REGION=" in env_content:
        env_content = env_content.replace(f"AWS_REGION=", f"AWS_REGION={aws_region}")
    else:
        env_content += f"\nAWS_REGION={aws_region}\n"
    
    with open(env_file, "w") as f:
        f.write(env_content)
    
    log("SUCCESS", "Configuração do AWS FinOps Dashboard concluída.")
    console.print("[green]Configuração do AWS FinOps Dashboard concluída.[/green]")
    return True

def start_finops_dashboard():
    """Inicia o aws-finops-dashboard"""
    if not os.path.exists(REPO_DIR):
        log("ERROR", "Repositório aws-finops-dashboard não encontrado.")
        console.print("[red]Repositório aws-finops-dashboard não encontrado.[/red]")
        console.print("[yellow]Execute a configuração primeiro.[/yellow]")
        return False
    
    os.chdir(REPO_DIR)
    
    console.print("[blue]Iniciando o AWS FinOps Dashboard...[/blue]")
    success, output = run_command(["docker-compose", "up", "-d"])
    
    if success:
        log("SUCCESS", "AWS FinOps Dashboard iniciado com sucesso.")
        console.print("[green]AWS FinOps Dashboard iniciado com sucesso.[/green]")
        console.print("[blue]AWS FinOps Dashboard está rodando em:[/blue] http://localhost:3000")
        console.print("[blue]Usuário padrão:[/blue] admin")
        console.print("[blue]Senha padrão:[/blue] admin")
        return True
    else:
        log("ERROR", "Falha ao iniciar o AWS FinOps Dashboard.")
        console.print("[red]Falha ao iniciar o AWS FinOps Dashboard.[/red]")
        console.print(f"[yellow]Erro: {output}[/yellow]")
        return False

def stop_finops_dashboard():
    """Para o aws-finops-dashboard"""
    if not os.path.exists(REPO_DIR):
        log("ERROR", "Repositório aws-finops-dashboard não encontrado.")
        console.print("[red]Repositório aws-finops-dashboard não encontrado.[/red]")
        console.print("[yellow]Execute a configuração primeiro.[/yellow]")
        return False
    
    os.chdir(REPO_DIR)
    
    console.print("[blue]Parando o AWS FinOps Dashboard...[/blue]")
    success, output = run_command(["docker-compose", "down"])
    
    if success:
        log("SUCCESS", "AWS FinOps Dashboard parado com sucesso.")
        console.print("[green]AWS FinOps Dashboard parado com sucesso.[/green]")
        return True
    else:
        log("ERROR", "Falha ao parar o AWS FinOps Dashboard.")
        console.print("[red]Falha ao parar o AWS FinOps Dashboard.[/red]")
        console.print(f"[yellow]Erro: {output}[/yellow]")
        return False

def finops_menu():
    """Menu principal do FinOps Dashboard"""
    from rich.prompt import IntPrompt
    
    while True:
        console.clear()
        console.print("\n[bold green]AWS FinOps Dashboard[/bold green]\n")
        
        console.print("[bold blue]Menu FinOps Dashboard:[/bold blue]")
        console.print("1. Verificar dependências (Git, Docker, Docker Compose)")
        console.print("2. Configurar AWS FinOps Dashboard")
        console.print("3. Iniciar AWS FinOps Dashboard")
        console.print("4. Parar AWS FinOps Dashboard")
        console.print("0. Voltar ao menu principal")
        
        option = IntPrompt.ask("Escolha uma opção", default=0)
        
        if option == 1:
            if check_git() and check_docker() and check_docker_compose():
                clone_finops_repo()
        elif option == 2:
            configure_finops_dashboard()
        elif option == 3:
            start_finops_dashboard()
        elif option == 4:
            stop_finops_dashboard()
        elif option == 0:
            break
        else:
            console.print("[red]Opção inválida.[/red]")
        
        console.print("\nPressione Enter para continuar...")
        input()
