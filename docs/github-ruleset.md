# GitHub Ruleset Necessário

O repositório deve configurar uma ruleset para `main` antes da primeira promoção de imagem:

- Bloquear push direto e exigir pull request.
- Exigir ao menos uma aprovação humana.
- Exigir que a aprovação seja descartada em novo push.
- Exigir o check `Verify / verify`.
- Bloquear force push e exclusão da branch.
- Restringir bypass a administradores explicitamente autorizados.

Essa configuração é feita por uma pessoa com permissão administrativa no GitHub. Ela não é aplicada
por este repositório para evitar que automação altere regras de proteção sem revisão humana.
