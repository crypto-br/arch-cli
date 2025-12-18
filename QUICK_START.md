# 🚀 Arch-CLI Quick Start Guide

## Instalação Rápida

### 1. Clone e Instale
```bash
git clone <repositorio>
cd arch-cli

# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instalar
pip3 install -e .
```

### 2. Configurar AWS
```bash
# Configurar credenciais AWS
aws configure

# Ou usar perfil específico
arch-cli np  # Configurar novo perfil
```

### 3. Testar Instalação
```bash
# Health check rápido
arch-cli health

# Análise básica
arch-cli analyze

# Ver todas as opções
arch-cli --help
```

## Comandos Essenciais

### 🏥 Health Check (10 segundos)
```bash
arch-cli health
arch-cli health --profile production
```

### 🤖 Análise Inteligente (30 segundos - 3 minutos)
```bash
# Análise rápida
arch-cli analyze

# Análise completa
arch-cli analyze --comprehensive

# Perfil específico
arch-cli analyze --profile staging
```

### ⚡ Otimização de Recursos
```bash
# Encontrar economia de custos
arch-cli optimize

# Com perfil específico
arch-cli optimize --profile production
```

### 📋 Comandos Tradicionais
```bash
arch-cli deps      # Verificar dependências
arch-cli list      # Listar recursos AWS
arch-cli prowler   # Auditoria de segurança
arch-cli np        # Novo perfil AWS
```

## Exemplos de Uso

### Rotina Diária
```bash
#!/bin/bash
echo "🔍 Health check diário..."
arch-cli health --profile production

if [ $? -eq 0 ]; then
    echo "✅ Tudo OK!"
else
    echo "⚠️ Executando análise completa..."
    arch-cli analyze --profile production
fi
```

### Otimização Semanal
```bash
#!/bin/bash
echo "💰 Verificando oportunidades de economia..."
arch-cli optimize --profile production > weekly-savings.txt
echo "📊 Relatório salvo em weekly-savings.txt"
```

## Troubleshooting

### Erro de Credenciais
```bash
# Verificar configuração
aws configure list
aws sts get-caller-identity

# Reconfigurar se necessário
arch-cli np
```

### MCP Server Indisponível
```
🔄 Running in basic mode (MCP server not available)
```
**Normal**: Arch-CLI funciona perfeitamente sem MCP, apenas com funcionalidades básicas.

### Performance Lenta
```bash
# Use health check para verificações rápidas
arch-cli health

# Análise básica ao invés de comprehensive
arch-cli analyze  # ao invés de --comprehensive
```

## Próximos Passos

1. **Explore os comandos**: Teste `analyze`, `optimize`, `health`
2. **Configure perfis**: Use `arch-cli np` para múltiplas contas
3. **Automatize**: Crie scripts para rotinas diárias/semanais
4. **Monitore**: Use `arch-cli health` para monitoramento contínuo

## Suporte

- **Documentação completa**: `docs/MCP_USAGE.md`
- **Roadmap**: `ROADMAP_IMPLEMENTATION.md`
- **Logs**: `~/.arch-cli/arch-cli.log`

---

**🎉 Pronto! Você já pode usar o arch-cli com inteligência MCP!**
