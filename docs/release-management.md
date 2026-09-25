# Gestão de Releases

## Versionamento

O release-please interpreta Conventional Commits em `main` e cria uma PR de versão. Ele atualiza
`VERSION` e o changelog, mas não cria tag ou GitHub Release: `skip-github-release` mantém a
publicação final dependente do deployment validado.

A primeira versão planejada é `v1.0.0`. `feat` gera incremento minor, `fix` gera patch e commits
com `!` geram major. A PR de versão continua sujeita à ruleset e à aprovação humana.

## Publicação

Após a PR de versão ser aprovada, seu merge gera a imagem e abre a PR de digest. O merge do digest
implanta e testa a imagem no runner local, então cria automaticamente a tag anotada e a GitHub
Release. A publicação falha se smoke, HA ou RBAC falhar.

Isso garante que uma tag representa estado já implantado e validado, não apenas uma imagem
construída.
