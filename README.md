JSON and Associative Array for ADVPL
====================================

JSON and Associative Arrays are very useful for interchanging data between different programs.

This library is Free Software under GPLv3 or later. Make sure to understand the license before using it.

It was tested on ADVPL and Harbour.

This documentation can also be found in [Portuguese](LEIAME.md).

## Index

* Associative Arrays
    * How to add Associative Arrays support
    * How to use Associative Arrays
    * How does it work on the background?
* JSON
    * How to add JSON support
    * FromJson(cJstr)
    * ToJson(uAnyVar)
    * EscpJsonStr(cJsStr)
    * JsonPrettify(cJstr [,nTab])
    * JsonMinify(cJstr)
    * ReadJsonFile(cFileName [,lStripComments])
* License
* Why GPL?

## Associative Arrays

### How to add Associative Arrays support

1. Add the file SHash.prg to your project.

2. Compile SHash.prg.

3. Include the header file to any project you want to use it:

        #Include "aarray.ch"

4. Use it. ;)


### How to use Associative Arrays

It's easier to learn from examples, isn't it?

Example:

    // Start an Associative Array
    aaFriends := Array(#)
    
    // Start another another Associative Array on top of the other
    aaFriends[#"Arthur"] := Array(#)
    
    // Set values:
    aaFriends[#"Arthur"][#"Name"] := "Arthur"
    aaFriends[#"Arthur"][#"Account"] := 230251
    aaFriends[#"Arthur"][#"Work"] := "Software Developer"
    
    // Start a new Associative Array and set values
    aaFriends[#"David"] := Array(#)
    aaFriends[#"David"][#"Name"] := "David"
    aaFriends[#"David"][#"Account"] := 187204
    aaFriends[#"David"][#"Work"] := "Web Designer"
    
    // Let's do something interesting:
    
    aaFriends[#"David"][#"Best Friend"] := aaFriends[#"Arthur"]
    
    // And test it:
    
    Alert (aaFriends[#"David"][#"Best Friend"][#"Name"])
    Alert (aaFriends[#"David"][#"Best Friend"][#"Work"])
    
    // We can also mix it with the regular Array:
    aaFriends[#"Arthur"][#"Friends"] := Array(1)
    aaFriends[#"Arthur"][#"Friends"][1] := aaFriends[#"David"]
    
    Alert (aaFriends[#"Arthur"][#"Friends"][1][#"Name"])


### How does it work on the background?

When we create an Associative Array, we are in reality instantiating a Class and creating an Object.

Take a look at it working, this:

    aaFriends := Array(#)
    aaFriends[#"David"] := Array(#)
    aaFriends[#"David"][#"Account"] := 187204

is translated to this by the precompiler:

    aaFriends := SHash():New()
    aaFriends:SetProperty("David", SHash():New())
    aaFriends:GetPropertyValue("David"):SetProperty("Account", 187204)

The SHash object has the aData array that stores all the data, so you can easily access all the data thought a loop:

    For i := 1 to len(aaFriends:aData)
        QOut( aaFriends:aData[i][1] +': '+ aaFriends:aData[i][2] )
    Next


## JSON

### How to add JSON support

1. Add the files JSON.prg and SHash.prg to your project.

2. Compile JSON.prg and SHash.prg.

3. Include the header files to any project you want to use it:

        #Include "aarray.ch"
        #Include "json.ch"

4. See the functions documentation, it's very easy to use it. ;)


 * Note: Thanks to the preprocessor we can call user functions without the U_, look at the aarray.ch header file to understand it better.


- - - - - - - - - - - - - -

### (User) Function: FromJson(cJstr)

Converts from a JSON string into any value it holds
 
#### Example:

    cJSON := '{"Products": [{"Name": "Water", "Cost": 1.3}, {"Name": "Bread", "Cost": 4e-1}], "Users": [{"Name": "Arthur", "Comment": "Hello\" \\World"}]}'

    aaBusiness := FromJson(cJSON)

    alert(aaBusiness[#'Products'][1][#'Name']) // Returns -> Water

    alert(aaBusiness[#'Products'][2][#'Cost']) // Returns -> 0.4

    alert(aaBusiness[#'Users'][1][#'Comment']) // Returns -> Hello" \World


#### Additional Info:

* Numbers accept the Scientific E Notation  
  234e-7 = 0.0000234  
  57e3   = 57000
* I'm don't know how I can make an Unicode or UTF-8 character in ADVPL, so the json \uXXXX converts an ASCII code. Values outside the ASCII table becomes '?' (quotation marks).

@param cJstr - The JSON string you want to convert from  
@return - The converted JSON string, it can be any type. Or Nil in case of a bad formatted JSON string. 


- - - - - - - - - - - - - -

### (User) Function: ToJson(uAnyVar)

Converts ADVPLs value into a JSON string  
Accepted values: Strings, Numbers, Logicals, Nil, Arrays and Associative Arrays (SHash Objects)
	 
#### Example:

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

    // Returns: 
    {"Products": [{"Name": "Water", "Cost": 1.3}, {"Name": "Bread", "Cost": 0.4}], "Users": [{"Name": "Arthur", "Comment": "Hello\" \\World"}]}

#### Additional Info:

@param uAnyVar - The value you want to convert to a JSON string  
@return string - JSON string


- - - - - - - - - - - - - -

### (User) Function: EscpJsonStr(cJsStr)

Escapes string to a JSON string format  
ToJson() Automatically escapes strings, there is no much use of this function unless you want to write the JSON strings yourself.

#### Example:

    cProdName := 'Cool" and \ cool"'
	
	cJSON := '{"Product": {"Name": "'+ EscpJsonStr(cProdName) +'"}}'
	 
	alert( JsonPrettify(cJSON) ) // -> {"Product": {"Name": "Cool\" and \\ cool\""}}
	
#### Additional Info:

@param cJsStr - The String you want to escape  
@return cJsStr - Escaped JSON string


- - - - - - - - - - - - - -

### (User) Function: JsonPrettify(cJstr [,nTab])

Prettify a JSON string. It will indent and make it more readable

#### Example:
	
	cJSON := '{"Products": [{"Name": "Water", "Cost": 1.30}, {"Name": "Bread", "Cost": 0.40}]}'
	 
	alert( JsonPrettify(cJSON, 4) )
	
Result:
	
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

#### Additional Info:

@param cJstr - The JSON string to prettify  
@param nTab (optional) - number of spaces for each indentation, -1 for tabs (\t) (Default: -1)  
@return string - Prettified JSON string


- - - - - - - - - - - - - -

### (User) Function: JsonMinify(cJstr)

Remove spaces, breaklines, and comments

Comments are not allowed in the JSON specification, but we can remove them with this function.

Allowed comments:

	// Single line comment
	 
	/*  Multiple Lines
	    Multiple Lines
	    Multiple Lines   */

#### Example:

	cJSON := '{' + CRLF
	cJSON += '  // this is a comment' + CRLF
	cJSON += '  "Products": [35, 50]' + CRLF
	cJSON += '}'
	
	cJSON := JsonMinify(cJSON) // -> returns '{"Products":[35,50]}'

#### Additional Info:

This function was ported from Chris Dary's JSONLint:  
<http://jsonlint.com/c/js/jsl.format.js>  
<https://github.com/arc90/jsonlintdotcom/blob/master/c/js/jsl.format.js>
	 
A copy of his license is within the code.

@param cJstr - The JSON string to Minify  
@return string - Minified JSON string


- - - - - - - - - - - - - -

### (User) Function: ReadJsonFile(cFileName [,lStripComments])

Reads JSON from a JSON file.

#### Example:

	aaConf := ReadJsonFile("D:\TOTVS\Config.json")
	alert(aaConf[#'Product'][35][#'name'])


#### Additional Info:

@param cFileName - Filename  
@param lStripComments (Optional) - .T. removes comments, .F. doesn't. (Default .T.)  
@return AnyValue - Returns the value of the JSON file


## License
Copyright (C) 2013  Arthur Helfstein Fragoso

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Why GPL?

To understand why I used GPL instead of LGPL in this library, read this: <https://www.gnu.org/philosophy/why-not-lgpl.html>.

It's very easy to make your code free, you can find instructions here: <http://www.gnu.org/licenses/gpl-howto.html>

If you need help, you can contact me by email:

arthur at life.net.br
