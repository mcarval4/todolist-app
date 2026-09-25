# ADR-002: GitOps com revisão humana obrigatória

## Decisão

Argo CD observa somente `main`. A promoção de um digest é sempre uma pull request criada pelo
workflow de release e requer revisão humana antes de qualquer merge.

## Consequências

Há uma etapa explícita de aprovação, mas o estado implantado permanece auditável e não existem
alterações automatizadas diretamente em `main`.
