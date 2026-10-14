# hs2json

Um projeto Haskell para manipulação e formatação (*pretty-printing*) de JSON, desenvolvido como projeto em dupla e guiado pelo tutorial da LambdaGeo.

Este projeto tem como foco aplicar conceitos modernos de desenvolvimento em Haskell, incluindo:
- **Modularização com Cabal:** Separação clara entre biblioteca (`src`), executável (`app`) e testes (`test`).
- **Testes Baseados em Propriedades:** Uso da biblioteca QuickCheck para garantir a integridade das funções de formatação.

## Estrutura do Projeto

- `src/JSON.hs`: Definição da Árvore de Sintaxe Abstrata (AST) para os valores JSON (`JValue`).
- `src/Prettify.hs`: Biblioteca de documentos (`Doc`) e combinadores de formatação com indentação.
- `src/PrettyJSON.hs`: Módulo responsável por converter os valores JSON em strings legíveis.
- `app/Main.hs`: Ponto de entrada do executável.
- `test/Spec.hs`: Arquivo principal da suíte de testes.

## Como Executar

Certifique-se de ter o `cabal` e o `GHC` (ou o `GHCup`) instalados.

Para compilar o projeto:
```bash
cabal build
```

Para rodar o executável:
```bash
cabal run hs2json
```

Para executar as verificações de formatação:
```bash
cabal test
```

No Windows, prefira o caminho curto padrão `C:\ghcup` para as ferramentas,
evitando limites de comprimento de caminhos durante a instalação. O projeto
pode permanecer em Documentos.

---

## 📝 Combinado da etapa de Pretty Printing (concluída)

A fundação do projeto (AST e estrutura do Cabal) já está pronta e na branch `main`.
O passo de pretty printing descrito abaixo está implementado e serve como registro
do combinado entre a dupla. Há verificações determinísticas de formatação via
`cabal test`; os próximos passos são os accessors e as propriedades com QuickCheck.

### Comportamento do pretty printer

`renderJValue :: JValue -> String` usa documentos `Doc` internamente e produz JSON
com indentação de dois espaços, sem vírgulas finais. Caracteres de controle e
Unicode são escapados, incluindo pares substitutos para caracteres acima de
U+FFFF. Objetos e arrays vazios são impressos como `{}` e `[]`. Números `NaN` e
infinitos são representados como `null`, pois não existem no formato JSON.
O executável demonstra valores aninhados e escapes.

1. **Desenvolver o Pretty Printing:** 
   - Garanta que a função `renderJValue :: JValue -> String` esteja corretamente implementada no arquivo `src/PrettyJSON.hs`.
   - Se certifique que o `app/Main.hs` faz uso dessa função para testar o output.
2. **Realizar o Commit:**
   - Após revisar os arquivos da Parte 2 (Pretty Printing), faça o commit dessas alterações utilizando a nomenclatura oficial (`feat:`). 
   - Exemplo de comando: `git commit -m "feat: implement JSON pretty printing"`
3. **Enviar (Push):**
   - Suba suas alterações para a nuvem com `git push origin main`.
