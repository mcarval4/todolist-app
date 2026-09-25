# ADR-001: kind como ambiente de demonstração

## Decisão

Usar kind com um control-plane e três workers, criado por Terraform.

## Contexto

O desafio permite ambiente local e requer cluster Kubernetes provisionado por código. A topologia
permite testar distribuição de pods e perda controlada de worker com recursos compatíveis com um
MacBook Air M4 de 16 GiB.

## Consequências

O ambiente é econômico e reproduzível, mas Docker Desktop e o host são pontos únicos de falha.
