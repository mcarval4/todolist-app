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

1. Mescle a pull request da feature e a pull request de promoção do digest, ambas após revisão
   humana.
2. Confirme que Argo CD sincronizou o digest e que os testes operacionais foram aprovados.
3. Crie uma tag anotada no commit de `main` que contém o digest implantado:

   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

O workflow `Publish SemVer Release` verifica que a tag pertence a `main`, valida assinatura Cosign
e atestado SPDX, então cria a GitHub Release. Uma tag que aponte para digest de placeholder ou
artefato não assinado falha antes da publicação.

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
