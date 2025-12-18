# 🤖 Arch-CLI com MCP - Guia de Uso

## Visão Geral
A integração MCP (Model Context Protocol) adiciona inteligência artificial ao arch-cli, fornecendo análises avançadas e recomendações inteligentes para sua infraestrutura AWS.

## Novos Comandos

### 🔍 `arch-cli analyze`
Análise inteligente completa da infraestrutura AWS

```bash
# Análise básica (rápida)
arch-cli analyze

# Análise abrangente (detalhada)
arch-cli analyze --comprehensive

# Análise com perfil específico
arch-cli analyze --profile production
```

**Saída esperada:**
```
🤖 AI-Enhanced AWS Infrastructure Analysis

💰 Cost Analysis
┌─────────────────────┬──────────────┐
│ Metric              │ Value        │
├─────────────────────┼──────────────┤
│ Total Monthly Cost  │ $1,250.50    │
│ Potential Savings   │ $340.20      │
└─────────────────────┴──────────────┘

💡 Cost Recommendations:
  • Consider Reserved Instances for stable workloads
  • Enable auto-scaling for variable workloads

🔒 Security Analysis
Security Score: 78%
⚠️  1 open security groups found
⚠️  2 users without MFA

🛡️  Security Recommendations:
  • Enable MFA for all IAM users
  • Restrict SSH access to specific IP ranges
```

### ⚡ `arch-cli optimize`
Otimização inteligente de recursos com economia de custos

```bash
# Otimização geral
arch-cli optimize

# Otimização com perfil específico
arch-cli optimize --profile staging
```

**Saída esperada:**
```
⚡ Resource Optimization Results

💰 Potential monthly savings: $450.75

📊 Found 3 underutilized resources:
  • i-abcdef1234567890 - Save $89.50/month
  • i-1234567890abcdef - Save $156.25/month
  • i-fedcba0987654321 - Save $205.00/month

💡 Recommendations:
  • Downsize underutilized instances
  • Consider using Auto Scaling Groups
  • Monitor CloudWatch metrics regularly
```

### 🏥 `arch-cli health`
Verificação rápida de saúde da infraestrutura

```bash
# Health check básico
arch-cli health

# Health check com perfil específico
arch-cli health --profile production
```

**Saída esperada:**
```
🏥 AWS Infrastructure Health Check

MCP Status: 🤖 Available
Monthly Cost: $1,250.50
Security Issues: 3
✅ Overall Status: Healthy
```

## Modos de Operação

### 🤖 Modo AI-Enhanced (com MCP)
Quando um servidor MCP está disponível:
- Análises preditivas avançadas
- Recomendações baseadas em ML
- Correlação inteligente de dados
- Insights contextuais profundos

### 📊 Modo Basic (sem MCP)
Quando MCP não está disponível:
- Análises baseadas em regras
- Recomendações básicas
- Funcionalidade completa mantida
- Graceful degradation

## Integração com Comandos Existentes

Os novos comandos MCP complementam os comandos bash existentes:

```bash
# Comandos tradicionais (bash)
arch-cli deps          # Verificar dependências
arch-cli prowler       # Auditoria Prowler
arch-cli list          # Listar recursos

# Novos comandos inteligentes (Python + MCP)
arch-cli analyze       # Análise AI-powered
arch-cli optimize      # Otimização inteligente
arch-cli health        # Health check rápido
```

## Configuração

### Perfis AWS
```bash
# Usar perfil padrão
arch-cli analyze

# Usar perfil específico
arch-cli analyze --profile production
arch-cli optimize --profile staging
arch-cli health --profile development
```

### Logs e Debug
Os logs são mantidos em `~/.arch-cli/arch-cli.log`:

```bash
# Ver logs em tempo real
tail -f ~/.arch-cli/arch-cli.log

# Filtrar logs MCP
grep "MCP" ~/.arch-cli/arch-cli.log
```

## Exemplos Práticos

### Análise de Custos Diária
```bash
#!/bin/bash
# daily-cost-check.sh

echo "🔍 Verificação diária de custos..."
arch-cli health --profile production

if [ $? -eq 0 ]; then
    echo "✅ Infraestrutura saudável"
else
    echo "⚠️  Problemas detectados, executando análise completa..."
    arch-cli analyze --comprehensive --profile production
fi
```

### Otimização Semanal
```bash
#!/bin/bash
# weekly-optimization.sh

echo "⚡ Otimização semanal de recursos..."
arch-cli optimize --profile production > weekly-optimization-report.txt

# Enviar relatório por email (exemplo)
mail -s "Weekly AWS Optimization Report" admin@company.com < weekly-optimization-report.txt
```

### CI/CD Integration
```yaml
# .github/workflows/aws-health-check.yml
name: AWS Health Check
on:
  schedule:
    - cron: '0 9 * * 1'  # Segunda-feira às 9h

jobs:
  health-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Arch-CLI
        run: pip install -e .
      - name: Run Health Check
        run: |
          arch-cli health --profile production
          arch-cli analyze --profile production > aws-analysis.json
      - name: Upload Results
        uses: actions/upload-artifact@v2
        with:
          name: aws-analysis
          path: aws-analysis.json
```

## Troubleshooting

### MCP Server Não Disponível
```
🔄 Running in basic mode (MCP server not available)
💡 For enhanced AI-powered insights, ensure MCP server is running
📊 Basic analysis and recommendations provided below
```

**Solução**: O arch-cli continua funcionando normalmente em modo básico.

### Erro de Credenciais AWS
```bash
# Verificar configuração AWS
aws configure list

# Testar credenciais
aws sts get-caller-identity
```

### Performance Lenta
```bash
# Usar análise rápida
arch-cli analyze  # ao invés de --comprehensive

# Usar health check para verificações rápidas
arch-cli health
```

## Próximos Passos

A Fase 1 implementa a base MCP. Próximas fases incluirão:

- **Fase 2**: Análise preditiva e auto-remediação
- **Fase 3**: Workflows adaptativos e interface natural language

Acompanhe o progresso em `ROADMAP_IMPLEMENTATION.md`.
