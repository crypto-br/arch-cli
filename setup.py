#!/usr/bin/env python3
"""
Script de instalação para o Arch CLI
"""

import os
import shutil
from setuptools import setup, find_packages

# Garantir que o script bash seja instalado
BASH_SCRIPT = "arch-cli.sh"
if os.path.exists(BASH_SCRIPT):
    os.chmod(BASH_SCRIPT, 0o755)  # Tornar o script executável

# Garantir que os módulos bash sejam instalados
MODULE_DIR = "modules"
if os.path.exists(MODULE_DIR):
    for file in os.listdir(MODULE_DIR):
        if file.endswith(".sh"):
            os.chmod(os.path.join(MODULE_DIR, file), 0o755)

# Configuração do pacote
setup(
    name="arch-cli",
    version="3.0.0",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "click>=8.0.0",
        "boto3>=1.20.0",
        "rich>=10.0.0",
        "pyyaml>=6.0",
    ],
    entry_points={
        "console_scripts": [
            "arch-cli=arch_cli.main:main",
        ],
    },
    python_requires=">=3.8",
    # Incluir arquivos bash
    package_data={
        "": ["*.sh", "modules/*.sh"],
    },
    # Garantir que os arquivos bash sejam instalados
    data_files=[
        ("bin", [BASH_SCRIPT]),
        ("share/arch-cli/modules", [os.path.join(MODULE_DIR, f) for f in os.listdir(MODULE_DIR) if f.endswith(".sh")]),
    ],
)
