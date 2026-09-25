# CI/CD

## Gates Humanos e Automação

| Evento | Gatilho | Executor | Resultado |
|---|---|---|---|
| PR de feature | Abertura ou atualização de PR | GitHub-hosted runner | Validação de Terraform, Helm, Python, imagem e workflows |
| Merge de feature | Aprovação e merge em `main` | release-please | PR com changelog e `VERSION` calculado por Conventional Commits |
| Merge de versão | Aprovação e merge em `main` | GitHub-hosted runner | Imagem multiarch, SBOM, assinatura Cosign e PR de digest |
| Merge de digest | Aprovação e merge em `main` | Runner `local-kind` | Argo CD, smoke, HA, RBAC, evidências, tag e GitHub Release |

Nenhum workflow faz merge em `main`. A ruleset controla os gates humanos. O bypass de demonstração
continua limitado a merge via PR e não representa a política de produção.

## Imagem

`Build And Propose Release` é acionado automaticamente pelo merge da PR de versão, que altera
`VERSION` em `main`. Ele publica imagem `linux/amd64` e `linux/arm64`,
`charts/todolist/values-demo.yaml`.

O pacote GHCR deve ser público no ambiente de demonstração para que o kind local faça pull sem
credencial. Produção usa credencial de registro e `imagePullSecret` gerenciado fora do Git.
