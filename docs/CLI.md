# Entrada externa no hs2json

## Objetivo e comportamento

O item 3 permite usar o pretty printer com dados externos, além da demonstração
original. O fluxo é texto JSON -> `ParseJSON.parseJSON` -> `JValue` ->
`PrettyJSON.renderJValue` -> saída padrão. O processamento é local: não há
chamadas de rede, gravação dos dados de entrada ou alteração do arquivo lido.

## Uso no PowerShell

Execute na raiz do repositório. `-v0` reduz as mensagens do Cabal; os argumentos
depois de `--` são encaminhados ao executável.

```powershell
# Ajuda e demonstracao original
cabal run -v0 hs2json -- --help
cabal run -v0 hs2json -- --example

# JSON como argumento
cabal run -v0 hs2json -- --json '[1,true,null]'

# JSON recebido pela entrada padrao
'{"nome":"Ana","ativo":true}' | cabal run -v0 hs2json -- -

# Arquivo de exemplo incluido no repositorio; substitua pelo seu caminho
cabal run -v0 hs2json -- --file '.\examples\entrada.json'
```

Sem argumentos, o programa mantém o exemplo quando a entrada é um terminal.
Se houver entrada redirecionada, ele lê um JSON até EOF (fim da entrada).
Use `--example` para solicitar a demonstração explicitamente em qualquer contexto.
O modo `-` lê até EOF, portanto aceita JSON distribuído em várias linhas.
Versões antigas do PowerShell podem tratar aspas de argumentos nativos de forma
diferente; o modo de entrada padrão evita passar aspas JSON como argumento.

## Contrato e limites

- O parser consome exatamente um valor, incluindo escalares como `42` e `null`.
  Conteúdo adicional, entrada vazia e sintaxe incompleta são erros.
- Arquivos e entrada padrão são lidos como UTF-8. Um BOM inicial é tolerado.
- Arrays, objetos, strings, booleanos, `null` e números são aceitos. A lista
  original de campos dos objetos é preservada, inclusive ordem e nomes repetidos.
- Escapes JSON são decodificados; pares substitutos Unicode são combinados.
  Substitutos isolados são rejeitados para evitar strings não interoperáveis.
- Números seguem a gramática JSON, sem `NaN`, `Infinity`, sinal `+` inicial ou
  zeros extras no início. O armazenamento continua sendo `Double`: números
  decimais e inteiros grandes podem perder precisão; valores muito pequenos
  podem arredondar para zero. Resultados infinitos são rejeitados.
- O documento é lido inteiro em memória. Esta versão não é um processador de
  arquivos gigantes em streaming e não promete preservação textual dos números.
- A saída de sucesso contém apenas JSON formatado e uma quebra final, sem logs.
  Mensagens de erro vão para `stderr`, sem imprimir o documento fornecido, e o
  processo retorna erro. Erros de arquivo podem mencionar o caminho envolvido.
- `--json`, `--file`, `-`, `--example` e `--help` são modos exclusivos.
  Argumentos desconhecidos, incompletos ou combinados são rejeitados com ajuda.

`parseJSON :: String -> Either String JValue` é a nova interface da biblioteca.
O parser usa `ReadP`, que já faz parte de `base`, sem nova biblioteca externa.
Ele não avalia Haskell, não executa comandos e não interpreta JSON como código.

## Verificação

```powershell
cabal build all
cabal test all --test-show-details=direct
```

A suíte existente mantém as 29 asserções e nove propriedades QuickCheck.
A nova `hs2json-cli-test` verifica o parser e chama o executável real para
conferir argumentos, arquivo com caminho contendo espaços, UTF-8, BOM, entrada
padrão, ajuda, exemplo e os códigos de saída de erros. Exemplos são sintéticos;
os arquivos temporários são removidos pelos testes.
