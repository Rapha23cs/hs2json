# hs2json

Um projeto Haskell para manipulação e formatação (*pretty-printing*) de JSON, desenvolvido como projeto em dupla e guiado pelo tutorial da LambdaGeo.

Este projeto tem como foco aplicar conceitos modernos de desenvolvimento em Haskell, incluindo:
- **Modularização com Cabal:** Separação clara entre biblioteca (`src`), executável (`app`) e testes (`test`).
- **Testes Baseados em Propriedades:** Uso da biblioteca QuickCheck para garantir a integridade das funções de formatação.

## Estrutura do Projeto

- `src/JSON.hs`: Definição da Árvore de Sintaxe Abstrata (AST) para os valores JSON (`JValue`).
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

---

## 📝 Instruções para o Próximo Commit (Para a Dupla)

A fundação do projeto (AST e estrutura do Cabal) já está pronta e na branch `main`. Para o próximo passo, você (minha dupla) deve adicionar as alterações de funcionalidade que já foram discutidas. 

1. **Desenvolver o Pretty Printing:** 
   - Garanta que a função `renderJValue :: JValue -> String` esteja corretamente implementada no arquivo `src/PrettyJSON.hs`.
   - Se certifique que o `app/Main.hs` faz uso dessa função para testar o output.
2. **Realizar o Commit:**
   - Após revisar os arquivos da Parte 2 (Pretty Printing), faça o commit dessas alterações utilizando a nomenclatura oficial (`feat:`). 
   - Exemplo de comando: `git commit -m "feat: implement JSON pretty printing"`
3. **Enviar (Push):**
   - Suba suas alterações para a nuvem com `git push origin main`.
