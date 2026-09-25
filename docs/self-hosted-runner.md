# Self-Hosted Runner Local

## Finalidade

O runner `local-kind` executa deployment e testes que dependem do cluster kind no MacBook. Ele não
executa workflows de pull request ou código de forks; somente workflows disparados por merge em
`main` podem usar seus labels.

## Requisitos

- macOS ARM64 com Docker Desktop iniciado após login
- `git`, `docker`, `kind`, `kubectl`, `helm`, `terraform` e `make` no `PATH`
- Cluster `todolist-demo` criado e contexto Kubernetes disponível
- Runner registrado exclusivamente neste repositório com labels `macos` e `local-kind`
- Serviço `launchd` ativo para reiniciar o runner após reboot/login

Execute `./scripts/setup-automation.sh` para validar os pré-requisitos, criar o secret de
release-please, registrar o runner e instalar o LaunchAgent. O wizard não deve ser executado por
CI e requer uma pessoa presente para emitir o PAT e confirmar a instalação do serviço.

## Execução

O workflow `Deploy And Verify Local Platform` usa `concurrency` para impedir testes destrutivos
simultâneos. Ele aguarda Argo CD, verifica `/healthz`, executa HA/RBAC, coleta evidências e as envia
ao GitHub por 30 dias. Se o MacBook estiver indisponível, o job permanece na fila; o runbook deve
ser consultado se a fila exceder 24 horas.

## Recuperação

1. Inicie Docker Desktop e confirme `docker info`.
2. Confirme `kind get clusters` e `kubectl get nodes`.
3. Verifique o serviço do runner em `~/Library/LaunchAgents/`.
4. Reexecute o workflow de deployment por `workflow_dispatch` somente após investigar a falha.
