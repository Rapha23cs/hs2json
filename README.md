# hs2json

Um projeto Haskell para manipulação e formatação (*pretty-printing*) de JSON, desenvolvido como projeto em dupla e guiado pelo tutorial da LambdaGeo.

Este projeto tem como foco aplicar conceitos modernos de desenvolvimento em Haskell, incluindo:
- **Modularização com Cabal:** Separação clara entre biblioteca (`src`), executável (`app`) e testes (`test`).
- **Testes Baseados em Propriedades:** Uso da biblioteca QuickCheck para garantir a integridade das funções de formatação.

## Estrutura do Projeto

- `src/JSON.hs`: Definição da Árvore de Sintaxe Abstrata (AST) para os valores JSON (`JValue`).
- `src/SimpleJSON.hs`: Interface compatível com o tutorial, reexportando o mesmo `JValue` e fornecendo accessors seguros.
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

Para executar as verificações de formatação e accessors:
```bash
cabal test
```

No Windows, prefira o caminho curto padrão `C:\ghcup` para as ferramentas,
evitando limites de comprimento de caminhos durante a instalação. O projeto
pode permanecer em Documentos.

---

## 📝 Etapas e combinados da dupla

A fundação do projeto (AST e estrutura do Cabal), o pretty printing com combinadores `Doc` e os acessadores seguros em `SimpleJSON` já estão implementados na branch `main`.

A suíte de testes em `test/Spec.hs` executa 29 asserções determinísticas e 7 propriedades com QuickCheck via `cabal test`.

### Testes com QuickCheck

O gerador `Arbitrary JValue` foi construído com controle de tamanho (`sized` e `resize`) para limitar a profundidade de recursão em `JArray` e `JObject`.

As seguintes propriedades são testadas:
- `prop_renderNotEmpty`: qualquer valor JSON produz texto não-vazio.
- `prop_renderDelimiters`: arrays e objetos sempre respeitam os delimitadores `[]` e `{}`.
- `prop_isNullConsistent`: coerência entre `Simple.isNull v` e `v == JNull`.
- `prop_getStringRoundtrip`: recuperação de strings via `getString`.
- `prop_getBoolRoundtrip`: recuperação de booleanos via `getBool`.
- `prop_getArrayRoundtrip`: preservação da lista de elementos via `getArray`.
- `prop_getObjectRoundtrip`: preservação dos campos de chave-valor via `getObject`.

### Comportamento do pretty printer

`renderJValue :: JValue -> String` usa documentos `Doc` internamente e produz JSON
com indentação de dois espaços, sem vírgulas finais. Caracteres de controle e
Unicode são escapados, incluindo pares substitutos para caracteres acima de
U+FFFF. Objetos e arrays vazios são impressos como `{}` e `[]`. Números `NaN` e
infinitos são representados como `null`, pois não existem no formato JSON.
O executável demonstra valores aninhados e escapes.

### Accessors seguros

Importe `SimpleJSON` para usar `getString`, `getInt`, `getDouble`, `getBool`,
`getObject`, `getArray` e `isNull`. Os accessors retornam `Just` para o tipo
correspondente e `Nothing` para tipos incompatíveis; `isNull` retorna `Bool`.
`getInt` trunca a parte decimal em direção a zero (`5.8` vira `Just 5` e `-5.8`
vira `Just (-5)`). Números não finitos ou resultados fora do intervalo de `Int`
retornam `Nothing`. `getDouble` preserva o número armazenado.

`JSON` continua disponível para os imports existentes; `SimpleJSON` reexporta
seus construtores, sem criar um segundo tipo `JValue`.

1. **Desenvolver o Pretty Printing:** 
   - Garanta que a função `renderJValue :: JValue -> String` esteja corretamente implementada no arquivo `src/PrettyJSON.hs`.
   - Se certifique que o `app/Main.hs` faz uso dessa função para testar o output.
2. **Realizar o Commit:**
   - Após revisar os arquivos da Parte 2 (Pretty Printing), faça o commit dessas alterações utilizando a nomenclatura oficial (`feat:`). 
   - Exemplo de comando: `git commit -m "feat: implement JSON pretty printing"`
3. **Enviar (Push):**
   - Suba suas alterações para a nuvem com `git push origin main`.
