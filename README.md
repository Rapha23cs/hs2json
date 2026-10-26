# hs2json

Biblioteca e ferramenta de linha de comando em **Haskell** para ler, representar e formatar (*pretty-printing*) documentos JSON, com testes baseados em propriedades via **QuickCheck**.

Projeto em dupla, desenvolvido a partir do tutorial oficial da LambdaGeo: [Construindo e testando uma biblioteca Haskell: JSON, Pretty Printing e QuickCheck](https://lambdageo-edu.github.io/lambdageo-tutorials/haskell/).

## 🎥 Vídeo de demonstração

[Assista à demonstração do projeto rodando (`cabal build`, `cabal test`, `cabal run`)](https://drive.google.com/file/d/1VKUELSeop1dJsF09Vwv8mCIzpUFU4hjI/view?usp=sharing)

## 👥 Autores

- Raphael Sá ([@Rapha23cs](https://github.com/Rapha23cs))
- Daniel Lucas Silva Aires ([@DanielLSA](https://github.com/DanielLSA))

O histórico de commits do repositório mostra a contribuição incremental de cada integrante.

---

## 📚 Sumário

- [Funcionalidades](#-funcionalidades)
- [Estrutura do projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Compilar, testar e executar](#-compilar-testar-e-executar)
- [Uso da CLI](#-uso-da-cli)
- [Exemplo de entrada e saída](#-exemplo-de-entrada-e-saída)
- [API da biblioteca](#-api-da-biblioteca)
- [Testes](#-testes)
- [Decisões de projeto](#-decisões-de-projeto)
- [Fluxo de trabalho da dupla](#-fluxo-de-trabalho-da-dupla)

---

## ✨ Funcionalidades

- **AST de JSON** (`JValue`) com os seis construtores canônicos: string, número, booleano, nulo, array e objeto.
- **Accessors seguros** (`getString`, `getInt`, `getDouble`, `getBool`, `getObject`, `getArray`, `isNull`) que retornam `Maybe` em vez de falhar.
- **Pretty printer** baseado em um tipo abstrato `Doc`, com indentação de 2 espaços e quebras de linha para legibilidade.
- **Escape correto de strings**: `\n`, `\t`, aspas, barras, caracteres de controle, Unicode BMP e pares substitutos UTF-16 para caracteres acima de U+FFFF (como emojis).
- **Parser de JSON** (`ParseJSON.parseJSON`) escrito com `ReadP`, que já faz parte do `base`, sem dependências externas.
- **CLI** que lê JSON por argumento, arquivo ou entrada padrão.
- **Testes** determinísticos, de propriedades (QuickCheck) e de integração com o executável real.

## 🗂 Estrutura do projeto

```text
hs2json/
├── hs2json.cabal          # Biblioteca, executável e suítes de teste
├── CHANGELOG.md
├── app/
│   └── Main.hs            # Executável (CLI)
├── src/
│   ├── JSON.hs            # Definição da AST (JValue)
│   ├── SimpleJSON.hs      # Interface do tutorial: reexporta JValue + accessors seguros
│   ├── ParseJSON.hs       # Parser: String -> Either String JValue
│   ├── Prettify.hs        # Biblioteca de documentos (Doc) e combinadores
│   └── PrettyJSON.hs      # Renderização de JValue em texto
├── test/
│   ├── Spec.hs            # Testes determinísticos + propriedades QuickCheck
│   └── CLISpec.hs         # Parser e testes de integração da CLI
├── examples/
│   └── entrada.json       # JSON de exemplo para a CLI
└── docs/
    └── CLI.md             # Contrato detalhado da CLI
```

Componentes definidos em [hs2json.cabal](hs2json.cabal):

| Componente | Nome | Descrição |
| :--- | :--- | :--- |
| `library` | `hs2json` | Módulos expostos: `JSON`, `SimpleJSON`, `ParseJSON`, `Prettify`, `PrettyJSON` |
| `executable` | `hs2json` | CLI em `app/Main.hs` |
| `test-suite` | `hs2json-test` | `test/Spec.hs` — asserções e propriedades QuickCheck |
| `test-suite` | `hs2json-cli-test` | `test/CLISpec.hs` — parser e CLI de ponta a ponta |

Todos os componentes compilam com `-Wall`.

## 🧰 Pré-requisitos

- **GHC** e **Cabal**, instalados preferencialmente pelo [GHCup](https://www.haskell.org/ghcup/).
- No Windows, prefira o caminho curto padrão `C:\ghcup` para evitar limites de comprimento de caminhos durante a instalação.

Verifique a instalação:

```bash
ghc --version
cabal --version
```

## 🚀 Compilar, testar e executar

Na raiz do repositório:

```bash
cabal build all     # compila biblioteca, executável e testes
cabal test all --test-show-details=direct   # roda as duas suítes de teste
cabal run hs2json   # executa a demonstração
```

## 💻 Uso da CLI

Os argumentos depois de `--` são repassados ao executável. `-v0` reduz as mensagens do Cabal e deixa apenas a saída do programa.

```bash
# Ajuda e demonstração original
cabal run -v0 hs2json -- --help
cabal run -v0 hs2json -- --example

# JSON passado como argumento
cabal run -v0 hs2json -- --json '[1,true,null]'

# Arquivo JSON (UTF-8)
cabal run -v0 hs2json -- --file examples/entrada.json

# Entrada padrão (lê até EOF)
echo '{"nome":"Ana","ativo":true}' | cabal run -v0 hs2json -- -
```

| Opção | Descrição |
| :--- | :--- |
| `--json TEXTO` | Formata um JSON recebido como argumento |
| `--file ARQUIVO` | Lê um arquivo JSON em UTF-8 (BOM inicial tolerado) |
| `-` | Lê JSON da entrada padrão até o fim |
| `--example` | Mostra a demonstração original |
| `--help` | Mostra a ajuda |

> [!NOTE]
> O nome do arquivo precisa vir depois de `--file`. Passar apenas o nome do arquivo resulta em `Argumentos invalidos.`

Em caso de JSON inválido, a mensagem de erro vai para `stderr` e o processo termina com código de saída diferente de zero. Os detalhes do contrato (limites, números, Unicode) estão em [docs/CLI.md](docs/CLI.md).

## 🔎 Exemplo de entrada e saída

Entrada ([examples/entrada.json](examples/entrada.json)):

```json
{"nome":"Ana","ativo":true,"itens":[1,2,3],"mensagem":"Olá\nHaskell 😀"}
```

Comando:

```bash
cabal run -v0 hs2json -- --file examples/entrada.json
```

Saída:

```json
{
  "nome": "Ana",
  "ativo": true,
  "itens": [
    1.0,
    2.0,
    3.0
  ],
  "mensagem": "Ol\u00e1\nHaskell \ud83d\ude00"
}
```

O emoji vira o par substituto `\ud83d\ude00` e os números são impressos como `Double` (`1.0`).

## 📖 API da biblioteca

```haskell
import SimpleJSON (JValue(..), getString, getInt, isNull)
import PrettyJSON (renderJValue)
import ParseJSON  (parseJSON)

data JValue
  = JString String
  | JNumber Double
  | JBool Bool
  | JNull
  | JObject [(String, JValue)]
  | JArray [JValue]

renderJValue :: JValue -> String
parseJSON    :: String -> Either String JValue
```

### Accessors (`SimpleJSON`)

| Função | Tipo |
| :--- | :--- |
| `getString` | `JValue -> Maybe String` |
| `getInt` | `JValue -> Maybe Int` |
| `getDouble` | `JValue -> Maybe Double` |
| `getBool` | `JValue -> Maybe Bool` |
| `getObject` | `JValue -> Maybe [(String, JValue)]` |
| `getArray` | `JValue -> Maybe [JValue]` |
| `isNull` | `JValue -> Bool` |

- Tipos incompatíveis retornam `Nothing`.
- `getInt` trunca a parte decimal em direção a zero (`5.8` vira `Just 5` e `-5.8` vira `Just (-5)`).
- `getInt` retorna `Nothing` para `NaN`, infinitos e valores fora do intervalo de `Int`.

### Pretty printer

`renderJValue` usa documentos `Doc` internamente (`Prettify`) e produz JSON com indentação de dois espaços e sem vírgulas finais. Objetos e arrays vazios saem como `{}` e `[]`. `NaN` e infinitos são impressos como `null`, pois não existem no formato JSON.

`Prettify` expõe os combinadores `empty`, `char`, `text`, `double`, `line`, `<>`, `hcat`, `fsep`, `</>`, `punctuate`, `group`, `softline`, `nest`, `compact` e `pretty`.

### Parser

`parseJSON` consome exatamente um valor JSON. Entrada vazia, conteúdo extra e sintaxe incompleta são erros. Substitutos Unicode isolados são rejeitados e pares substitutos são combinados.

## 🧪 Testes

```bash
cabal test all --test-show-details=direct
```

### `hs2json-test` ([test/Spec.hs](test/Spec.hs))

- **29 asserções determinísticas**: 16 de pretty printing (escapes, Unicode, indentação, `Doc`) e 13 de accessors.
- **9 propriedades QuickCheck**:

| # | Propriedade | O que verifica |
| :-: | :--- | :--- |
| 1 | `prop_renderNotEmpty` | Qualquer JSON renderizado é não vazio |
| 2 | `prop_renderDelimiters` | Objetos e arrays começam e terminam com `{}` e `[]` |
| 3 | `prop_isNullConsistent` | `isNull v` equivale a `v == JNull` |
| 4 | `prop_getStringRoundtrip` | `getString (JString s) == Just s` |
| 5 | `prop_getBoolRoundtrip` | `getBool (JBool b) == Just b` |
| 6 | `prop_getArrayRoundtrip` | `getArray` preserva a lista de elementos |
| 7 | `prop_getObjectRoundtrip` | `getObject` preserva os pares chave-valor |
| 8 | `prop_stringEscapes` | Strings saem entre aspas, sem controles crus e com escapes JSON válidos |
| 9 | `prop_groupIdempotent` | `group (group d)` produz o mesmo layout que `group d` |

Cada propriedade roda 100 casos aleatórios e é executada por uma função auxiliar com `quickCheckResult` e `exitFailure`, então qualquer falha faz o `cabal test` retornar erro.

### `hs2json-cli-test` ([test/CLISpec.hs](test/CLISpec.hs))

- Parser: valores válidos, ida e volta (`parseJSON` e `renderJValue`) e entradas inválidas.
- CLI chamando o executável real: `--json`, `--file` (incluindo caminho com espaços), UTF-8, BOM, entrada padrão, `--help`, `--example` e códigos de saída de erro.

## 🧠 Decisões de projeto

- **Gerador `Arbitrary JValue` limitado.** `JValue` é recursivo via listas (`JArray` e `JObject`). Usar apenas `sized` não basta, porque `listOf` usa o tamanho ambiente do QuickCheck (até 100) e a árvore cresce exponencialmente em largura, consumindo toda a memória. Por isso o gerador envolve `listOf` com `resize (n `div` 2)`, e largura e profundidade encolhem juntas até o caso base (apenas valores primitivos).
- **`SimpleJSON` reexporta `JValue`.** O tipo é definido em `JSON` e reexportado por `SimpleJSON`, mantendo compatibilidade com o tutorial sem criar dois tipos distintos.
- **Parser sem dependências externas.** `ReadP` faz parte do `base`, e o parser não avalia código nem executa comandos.
- **Números como `Double`.** Inteiros muito grandes podem perder precisão e valores infinitos são rejeitados.

## 🤝 Fluxo de trabalho da dupla

- Commits pequenos e incrementais, seguindo [Conventional Commits](https://www.conventionalcommits.org/) (`init`, `feat`, `test`, `docs`).
- Cada etapa do tutorial virou um ou mais commits: estrutura Cabal, pretty printer, accessors, testes QuickCheck, CLI e documentação.

Histórico resumido:

```text
4c554e2 feat: add CLI options and stdin support to hs2json executable
d9de8f2 test: enforce exitFailure on QuickCheck property failure
17e5809 test: add escape correctness and idempotency properties
028c4aa docs: list remaining tasks and technical requirements in README.md
ab100fa test: add bounded JValue generator and QuickCheck properties
481b141 feat: add safe JSON accessors
251f845 feat: implement JSON pretty printing
2e2891a docs: improve README.md
437f01d init: setup initial project structure with Cabal
```

Consulte também o [CHANGELOG.md](CHANGELOG.md).
