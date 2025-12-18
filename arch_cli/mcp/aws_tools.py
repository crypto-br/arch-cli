"""
AWS Tools for MCP Integration
Provides AWS-specific functionality enhanced by MCP intelligence
"""

import boto3
import json
import logging
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from .client import get_mcp_client
from .fallback import FallbackMode

logger = logging.getLogger(__name__)

class AWSTools:
    """AWS tools enhanced with MCP intelligence"""
    
    def __init__(self, profile: Optional[str] = None):
        self.profile = profile
        self.session = boto3.Session(profile_name=profile) if profile else boto3.Session()
        self.fallback = FallbackMode()
        
    async def analyze_costs(self, enhanced: bool = True) -> Dict:
        """Analyze AWS costs with optional MCP enhancement"""
        try:
            # Get basic cost data
            basic_analysis = await self._get_basic_cost_analysis()
            
            if not enhanced:
                return basic_analysis
            
            # Try MCP enhancement
            try:
                mcp_client = await get_mcp_client()
                if mcp_client.is_available():
                    enhanced_analysis = await mcp_client.call_tool(
                        "aws-cost-analyzer",
                        {"basic_data": basic_analysis, "profile": self.profile}
                    )
                    return self._merge_analysis(basic_analysis, enhanced_analysis)
            except Exception as e:
                logger.warning(f"MCP enhancement failed, using fallback: {e}")
            
            # Fallback to basic analysis
            return self.fallback.enhance_cost_analysis(basic_analysis)
            
        except Exception as e:
            logger.error(f"Cost analysis failed: {e}")
            return {"error": str(e)}
    
    async def security_scan(self, quick: bool = True) -> Dict:
        """Perform security scan with MCP intelligence"""
        try:
            # Get basic security data
            basic_scan = await self._get_basic_security_scan()
            
            if not quick:
                # Try MCP enhancement for comprehensive scan
                try:
                    mcp_client = await get_mcp_client()
                    if mcp_client.is_available():
                        enhanced_scan = await mcp_client.call_tool(
                            "aws-security-scanner",
                            {"basic_data": basic_scan, "profile": self.profile}
                        )
                        return self._merge_analysis(basic_scan, enhanced_scan)
                except Exception as e:
                    logger.warning(f"MCP security scan failed: {e}")
            
            # Fallback to basic scan
            return self.fallback.enhance_security_scan(basic_scan)
            
        except Exception as e:
            logger.error(f"Security scan failed: {e}")
            return {"error": str(e)}
    
    async def optimize_resources(self) -> Dict:
        """Optimize AWS resources with MCP recommendations"""
        try:
            # Get basic resource data
            basic_optimization = await self._get_basic_resource_data()
            
            # Try MCP enhancement
            try:
                mcp_client = await get_mcp_client()
                if mcp_client.is_available():
                    optimization = await mcp_client.call_tool(
                        "aws-resource-optimizer",
                        {"resource_data": basic_optimization, "profile": self.profile}
                    )
                    return optimization
            except Exception as e:
                logger.warning(f"MCP optimization failed: {e}")
            
            # Fallback to basic optimization
            return self.fallback.basic_resource_optimization(basic_optimization)
            
        except Exception as e:
            logger.error(f"Resource optimization failed: {e}")
            return {"error": str(e)}
    
    async def _get_basic_cost_analysis(self) -> Dict:
        """Get basic cost analysis using AWS APIs"""
        try:
            ce_client = self.session.client('ce')
            
            # Get cost for last 30 days
            end_date = datetime.now().date()
            start_date = end_date - timedelta(days=30)
            
            response = ce_client.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date.strftime('%Y-%m-%d'),
                    'End': end_date.strftime('%Y-%m-%d')
                },
                Granularity='MONTHLY',
                Metrics=['BlendedCost']
            )
            
            total_cost = 0
            if response['ResultsByTime']:
                total_cost = float(response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])
            
            return {
                "period": f"{start_date} to {end_date}",
                "total_cost": total_cost,
                "currency": response['ResultsByTime'][0]['Total']['BlendedCost']['Unit'] if response['ResultsByTime'] else 'USD'
            }
            
        except Exception as e:
            logger.error(f"Basic cost analysis failed: {e}")
            return {"error": str(e)}
    
    async def _get_basic_security_scan(self) -> Dict:
        """Get basic security scan using AWS APIs"""
        try:
            ec2_client = self.session.client('ec2')
            iam_client = self.session.client('iam')
            
            # Check security groups
            security_groups = ec2_client.describe_security_groups()
            open_sgs = []
            
            for sg in security_groups['SecurityGroups']:
                for rule in sg.get('IpPermissions', []):
                    for ip_range in rule.get('IpRanges', []):
                        if ip_range.get('CidrIp') == '0.0.0.0/0':
                            open_sgs.append({
                                'group_id': sg['GroupId'],
                                'port': rule.get('FromPort', 'All'),
                                'protocol': rule.get('IpProtocol', 'All')
                            })
            
            # Check IAM users without MFA
            users = iam_client.list_users()
            users_without_mfa = []
            
            for user in users['Users']:
                mfa_devices = iam_client.list_mfa_devices(UserName=user['UserName'])
                if not mfa_devices['MFADevices']:
                    users_without_mfa.append(user['UserName'])
            
            return {
                "open_security_groups": open_sgs,
                "users_without_mfa": users_without_mfa,
                "scan_timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Basic security scan failed: {e}")
            return {"error": str(e)}
    
    async def _get_basic_resource_data(self) -> Dict:
        """Get basic resource data for optimization"""
        try:
            ec2_client = self.session.client('ec2')
            cloudwatch = self.session.client('cloudwatch')
            
            # Get EC2 instances
            instances = ec2_client.describe_instances()
            instance_data = []
            
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    if instance['State']['Name'] == 'running':
                        instance_data.append({
                            'instance_id': instance['InstanceId'],
                            'instance_type': instance['InstanceType'],
                            'launch_time': instance['LaunchTime'].isoformat()
                        })
            
            return {
                "ec2_instances": instance_data,
                "scan_timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Basic resource data collection failed: {e}")
            return {"error": str(e)}
    
    def _merge_analysis(self, basic: Dict, enhanced: Dict) -> Dict:
        """Merge basic and enhanced analysis results"""
        result = basic.copy()
        result.update(enhanced)
        result["enhanced"] = True
        result["mcp_enabled"] = True
        return result
