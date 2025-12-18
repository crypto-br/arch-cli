#!/usr/bin/env python3
"""
Módulo principal do Arch CLI que serve como ponto de entrada para o comando arch-cli
"""

import os
import sys
import subprocess
import asyncio
import click
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from .dependencies import check_dependencies as check_deps_py
from .mcp.smart_analyzer import SmartAnalyzer

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
    header.append(" \\__,_|_|  \\___|_| |_|      \\___|_|_| v4.0\n", style="green")
    header.append("\n")
    header.append("Created by: Luiz Machado (@cryptobr)\n")
    
    console.print(Panel(header, border_style="blue"))

@click.group(invoke_without_command=True)
@click.pass_context
@click.version_option(version="4.0.0")
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
@click.argument("profile_name", required=False)
def profile(profile_name):
    """Define ou gerencia o perfil AWS ativo"""
    if profile_name:
        subprocess.run(["/bin/bash", BASH_SCRIPT, "--profile", profile_name])
    else:
        subprocess.run(["/bin/bash", BASH_SCRIPT, "--profile"])
@main.command()
def finops():
    """Acessa o menu do AWS FinOps Dashboard"""
    subprocess.run(["/bin/bash", BASH_SCRIPT, "--finops"])

@main.command()
@click.option("--profile", help="AWS profile to use")
@click.option("--comprehensive", is_flag=True, help="Run comprehensive analysis (slower but more detailed)")
def analyze(profile, comprehensive):
    """🤖 Smart AWS infrastructure analysis with AI insights"""
    async def run_analysis():
        analyzer = SmartAnalyzer(profile)
        console.print("🚀 Starting smart AWS analysis...")
        
        if not comprehensive:
            console.print("💡 Tip: Use --comprehensive for detailed analysis")
        
        results = await analyzer.analyze_infrastructure(comprehensive=comprehensive)
        analyzer.display_analysis_results(results)
    
    asyncio.run(run_analysis())

@main.command()
@click.option("--profile", help="AWS profile to use")
def optimize(profile):
    """⚡ Smart resource optimization with cost savings recommendations"""
    async def run_optimization():
        analyzer = SmartAnalyzer(profile)
        console.print("🎯 Analyzing resources for optimization opportunities...")
        
        from .mcp.aws_tools import AWSTools
        aws_tools = AWSTools(profile)
        results = await aws_tools.optimize_resources()
        
        if "error" in results:
            console.print(f"[red]❌ Optimization failed: {results['error']}[/red]")
            return
        
        # Display optimization results
        console.print(Panel("⚡ Resource Optimization Results", style="green"))
        
        total_savings = results.get("total_potential_savings", 0)
        if total_savings > 0:
            console.print(f"[green]💰 Potential monthly savings: ${total_savings:.2f}[/green]")
        
        underutilized = results.get("underutilized_resources", [])
        if underutilized:
            console.print(f"\n📊 Found {len(underutilized)} underutilized resources:")
            for resource in underutilized[:5]:  # Show top 5
                console.print(f"  • {resource.get('resource_id', 'Unknown')} - Save ${resource.get('monthly_savings', 0):.2f}/month")
        
        recommendations = results.get("recommendations", [])
        if recommendations:
            console.print("\n💡 [bold]Recommendations:[/bold]")
            for rec in recommendations:
                console.print(f"  • {rec}")
    
    asyncio.run(run_optimization())

@main.command()
@click.option("--profile", help="AWS profile to use")
def health(profile):
    """🏥 Quick health check of AWS infrastructure"""
    async def run_health_check():
        analyzer = SmartAnalyzer(profile)
        console.print("🔍 Running quick health check...")
        
        results = await analyzer.quick_health_check()
        
        if results.get("status") == "unhealthy":
            console.print(f"[red]❌ Health check failed: {results.get('error', 'Unknown error')}[/red]")
            return
        
        # Display health status
        console.print(Panel("🏥 AWS Infrastructure Health Check", style="blue"))
        
        mcp_status = "🤖 Available" if results.get("mcp_available") else "📊 Basic Mode"
        console.print(f"MCP Status: {mcp_status}")
        
        if "monthly_cost" in results:
            console.print(f"Monthly Cost: ${results['monthly_cost']:.2f}")
        
        if "security_issues" in results:
            issues = results["security_issues"]
            color = "red" if issues > 0 else "green"
            console.print(f"Security Issues: [{color}]{issues}[/{color}]")
        
        console.print(f"[green]✅ Overall Status: {results['status'].title()}[/green]")
    
    asyncio.run(run_health_check())

if __name__ == "__main__":
    main()
