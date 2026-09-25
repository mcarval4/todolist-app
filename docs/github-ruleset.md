# GitHub Ruleset Necessário

O repositório possui uma ruleset ativa, `Protect main`, para `main`. Forks ou repositórios que
reutilizem esta plataforma devem configurar uma equivalente antes da primeira promoção de imagem:

- Bloquear push direto e exigir pull request.
- Exigir ao menos uma aprovação humana.
- Exigir que a aprovação seja descartada em novo push.
- Exigir o check `Verify / verify`.
- Bloquear force push e exclusão da branch.
- Restringir bypass a administradores explicitamente autorizados.

Essa configuração é feita por uma pessoa com permissão administrativa no GitHub. Ela não é aplicada
por workflows, para evitar que automação altere regras de proteção sem revisão humana.

## Exceção de Demonstração

Neste repositório de demonstração, `mcarval4` possui bypass limitado a merge por pull request. Push
direto, force push e exclusão de `main` continuam bloqueados, e o check `Verify / verify` permanece
obrigatório. A exceção permite concluir a demonstração quando não há um segundo revisor disponível.

Em produção, o autor não aprova nem mescla a própria pull request. O bypass é desabilitado para
desenvolvedores e só pode ser usado em incidente ou exceção formal por um administrador de
plataforma autorizado, com justificativa e registro de auditoria.
