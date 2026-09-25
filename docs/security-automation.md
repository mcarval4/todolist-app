# Segurança da Automação

## Demonstração

`RELEASE_PLEASE_TOKEN` é um fine-grained PAT temporário, limitado a este repositório e com
permissões `Contents`, `Pull requests` e `Issues` de leitura/escrita. Ele permite que a PR criada
por release-please dispare o workflow `Verify`. O token é um GitHub Actions secret e nunca entra no
Git, logs ou evidências.

O wizard `scripts/setup-automation.sh` guiará sua criação, armazenamento e a instalação do runner.
Revogue e recrie o token se houver suspeita de exposição.

## Produção

Produção não usa PAT individual. A identidade de release é uma GitHub App instalada apenas nos
repositórios necessários, com permissões mínimas equivalentes. A App emite tokens de instalação
temporários; sua chave privada fica em secret manager corporativo, com rotação e auditoria.

A GitHub App não recebe bypass de ruleset. Bypass em produção é reservado a incidente ou exceção
formal, executado por administrador de plataforma autorizado e registrado para auditoria.
