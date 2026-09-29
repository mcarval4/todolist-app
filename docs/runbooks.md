# Runbooks

## Criar o ambiente

1. Inicie Docker Desktop com o perfil de recursos documentado no README.
2. Exporte `TF_VAR_git_repository_url` com a URL HTTPS do repositório.
3. Execute `make bootstrap`.
4. Aguarde Argo CD sincronizar a aplicação aprovada em `main`.

## Executar testes de resiliência

Execute `make test-ha`. O script mantém requisições a `/healthz`, executa rollout, remove uma
réplica e interrompe um worker. O worker é reiniciado automaticamente pelo trap de limpeza.

O teste de failover do banco deve ser conduzido separadamente durante a apresentação, pois seu RTO
aceitável é diferente do teste de continuidade da camada stateless.

## Destruir o ambiente

Execute `make destroy`. Isso remove recursos Terraform e o cluster kind local. Evidências devem
ser coletadas antes com `make evidence`.

## Publicar uma release SemVer

1. Mescle a pull request da feature após revisão humana. O release-please abre a pull request de
   versão com `VERSION` e changelog calculados pelos Conventional Commits.
2. Revise e mescle a pull request de versão. O workflow de build publica imagem multiarch, gera
   SBOM, assina via Cosign/OIDC e abre uma pull request de promoção do digest.
3. Revise e mescle a pull request de digest. Argo CD sincroniza o chart e o runner `local-kind`
   executa smoke test, HA, RBAC e coleta de evidências.
4. Se todos os gates passarem, `Deploy And Verify Local Platform` cria automaticamente a tag
   anotada e a GitHub Release. Não crie tags manualmente para esse fluxo.

Se o deployment ou um teste falhar, a tag não é criada. Corrija em uma nova pull request e repita a
promoção pelo fluxo GitOps.

O pacote GHCR deve ser público para o ambiente local permanecer replicável sem credenciais de
registro. Para uma imagem privada, crie um `imagePullSecret` fora do Git e configure o chart antes
da promoção.

## Runner indisponível

1. Confirme que o MacBook está ligado e Docker Desktop está pronto.
2. Verifique o runner e o cluster conforme `docs/self-hosted-runner.md`.
3. Não cancele o job automaticamente antes de 24 horas de indisponibilidade.
4. Após recuperar o host, use `workflow_dispatch` para reexecutar apenas se o workflow não retomar.

## Falha de deployment ou teste

1. Consulte o artefato `local-platform-evidence-<run-id>` no GitHub Actions.
2. Verifique `kubectl describe application/todolist -n argocd` e eventos do namespace.
3. Corrija em nova feature branch; não altere manifests diretamente no cluster.
4. Use a reversão GitOps por pull request para retornar ao digest anterior, se necessário.
