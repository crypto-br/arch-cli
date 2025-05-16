# Contribuindo para o Arch CLI

Obrigado pelo interesse em contribuir para o Arch CLI! Este documento fornece diretrizes para contribuir com o projeto.

## Como Contribuir

### Reportando Bugs

Se você encontrou um bug, por favor, crie uma issue com os seguintes detalhes:

1. Um título claro e descritivo
2. Passos detalhados para reproduzir o bug
3. Comportamento esperado
4. Comportamento atual
5. Ambiente (sistema operacional, versão do bash, etc.)
6. Capturas de tela, se aplicável

### Sugerindo Melhorias

Para sugerir melhorias, crie uma issue com:

1. Um título claro e descritivo
2. Descrição detalhada da melhoria proposta
3. Justificativa para a melhoria
4. Exemplos de uso, se aplicável

### Pull Requests

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nome-da-feature`)
3. Faça commit das suas alterações (`git commit -m 'Adiciona nova feature'`)
4. Faça push para a branch (`git push origin feature/nome-da-feature`)
5. Abra um Pull Request

## Padrões de Código

### Shell Script

- Use 4 espaços para indentação
- Adicione comentários para explicar o código
- Siga as [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Teste seu código antes de enviar

### Documentação

- Mantenha a documentação atualizada
- Use markdown para formatação
- Seja claro e conciso

## Estrutura do Projeto

```
arch-cli/
├── arch-cli.sh              # Script principal
├── modules/                 # Módulos separados por funcionalidade
│   ├── utils.sh             # Funções utilitárias
│   ├── dependencies.sh      # Verificação de dependências
│   └── ...                  # Outros módulos
├── README.md                # Documentação principal
├── CHANGELOG.md             # Registro de alterações
└── CONTRIBUTING.md          # Guia de contribuição
```

## Processo de Desenvolvimento

1. Escolha uma issue para trabalhar
2. Discuta a abordagem na issue
3. Implemente a solução
4. Teste a solução
5. Envie um Pull Request
6. Aguarde a revisão

## Testes

- Teste suas alterações em diferentes sistemas operacionais, se possível
- Verifique se todas as funcionalidades existentes continuam funcionando
- Adicione testes para novas funcionalidades

## Versionamento

Este projeto segue o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

- MAJOR: Alterações incompatíveis com versões anteriores
- MINOR: Adição de funcionalidades compatíveis com versões anteriores
- PATCH: Correções de bugs compatíveis com versões anteriores

## Licença

Ao contribuir para este projeto, você concorda que suas contribuições serão licenciadas sob a mesma licença do projeto.
