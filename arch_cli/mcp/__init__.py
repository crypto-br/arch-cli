"""
MCP (Model Context Protocol) Integration for Arch-CLI
Provides intelligent AWS analysis and recommendations
"""

__version__ = "1.0.0"
__author__ = "Luiz Machado (@cryptobr)"

from .client import MCPClient
from .aws_tools import AWSTools
from .fallback import FallbackMode
from .smart_analyzer import SmartAnalyzer

__all__ = [
    'MCPClient',
    'AWSTools', 
    'FallbackMode',
    'SmartAnalyzer'
]
