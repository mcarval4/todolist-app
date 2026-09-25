# ADR-005: GitHub App como identidade de produção

## Decisão

Usar PAT fine-grained somente na demonstração e GitHub App em produção.

## Consequências

Produção não depende da identidade de uma pessoa. Tokens de instalação têm vida curta e permissões
limitadas; a chave privada exige gestão, rotação e auditoria.
