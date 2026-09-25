# ADR-004: Release-please separado da publicação final

## Decisão

Usar release-please para criar PR de versão, com `skip-github-release: true`. A tag e GitHub
Release são criadas pelo workflow local somente depois do deployment e testes aprovados.

## Consequências

Uma versão representa artefato implantado e testado. O fluxo introduz uma segunda PR aprovada por
release, em troca de rastreabilidade e gate explícito.
