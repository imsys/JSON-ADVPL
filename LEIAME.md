![ ](.\logo-totvs-json.PNG)
JSON e Vetores Associativos para AdvPL
======================================

JSON e Vetores Associativos são bem úteis para a troca de dados entre programas.

Essa biblioteca é Software Livre dentro dos termos da LGPLv3 ou posterior.

Foi testado com AdvPL e Harbour.

This documentation can also be found in [English](README.md).

## Índice

* Vetores Associativos
    * Como adicionar suporte à vetores Vetores Associativos
    * Como usar Vetores Associativos
    * Como funciona internamente
* JSON
    * Como adicionar suporte ao JSON
    * FromJson(cJstr)
    * ToJson(uAnyVar)
    * EscpJsonStr(cJsStr)
    * JsonPrettify(cJstr [,nTab])
    * JsonMinify(cJstr)
    * ReadJsonFile(cFileName [,lStripComments])
* Licença
* Por que GPL?

## Vetores Associativos

### Como adicionar suporte à vetores Vetores Associativos

1. Adicione o arquivo SHash.prg em seu projeto;

2. Compile SHash.prg.

3. Inclua o arquivo cabeçalho em todo projeto que precisar usá-lo:

    ```AdvPL

    #Include "aarray.ch"
    ```

4. Use-o. ;)


### Como usar Vetores Associativos

É muito fácil aprender através de exemplos, não é?

Exemplo:

```AdvPL

// Inicia um Vetor Associativo
aaFriends := Array(#)

// Inicia outro Vetor Associativo em cima do anterior
aaFriends[#"Arthur"] := Array(#)

// Define valores:
aaFriends[#"Arthur"][#"Name"] := "Arthur"
aaFriends[#"Arthur"][#"Account"] := 230251
aaFriends[#"Arthur"][#"Work"] := "Software Developer"

// Inicia um novo Vetor Associativo e define valores
aaFriends[#"David"] := Array(#)
aaFriends[#"David"][#"Name"] := "David"
aaFriends[#"David"][#"Account"] := 187204
aaFriends[#"David"][#"Work"] := "Web Designer"

// Vamos fazer algo interessante!

aaFriends[#"David"][#"Best Friend"] := aaFriends[#"Arthur"]

// E testar:

Alert (aaFriends[#"David"][#"Best Friend"][#"Name"])
Alert (aaFriends[#"David"][#"Best Friend"][#"Work"])

// Também podemos misturá-los com Vetores normais:
aaFriends[#"Arthur"][#"Friends"] := Array(1)
aaFriends[#"Arthur"][#"Friends"][1] := aaFriends[#"David"]

Alert (aaFriends[#"Arthur"][#"Friends"][1][#"Name"])

```


### Como funciona internamente

Quando criamos um Vetor Associativo, estamos na verdade instanciando uma classe e criando um objeto.

Dê uma olhada:

```AdvPL

aaFriends := Array(#)
aaFriends[#"David"] := Array(#)
aaFriends[#"David"][#"Account"] := 187204
```

Isto é traduzido por isso pelo pré-compilador:

```AdvPL

aaFriends := SHash():New()
aaFriends:Set("David", SHash():New())
aaFriends:Get("David"):Set("Account", 187204)
```

Os objetos SHash contêm o vetor SHash que armazena todos os dados, então é muito fácil acessar tudo através de um loop:

```AdvPL
For i := 1 to len(aaFriends:aData)
    QOut( aaFriends:aData[i][1] +': '+ aaFriends:aData[i][2] )
Next
```

## JSON

### Como adicionar suporte ao JSON

1. Adicione os arquivos JSON.prg e SHash.prg em seu projeto.

2. Compile JSON.prg e SHash.prg.

3. Inclua os arquivos de cabeçalhos em todo projeto que precisar usá-lo:

    ```AdvPL
    
    #Include "aarray.ch"
    #Include "json.ch"
    ```

4. Veja a documentação das funções, é bem facil. ;)


 * Nota: Graças ao pré-processador podemos chamar as funções de usuários sem o U_, veja o arquivo aarray.ch para entender melhor.


- - - - - - - - - - - - - -

### (User) Function: FromJson(cJstr)

Converte strings JSON em qualquer valor que contenha.
 
#### Exemplo:

```AdvPL

cJSON := '{"Products": [{"Name": "Water", "Cost": 1.3}, {"Name": "Bread", "Cost": 4e-1}], "Users": [{"Name": "Arthur", "Comment": "Hello\" \\World"}]}'

aaBusiness := FromJson(cJSON)

alert(aaBusiness[#'Products'][1][#'Name']) // Retorna -> Water

alert(aaBusiness[#'Products'][2][#'Cost']) // Retorna -> 0.4

alert(aaBusiness[#'Users'][1][#'Comment']) // Retorna -> Hello" \World
```


#### Informações Adicionais:

* É aceito Notação Científica E nos números  
  234e-7 = 0.0000234  
  57e3   = 57000

