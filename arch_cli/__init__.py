"""
Arch CLI - Ferramenta para gerenciamento de times de Arquitetura, SRE e DevOps com foco em AWS
"""

from .utils import detect_os, log, run_command, setup_config_dir
from .dependencies import check_dependencies
from .finops import finops_menu

__version__ = "3.0.0"
