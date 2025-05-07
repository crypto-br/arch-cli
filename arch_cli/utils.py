"""
Utilitários para o Arch CLI em Python
"""

import os
import platform
import subprocess
import json
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TimeElapsedColumn

console = Console()

# Configurações
CONFIG_DIR = os.path.expanduser("~/.arch-cli")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")
LOG_FILE = os.path.join(CONFIG_DIR, "arch-cli.log")

def setup_config_dir():
    """Cria o diretório de configuração se não existir"""
    if not os.path.exists(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)
        log("INFO", f"Diretório de configuração criado: {CONFIG_DIR}")
    
    if not os.path.exists(LOG_FILE):
        with open(LOG_FILE, "w") as f:
            pass
        log("INFO", f"Arquivo de log criado: {LOG_FILE}")

def log(level, message):
    """Registra mensagens no arquivo de log"""
    import datetime
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp}] [{level}] {message}\n")
    
    if level == "INFO":
        console.print(f"[blue][INFO][/blue] {message}")
    elif level == "SUCCESS":
        console.print(f"[green][SUCCESS][/green] {message}")
    elif level == "WARNING":
        console.print(f"[yellow][WARNING][/yellow] {message}")
    elif level == "ERROR":
        console.print(f"[red][ERROR][/red] {message}")
    else:
        console.print(message)

def detect_os():
    """Detecta o sistema operacional"""
    system = platform.system().lower()
    
    if system == "linux":
        # Verificar Amazon Linux
        try:
            if os.path.exists("/etc/system-release"):
                with open("/etc/system-release") as f:
                    if "Amazon Linux" in f.read():
                        return "amazon-linux"
        except:
            pass
            
        # Verificar distribuição Linux
        try:
            with open("/etc/os-release") as f:
                os_release = f.read().lower()
                if "debian" in os_release or "ubuntu" in os_release:
                    return "debian"
                elif "rhel" in os_release or "centos" in os_release or "fedora" in os_release:
                    return "redhat"
                else:
                    return "linux-other"
        except FileNotFoundError:
            return "linux-other"
    elif system == "darwin":
        return "macos"
    else:
        return "unknown"

def run_command(command, shell=False):
    """Executa um comando e retorna o resultado"""
    try:
        if shell:
            result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        else:
            result = subprocess.run(command, check=True, text=True, capture_output=True)
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, e.stderr

def get_aws_profiles():
    """Obtém a lista de perfis AWS configurados"""
    success, output = run_command(["aws", "configure", "list-profiles"])
    if success:
        return output.strip().split("\n")
    return []

def create_progress_bar(description="Processando"):
    """Cria uma barra de progresso"""
    return Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TimeElapsedColumn(),
        console=console
    )

def load_config():
    """Carrega a configuração do arquivo JSON"""
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r") as f:
                return json.load(f)
        except json.JSONDecodeError:
            log("ERROR", f"Erro ao carregar arquivo de configuração: {CONFIG_FILE}")
            return {}
    return {}

def save_config(config):
    """Salva a configuração no arquivo JSON"""
    try:
        with open(CONFIG_FILE, "w") as f:
            json.dump(config, f, indent=2)
        return True
    except Exception as e:
        log("ERROR", f"Erro ao salvar arquivo de configuração: {str(e)}")
        return False
