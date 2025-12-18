"""
Smart Analyzer for Arch-CLI
Main interface for intelligent AWS analysis using MCP
"""

import asyncio
import logging
from typing import Dict, List, Optional, Any
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn

from .aws_tools import AWSTools
from .client import get_mcp_client
from .fallback import FallbackMode

logger = logging.getLogger(__name__)
console = Console()

class SmartAnalyzer:
    """Main smart analyzer for AWS infrastructure"""
    
    def __init__(self, profile: Optional[str] = None):
        self.profile = profile
        self.aws_tools = AWSTools(profile)
        self.fallback = FallbackMode()
        
    async def analyze_infrastructure(self, comprehensive: bool = False) -> Dict:
        """Comprehensive infrastructure analysis"""
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            
            task = progress.add_task("Analyzing AWS infrastructure...", total=None)
            
            try:
                # Run parallel analysis
                results = await asyncio.gather(
                    self.aws_tools.analyze_costs(enhanced=True),
                    self.aws_tools.security_scan(quick=not comprehensive),
                    self.aws_tools.optimize_resources(),
                    return_exceptions=True
                )
                
                cost_analysis, security_scan, resource_optimization = results
                
                # Compile comprehensive report
                report = {
                    "timestamp": asyncio.get_event_loop().time(),
                    "profile": self.profile,
                    "comprehensive": comprehensive,
                    "cost_analysis": cost_analysis if not isinstance(cost_analysis, Exception) else {"error": str(cost_analysis)},
                    "security_scan": security_scan if not isinstance(security_scan, Exception) else {"error": str(security_scan)},
                    "resource_optimization": resource_optimization if not isinstance(resource_optimization, Exception) else {"error": str(resource_optimization)},
                }
                
                # Generate summary
                report["summary"] = self._generate_summary(report)
                
                progress.update(task, description="Analysis complete!")
                return report
                
            except Exception as e:
                logger.error(f"Infrastructure analysis failed: {e}")
                return {"error": str(e)}
    
    async def quick_health_check(self) -> Dict:
        """Quick health check of AWS infrastructure"""
        try:
            mcp_client = await get_mcp_client()
            mcp_available = mcp_client.is_available()
            
            # Basic health indicators
            health_check = {
                "mcp_available": mcp_available,
                "profile": self.profile,
                "timestamp": asyncio.get_event_loop().time(),
                "status": "healthy"
            }
            
            # Quick cost check
            cost_data = await self.aws_tools.analyze_costs(enhanced=False)
            if "error" not in cost_data:
                health_check["monthly_cost"] = cost_data.get("total_cost", 0)
            
            # Quick security check
            security_data = await self.aws_tools.security_scan(quick=True)
            if "error" not in security_data:
                health_check["security_issues"] = len(security_data.get("open_security_groups", []))
            
            return health_check
            
        except Exception as e:
            return {"status": "unhealthy", "error": str(e)}
    
    def display_analysis_results(self, results: Dict):
        """Display analysis results in a formatted way"""
        if "error" in results:
            console.print(f"[red]❌ Analysis failed: {results['error']}[/red]")
            return
        
        # Display header
        mcp_status = "🤖 AI-Enhanced" if results.get("cost_analysis", {}).get("mcp_enabled") else "📊 Basic Mode"
        console.print(Panel(f"AWS Infrastructure Analysis - {mcp_status}", style="blue"))
        
        # Cost Analysis
        self._display_cost_analysis(results.get("cost_analysis", {}))
        
        # Security Analysis
        self._display_security_analysis(results.get("security_scan", {}))
        
        # Resource Optimization
        self._display_resource_optimization(results.get("resource_optimization", {}))
        
        # Summary
        if "summary" in results:
            self._display_summary(results["summary"])
    
    def _display_cost_analysis(self, cost_data: Dict):
        """Display cost analysis results"""
        if "error" in cost_data:
            console.print("[red]❌ Cost analysis failed[/red]")
            return
        
        console.print("\n💰 [bold]Cost Analysis[/bold]")
        
        table = Table(show_header=True, header_style="bold magenta")
        table.add_column("Metric", style="cyan")
        table.add_column("Value", style="green")
        
        table.add_row("Total Monthly Cost", f"${cost_data.get('total_cost', 0):.2f}")
        
        if "optimization_opportunities" in cost_data:
            total_savings = sum(op.get("potential_savings", 0) for op in cost_data["optimization_opportunities"])
            table.add_row("Potential Savings", f"${total_savings:.2f}")
        
        console.print(table)
        
        # Recommendations
        if "recommendations" in cost_data:
            console.print("\n💡 [bold]Cost Recommendations:[/bold]")
            for rec in cost_data["recommendations"]:
                console.print(f"  • {rec}")
    
    def _display_security_analysis(self, security_data: Dict):
        """Display security analysis results"""
        if "error" in security_data:
            console.print("[red]❌ Security analysis failed[/red]")
            return
        
        console.print("\n🔒 [bold]Security Analysis[/bold]")
        
        # Security score
        score = security_data.get("security_score", security_data.get("compliance_score", 0))
        score_color = "green" if score > 0.8 else "yellow" if score > 0.6 else "red"
        console.print(f"Security Score: [{score_color}]{score:.1%}[/{score_color}]")
        
        # Issues
        open_sgs = security_data.get("open_security_groups", [])
        if open_sgs:
            console.print(f"[yellow]⚠️  {len(open_sgs)} open security groups found[/yellow]")
        
        users_no_mfa = security_data.get("users_without_mfa", [])
        if users_no_mfa:
            console.print(f"[yellow]⚠️  {len(users_no_mfa)} users without MFA[/yellow]")
        
        # Recommendations
        if "recommendations" in security_data:
            console.print("\n🛡️  [bold]Security Recommendations:[/bold]")
            for rec in security_data["recommendations"]:
                console.print(f"  • {rec}")
    
    def _display_resource_optimization(self, optimization_data: Dict):
        """Display resource optimization results"""
        if "error" in optimization_data:
            console.print("[red]❌ Resource optimization failed[/red]")
            return
        
        console.print("\n⚡ [bold]Resource Optimization[/bold]")
        
        # Optimization score
        score = optimization_data.get("optimization_score", 0)
        score_color = "green" if score > 0.8 else "yellow" if score > 0.6 else "red"
        console.print(f"Optimization Score: [{score_color}]{score:.1%}[/{score_color}]")
        
        # Underutilized resources
        underutilized = optimization_data.get("underutilized_resources", [])
        if underutilized:
            console.print(f"[yellow]📊 {len(underutilized)} underutilized resources found[/yellow]")
        
        # Potential savings
        total_savings = optimization_data.get("total_potential_savings", 0)
        if total_savings:
            console.print(f"[green]💰 Potential monthly savings: ${total_savings:.2f}[/green]")
        
        # Recommendations
        if "recommendations" in optimization_data:
            console.print("\n🎯 [bold]Optimization Recommendations:[/bold]")
            for rec in optimization_data["recommendations"]:
                console.print(f"  • {rec}")
    
    def _display_summary(self, summary: Dict):
        """Display analysis summary"""
        console.print("\n📋 [bold]Summary[/bold]")
        
        priority_actions = summary.get("priority_actions", [])
        if priority_actions:
            console.print("[bold]🚨 Priority Actions:[/bold]")
            for action in priority_actions[:3]:  # Top 3
                console.print(f"  1. {action}")
        
        overall_score = summary.get("overall_score", 0)
        score_color = "green" if overall_score > 0.8 else "yellow" if overall_score > 0.6 else "red"
        console.print(f"\n[bold]Overall Health Score: [{score_color}]{overall_score:.1%}[/{score_color}][/bold]")
    
    def _generate_summary(self, report: Dict) -> Dict:
        """Generate analysis summary"""
        summary = {
            "overall_score": 0.7,  # Default
            "priority_actions": [],
            "key_metrics": {}
        }
        
        # Collect priority actions from all analyses
        cost_data = report.get("cost_analysis", {})
        if "recommendations" in cost_data:
            summary["priority_actions"].extend(cost_data["recommendations"][:2])
        
        security_data = report.get("security_scan", {})
        if "recommendations" in security_data:
            summary["priority_actions"].extend(security_data["recommendations"][:2])
        
        optimization_data = report.get("resource_optimization", {})
        if "recommendations" in optimization_data:
            summary["priority_actions"].extend(optimization_data["recommendations"][:1])
        
        # Calculate overall score
        scores = []
        if "security_score" in security_data:
            scores.append(security_data["security_score"])
        if "optimization_score" in optimization_data:
            scores.append(optimization_data["optimization_score"])
        
        if scores:
            summary["overall_score"] = sum(scores) / len(scores)
        
        return summary
