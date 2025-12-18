"""
Tests for MCP Integration
"""

import pytest
import asyncio
from unittest.mock import Mock, patch, AsyncMock
from arch_cli.mcp.client import MCPClient
from arch_cli.mcp.aws_tools import AWSTools
from arch_cli.mcp.smart_analyzer import SmartAnalyzer
from arch_cli.mcp.fallback import FallbackMode

class TestMCPClient:
    """Test MCP Client functionality"""
    
    @pytest.mark.asyncio
    async def test_mcp_client_connection(self):
        """Test MCP client connection"""
        client = MCPClient()
        result = await client.connect()
        assert result is True
        assert client.is_connected is True
        assert len(client.tools_available) > 0
    
    @pytest.mark.asyncio
    async def test_mcp_tool_call(self):
        """Test MCP tool call"""
        client = MCPClient()
        await client.connect()
        
        result = await client.call_tool("aws-cost-analyzer", {})
        assert "analysis" in result
        assert "total_monthly_cost" in result["analysis"]
    
    @pytest.mark.asyncio
    async def test_mcp_client_disconnect(self):
        """Test MCP client disconnect"""
        client = MCPClient()
        await client.connect()
        await client.disconnect()
        assert client.is_connected is False
        assert len(client.tools_available) == 0

class TestAWSTools:
    """Test AWS Tools functionality"""
    
    @pytest.mark.asyncio
    async def test_cost_analysis_fallback(self):
        """Test cost analysis with fallback"""
        with patch('boto3.Session') as mock_session:
            mock_ce_client = Mock()
            mock_ce_client.get_cost_and_usage.return_value = {
                'ResultsByTime': [{
                    'Total': {
                        'BlendedCost': {
                            'Amount': '1250.50',
                            'Unit': 'USD'
                        }
                    }
                }]
            }
            mock_session.return_value.client.return_value = mock_ce_client
            
            tools = AWSTools()
            result = await tools.analyze_costs(enhanced=False)
            assert isinstance(result, dict)
            assert "total_cost" in result
    
    @pytest.mark.asyncio
    async def test_security_scan_basic(self):
        """Test basic security scan"""
        with patch('boto3.Session') as mock_session:
            mock_ec2_client = Mock()
            mock_iam_client = Mock()
            
            mock_ec2_client.describe_security_groups.return_value = {
                'SecurityGroups': [{
                    'GroupId': 'sg-123',
                    'IpPermissions': [{
                        'IpRanges': [{'CidrIp': '0.0.0.0/0'}],
                        'FromPort': 22,
                        'IpProtocol': 'tcp'
                    }]
                }]
            }
            
            mock_iam_client.list_users.return_value = {
                'Users': [{'UserName': 'testuser'}]
            }
            mock_iam_client.list_mfa_devices.return_value = {
                'MFADevices': []
            }
            
            mock_session.return_value.client.side_effect = lambda service: {
                'ec2': mock_ec2_client,
                'iam': mock_iam_client
            }[service]
            
            tools = AWSTools()
            result = await tools.security_scan(quick=True)
            assert isinstance(result, dict)
            assert "open_security_groups" in result
    
    @pytest.mark.asyncio
    async def test_optimize_resources(self):
        """Test resource optimization"""
        with patch('boto3.Session') as mock_session:
            mock_ec2_client = Mock()
            mock_cloudwatch_client = Mock()
            
            mock_ec2_client.describe_instances.return_value = {
                'Reservations': [{
                    'Instances': [{
                        'InstanceId': 'i-123',
                        'InstanceType': 't3.large',
                        'State': {'Name': 'running'},
                        'LaunchTime': '2023-01-01T00:00:00Z'
                    }]
                }]
            }
            
            mock_session.return_value.client.side_effect = lambda service: {
                'ec2': mock_ec2_client,
                'cloudwatch': mock_cloudwatch_client
            }[service]
            
            tools = AWSTools()
            result = await tools.optimize_resources()
            assert isinstance(result, dict)

