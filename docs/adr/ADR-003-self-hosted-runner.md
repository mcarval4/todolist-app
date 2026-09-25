# ADR-003: Runner local dedicado ao kind

## Decisão

Usar um GitHub Actions self-hosted runner persistente no MacBook, exclusivo ao repositório e com
labels `macos` e `local-kind`.

## Consequências

Deploy e testes de caos alcançam o kind local. A máquina é uma dependência operacional e não deve
executar workflows de PR ou forks.
