# Arquitetura da Plataforma Local

## Objetivo

Demonstrar uma entrega de plataforma reprodutível que atende provisionamento automatizado,
deploy automatizado, acesso externo, escalabilidade, resiliência e operação documentada.

## Topologia

O Terraform cria um cluster kind com um control-plane e três workers. Cilium substitui o CNI
padrão, aplica NetworkPolicies e publica o Ingress em `todolist.localhost`. O chart Helm entrega
três réplicas da TodoList, distribuídas entre workers, atrás de Service `ClusterIP` e Ingress.

CloudNativePG mantém primário e réplica em workers distintos. Argo CD reconcilia o chart Helm a
partir de `main`; somente uma imagem cujo digest tenha sido aprovado em pull request é implantada.

## Limites Deliberados

- Os volumes do kind são locais ao Docker Desktop e não constituem disaster recovery.
- O ambiente não tolera a perda do host ou do daemon Docker.
- Failover do PostgreSQL possui RTO de até 90 segundos; perda de worker com banco saudável possui
  orçamento de indisponibilidade de até 10 segundos.
- Prometheus retém apenas duas horas para caber no perfil de demonstração.

## Recursos

O perfil aprovado é Docker Desktop com 4 CPUs, 6 GiB RAM e 20 GiB de disco. Requests e limits
pequenos protegem o host e os testes são executados de forma sequencial.

## Fluxo de Release

GitHub Actions valida pull requests. Uma execução manual do workflow de release constrói imagem
multiarch, publica no GHCR, gera SBOM, assina via Cosign/OIDC e abre uma pull request de promoção
do digest. A revisão humana é obrigatória; nenhuma automação mescla alterações em `main`.

## Segurança

Kyverno bloqueia Deployments da aplicação que não atendam ao baseline restrito ou não possuam
imagem assinada por workflow GitHub Actions. RBAC é limitado ao namespace, segredos são montados
em arquivo e NetworkPolicy restringe tráfego a DNS, banco e Ingress Cilium.
