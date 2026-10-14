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

---

## 📌 Checklist de Especificações Técnicas e Tarefas Pendentes (Para a Dupla)

Status atual do projeto com base nas especificações técnicas oficiais:

- [x] **A. Tipo de Dados e Accessors (`src/SimpleJSON.hs`):**
  - Definição da AST `JValue` e dos 7 acessadores seguros (`getString`, `getInt`, `getDouble`, `getBool`, `getObject`, `getArray`, `isNull`).
- [x] **B. Pretty Printer JSON (`src/Prettify.hs` e `src/PrettyJSON.hs`):**
  - Tipo abstrato `Doc`, combinadores de formatação, indentação de 2 espaços e escape completo (Unicode, controle e pares substitutos para plano astral).
- [x] **C. QuickCheck Base (`test/Spec.hs`):**
  - Instância `Arbitrary JValue` com gerador limitado por `resize (n `div` 2) (listOf ...)` para evitar consumo exponencial de memória.
  - 7 propriedades fundamentais já implementadas e verificadas.

---

### 📝 O que falta fazer (Ficará sob sua responsabilidade)

1. **Propriedades adicionais de QuickCheck no `test/Spec.hs`:**
   - **Corretude dos escapes:** Adicionar propriedade que gere strings aleatórias e valide que `renderJValue (JString s)` nunca contém caracteres de controle sem escape (como `\n`, `\t` ou caracteres `< ' '`) e sempre inicia e termina com aspas duplas `"`.
   - **Idempotência ou invariantes extras:** Adicionar propriedade testando invariantes adicionais mencionadas no tutorial (ex: idempotência de renderização).
   - Commit sugerido: `test: add escape correctness and idempotency properties`

2. **Garantir falha de exit code na suíte de testes (`test/Spec.hs`):**
   - Substituir as chamadas diretas de `quickCheck` por `quickCheckResult` com verificação via `unless (isSuccess res) (exitFailure)` (importando `System.Exit`), garantindo que o comando `cabal test` retorne código de erro se algum teste falhar na avaliação automatizada.
   - Commit sugerido: `test: enforce exitFailure on QuickCheck property failure`

3. **Expansão do Executável (`app/Main.hs`):**
   - Permitir receber argumentos pela linha de comando (`getArgs`) ou ler JSON da entrada padrão (`getContents`) para formatar dados externos.
   - Commit sugerido: `feat: add CLI options and stdin support to hs2json executable`

4. **Validação Final:**
   - Executar `cabal test` no ambiente para garantir que todas as asserções e propriedades passem com 100 testes cada.