* Não sei como usar Unicode em AdvPL, por isso a expressão \uXXXX converte para ASCII. Valores fora da tabela ASCII se tornam '?' (pontos de interrogação).

@param cJstr - A string JSON que você deseja converter  
@return - Resultado da conversão no formato apropriado. Retorna Nil em caso de um JSON mal formatado.


- - - - - - - - - - - - - -

### (User) Function: ToJson(uAnyVar)

Converte valor AdvPL em string JSON  
Valores aceitos: Strings, Números, Lógicos, Nil, Vetores e Vetores Associativos (Objetos SHash)
	 
#### Exemplo:

```AdvPL

aaBusiness := Array(#)
aaBusiness[#'Products'] := Array(2)
aaBusiness[#'Products'][1] := Array(#)
aaBusiness[#'Products'][1][#'Name'] := "Water"
aaBusiness[#'Products'][1][#'Cost'] := 1.3
aaBusiness[#'Products'][2] := Array(#)
aaBusiness[#'Products'][2][#'Name'] := "Bread"
aaBusiness[#'Products'][2][#'Cost'] := 0.4
aaBusiness[#'Users'] := Array(1)
aaBusiness[#'Users'][1] := Array(#)
aaBusiness[#'Users'][1][#'Name'] := "Arthur"
aaBusiness[#'Users'][1][#'Comment'] := 'Hello" \World' 


alert( ToJson(aaBusiness) )
```

Retorna: 

```json

{"Products": [{"Name": "Water", "Cost": 1.3}, {"Name": "Bread", "Cost": 0.4}], "Users": [{"Name": "Arthur", "Comment": "Hello\" \\World"}]}
```

#### Informações Adicionais:

@param uAnyVar - O valor que a ser convertido  
@return string - String JSON


- - - - - - - - - - - - - -

### (User) Function: EscpJsonStr(cJsStr)

Escapa string para o formato de string JSON  
ToJson() automaticamente escapa strings, essa função não tem muita necessidade a menos que você queira escrever strings JSON por conta própria.

#### Exemplo:

```AdvPL

cProdName := 'Cool" and \ cool"'

cJSON := '{"Product": {"Name": "'+ EscpJsonStr(cProdName) +'"}}'

alert( JsonPrettify(cJSON) ) // -> {"Product": {"Name": "Cool\" and \\ cool\""}}
```
	
#### Informações Adicionais:

@param cJsStr - String que deseja escapar  
@return cJsStr - String JSON escapada


- - - - - - - - - - - - - -

### (User) Function: JsonPrettify(cJstr [,nTab])

Embeleza uma string JSON, ou seja, indenta e deixa a leitura mais fácil.

#### Exemplo:
	
```AdvPL
cJSON := '{"Products": [{"Name": "Water", "Cost": 1.30}, {"Name": "Bread", "Cost": 0.40}]}'

alert( JsonPrettify(cJSON, 4) )
```
	
Resulta em:

```json

{
    "Products": [
        {
            "Name": "Water",
            "Cost": 1.30
        },
        {
            "Name": "Bread",
            "Cost": 0.40
        }
    ]
}
```

#### Informações Adicionais:

@param cJstr - String JSON a ser embelezada  
@param nTab (opcional) - Número de espaços para indentação ou -1 para tabulação (\t) (Padrão: -1)  
@return string - String JSON embelezada


- - - - - - - - - - - - - -

### (User) Function: JsonMinify(cJstr)

Remove espaços, quebra de linhas e comentários

Comentários não são permitidos dentro da especificação JSON, mas usá-los e removê-los com essa função.

Comentários permitidos:

```javascript

// Comentários de uma linha
 
/*  Comentários
    de Múltiplas
    Linhas         */
```

#### Exemplo:

```AdvPL

cJSON := '{' + CRLF
cJSON += '  // Isto é um comentário ' + CRLF
cJSON += '  "Products": [35, 50]' + CRLF
cJSON += '}'

cJSON := JsonMinify(cJSON) // -> Retorna '{"Products":[35,50]}'
```

#### Informações Adicionais:

Essa função foi portada do JSONLint de Chris Dary:  
<http://jsonlint.com/c/js/jsl.format.js>  
<https://github.com/arc90/jsonlintdotcom/blob/master/c/js/jsl.format.js>
	 
Uma cópia de sua licença está junta ao código.

@param cJstr - String JSON a se minificada  
@return string - String JSON minificada


- - - - - - - - - - - - - -

### (User) Function: ReadJsonFile(cFileName [,lStripComments])

Lê um arquivo JSON.

#### Exemplo:

```AdvPL

aaConf := ReadJsonFile("D:\TOTVS\Config.json")
alert(aaConf[#'Product'][35][#'name'])
```

#### Informações Adicionais:

@param cFileName - Nome do arquivo  
@param lStripComments (Opcional) - .T. remove comentários, .F. não remove. (Padrão .T.)  
@return AnyValue - Retorna o valor do arquivo JSON


## Licença
Copyright (C) 2013  Arthur Helfstein Fragoso

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
