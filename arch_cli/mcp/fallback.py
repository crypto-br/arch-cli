"""
Fallback Mode for Arch-CLI
Provides basic functionality when MCP server is not available
"""

import logging
from typing import Dict, List, Any
from datetime import datetime

logger = logging.getLogger(__name__)

class FallbackMode:
    """Fallback functionality when MCP is not available"""
    
    def __init__(self):
        self.mode = "fallback"
        logger.info("Fallback mode initialized")
    
    def enhance_cost_analysis(self, basic_data: Dict) -> Dict:
        """Enhance cost analysis with basic rules"""
        enhanced = basic_data.copy()
        enhanced["enhanced"] = False
        enhanced["mcp_enabled"] = False
        
        # Basic cost optimization suggestions
        total_cost = basic_data.get("total_cost", 0)
        
        recommendations = []
        if total_cost > 1000:
            recommendations.append("Consider Reserved Instances for cost savings")
        if total_cost > 500:
            recommendations.append("Review unused resources monthly")
        
        enhanced["recommendations"] = recommendations
        enhanced["optimization_opportunities"] = self._basic_cost_opportunities(total_cost)
        
        return enhanced
    
    def enhance_security_scan(self, basic_data: Dict) -> Dict:
        """Enhance security scan with basic rules"""
        enhanced = basic_data.copy()
        enhanced["enhanced"] = False
        enhanced["mcp_enabled"] = False
        
        # Calculate basic security score
        issues = 0
        recommendations = []
        
        # Check open security groups
        open_sgs = basic_data.get("open_security_groups", [])
        if open_sgs:
            issues += len(open_sgs)
            recommendations.append("Restrict overly permissive security groups")
        
        # Check users without MFA
        users_no_mfa = basic_data.get("users_without_mfa", [])
        if users_no_mfa:
            issues += len(users_no_mfa)
            recommendations.append("Enable MFA for all IAM users")
        
        # Basic security score (0-1)
        max_issues = 10  # Arbitrary baseline
        security_score = max(0, (max_issues - issues) / max_issues)
        
        enhanced["security_score"] = security_score
        enhanced["recommendations"] = recommendations
        enhanced["total_issues"] = issues
        
        return enhanced
    
    def basic_resource_optimization(self, resource_data: Dict) -> Dict:
        """Basic resource optimization without MCP"""
        optimization = {
            "enhanced": False,
            "mcp_enabled": False,
            "scan_timestamp": datetime.now().isoformat()
        }
        
        # Basic EC2 analysis
        instances = resource_data.get("ec2_instances", [])
        recommendations = []
        
        if len(instances) > 10:
            recommendations.append("Consider using Auto Scaling Groups for better resource management")
        
        if instances:
            recommendations.append("Monitor CloudWatch metrics to identify underutilized instances")
        
        optimization["recommendations"] = recommendations
        optimization["instance_count"] = len(instances)
        optimization["optimization_score"] = 0.5  # Basic score
        
        return optimization
    
    def _basic_cost_opportunities(self, total_cost: float) -> List[Dict]:
        """Generate basic cost optimization opportunities"""
        opportunities = []
        
        if total_cost > 2000:
            opportunities.append({
                "type": "Reserved Instances",
                "potential_savings": total_cost * 0.3,  # 30% potential savings
                "confidence": 0.6,
                "description": "Consider Reserved Instances for stable workloads"
            })
        
        if total_cost > 1000:
            opportunities.append({
                "type": "Resource Rightsizing",
                "potential_savings": total_cost * 0.15,  # 15% potential savings
                "confidence": 0.5,
                "description": "Review and rightsize underutilized resources"
            })
        
        opportunities.append({
            "type": "Unused Resources",
            "potential_savings": total_cost * 0.1,  # 10% potential savings
            "confidence": 0.7,
            "description": "Identify and terminate unused resources"
        })
        
        return opportunities
    
    def get_basic_recommendations(self, service_type: str) -> List[str]:
        """Get basic recommendations by service type"""
        recommendations = {
            "ec2": [
                "Use appropriate instance types for your workload",
                "Enable detailed monitoring for better insights",
                "Consider Spot Instances for fault-tolerant workloads"
            ],
            "s3": [
                "Use appropriate storage classes",
                "Enable lifecycle policies",
                "Monitor access patterns"
            ],
            "rds": [
                "Use appropriate instance sizes",
                "Enable automated backups",
                "Consider read replicas for read-heavy workloads"
            ],
            "general": [
                "Tag all resources for better cost tracking",
                "Set up billing alerts",
                "Review resources monthly"
            ]
        }
        
        return recommendations.get(service_type, recommendations["general"])
    
    def format_fallback_message(self) -> str:
        """Format message indicating fallback mode"""
        return (
            "🔄 Running in basic mode (MCP server not available)\n"
            "💡 For enhanced AI-powered insights, ensure MCP server is running\n"
            "📊 Basic analysis and recommendations provided below"
        )