class TestFallbackMode:
    """Test Fallback Mode functionality"""
    
    def test_fallback_cost_enhancement(self):
        """Test fallback cost enhancement"""
        fallback = FallbackMode()
        basic_data = {"total_cost": 1500.0}
        
        result = fallback.enhance_cost_analysis(basic_data)
        assert result["enhanced"] is False
        assert result["mcp_enabled"] is False
        assert "recommendations" in result
        assert len(result["recommendations"]) > 0
    
    def test_fallback_security_enhancement(self):
        """Test fallback security enhancement"""
        fallback = FallbackMode()
        basic_data = {
            "open_security_groups": [{"group_id": "sg-123"}],
            "users_without_mfa": ["user1", "user2"]
        }
        
        result = fallback.enhance_security_scan(basic_data)
        assert "security_score" in result
        assert "recommendations" in result
        assert result["total_issues"] == 3
        assert 0 <= result["security_score"] <= 1
    
    def test_basic_resource_optimization(self):
        """Test basic resource optimization"""
        fallback = FallbackMode()
        resource_data = {
            "ec2_instances": [
                {"instance_id": "i-123", "instance_type": "t3.large"},
                {"instance_id": "i-456", "instance_type": "t3.medium"}
            ]
        }
        
        result = fallback.basic_resource_optimization(resource_data)
        assert "recommendations" in result
        assert "instance_count" in result
        assert result["instance_count"] == 2
        assert "optimization_score" in result
    
    def test_get_basic_recommendations(self):
        """Test basic recommendations by service"""
        fallback = FallbackMode()
        
        ec2_recs = fallback.get_basic_recommendations("ec2")
        assert len(ec2_recs) > 0
        assert any("instance" in rec.lower() for rec in ec2_recs)
        
        s3_recs = fallback.get_basic_recommendations("s3")
        assert len(s3_recs) > 0
        assert any("storage" in rec.lower() for rec in s3_recs)
        
        general_recs = fallback.get_basic_recommendations("unknown")
        assert len(general_recs) > 0

class TestSmartAnalyzer:
    """Test Smart Analyzer functionality"""
    
    @pytest.mark.asyncio
    async def test_quick_health_check(self):
        """Test quick health check"""
        with patch('boto3.Session'):
            analyzer = SmartAnalyzer()
            result = await analyzer.quick_health_check()
            assert "status" in result
            assert "mcp_available" in result
            assert "timestamp" in result
    
    @pytest.mark.asyncio
    async def test_analyze_infrastructure_basic(self):
        """Test basic infrastructure analysis"""
        with patch('boto3.Session'):
            with patch('arch_cli.mcp.aws_tools.AWSTools.analyze_costs') as mock_costs:
                with patch('arch_cli.mcp.aws_tools.AWSTools.security_scan') as mock_security:
                    with patch('arch_cli.mcp.aws_tools.AWSTools.optimize_resources') as mock_optimize:
                        
                        mock_costs.return_value = {"total_cost": 1000.0}
                        mock_security.return_value = {"security_score": 0.8}
                        mock_optimize.return_value = {"optimization_score": 0.7}
                        
                        analyzer = SmartAnalyzer()
                        result = await analyzer.analyze_infrastructure(comprehensive=False)
                        
                        assert "cost_analysis" in result
                        assert "security_scan" in result
                        assert "resource_optimization" in result
                        assert "summary" in result
    
    def test_generate_summary(self):
        """Test summary generation"""
        analyzer = SmartAnalyzer()
        
        report = {
            "cost_analysis": {
                "recommendations": ["Save money", "Use RI"]
            },
            "security_scan": {
                "recommendations": ["Enable MFA", "Fix SG"],
                "security_score": 0.7
            },
            "resource_optimization": {
                "recommendations": ["Rightsize"],
                "optimization_score": 0.8
            }
        }
        
        summary = analyzer._generate_summary(report)
        assert "priority_actions" in summary
        assert "overall_score" in summary
        assert len(summary["priority_actions"]) > 0
        assert 0 <= summary["overall_score"] <= 1

class TestIntegration:
    """Integration tests"""
    
    @pytest.mark.asyncio
    async def test_end_to_end_health_check(self):
        """Test complete health check flow"""
        with patch('boto3.Session'):
            analyzer = SmartAnalyzer()
            result = await analyzer.quick_health_check()
            
            # Should always return a result
            assert isinstance(result, dict)
            assert "status" in result
    
    def test_fallback_message_format(self):
        """Test fallback message formatting"""
        fallback = FallbackMode()
        message = fallback.format_fallback_message()
        
        assert "basic mode" in message.lower()
        assert "mcp server" in message.lower()
        assert "🔄" in message or "💡" in message or "📊" in message

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
