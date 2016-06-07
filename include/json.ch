/*----------------------------------------------------------------------*\
 * JSON for AdvPL
 * Copyright (C) 2013  Arthur Helfstein Fragoso
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * This program includes the function JsonMinify that is a ported version
 * of JSONLint by Chris Dary. Here is his original license: (MIT License)
 * 
 * Copyright (c) 2011 Chris Dary.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 *----------------------------------------------------------------------*
 *
 * How to use this program:
 *
 * 1 - Add the files JSON.prg and SHash.prg to your project.
 *
 * 2 - Compile JSON.prg and SHash.prg.
 *
 * 3 - Include the header files to any project you want to use it:
 *
 *   #Include "aarray.ch"
 *   #Include "json.ch"
 *
 * 4 - See the functions documentation, it's very easy to use it. ;)
 *
 *
 * Note: Thanks to the preprocessor we can call user functions without
 * the U_, we just use the #xtranslate function, see bellow to understand
 * it.
 *
\*----------------------------------------------------------------------*/


#IFNDEF _JSON_CH

	#DEFINE _JSON_CH

	
	/**
	 * (User) Function: FromJson(cJstr)
	 * Converts from a JSON string into any value it holds
	 *
	 * Example:
	 * ----
	 * cJSON := '{"Products": [{"Name": "Water", "Cost": 1.3}, {"Name": "Bread", "Cost": 4e-1}], "Users": [{"Name": "Arthur", "Comment": "Hello\" \\World"}]}'
	 *
	 * aaBusiness := FromJson(cJSON)
	 * 
	 * alert(aaBusiness[#'Products'][1][#'Name']) // Returns -> Water
	 *
	 * alert(aaBusiness[#'Products'][2][#'Cost']) // Returns -> 0.4
	 * 
	 * alert(aaBusiness[#'Users'][1][#'Comment']) // Returns -> Hello" \World
	 * ----
	 *
	 * Additional Info:
	 *  * Numbers accept the Scientific E Notation
	 *    234e-7 = 0.0000234
	 *    57e3   = 57000
	 *  * I don't know how I can make an Unicode or UTF-8 character in Clipper/AdvPL,
	 *    So, the json \uXXXX converts an ASCII code. Values outside the ASCII table becomes '?' (quotation marks).
	 *
	 * @param cJstr - The JSON string you want to convert from
	 * @return - The converted JSON string, it can be any type. Or Nil in case of a bad formatted JSON string. 
	**/
	
	#xtranslate FromJson(<cJstr>)                   => U_FromJson(<cJstr>)
	
	
	/**
	 * (User) Function: ToJson(uAnyVar)
	 * Converts AdvPLs value into a JSON string
	 * Accepted values: Strings, Numbers, Logicals, Nil, Arrays and Associative Arrays (SHash Objects)
	 *
	 * Example:
	 * ----
	 * aaBusiness := Array(#)
	 * aaBusiness[#'Products'] := Array(2)
	 * aaBusiness[#'Products'][1] := Array(#)
	 * aaBusiness[#'Products'][1][#'Name'] := "Water"
	 * aaBusiness[#'Products'][1][#'Cost'] := 1.3
	 * aaBusiness[#'Products'][2] := Array(#)
	 * aaBusiness[#'Products'][2][#'Name'] := "Bread"
	 * aaBusiness[#'Products'][2][#'Cost'] := 0.4
	 * aaBusiness[#'Users'] := Array(1)
	 * aaBusiness[#'Users'][1] := Array(#)
	 * aaBusiness[#'Users'][1][#'Name'] := "Arthur"
	 * aaBusiness[#'Users'][1][#'Comment'] := 'Hello" \World' 
	 * 
	 * 
	 * alert( ToJson(aaBusiness) )
	 *
	 * // Returns: 
	 *  {"Products": [{"Name": "Water", "Cost": 1.3}, {"Name": "Bread", "Cost": 0.4}], "Users": [{"Name": "Arthur", "Comment": "Hello\" \\World"}]}
	 * ----
	 *
	 * @param uAnyVar - The value you want to convert to a JSON string
	 * @return string - JSON string
	**/
	
	#xtranslate ToJson(<uAnyVar>)                     => U_ToJson(<uAnyVar>)
	
	
	/**
	 * (User) Function: EscpJsonStr(cJsStr)
	 * Escapes string to a JSON string format
	 * ToJson() Automatically escapes strings, there is no much use of this function unless
	 * you want to write the JSON strings yourself.
	 *
	 * Example:
	 * ----
	 * cProdName := 'Cool" and \ cool"'
	 *
	 * cJSON := '{"Product": {"Name": "'+ EscpJsonStr(cProdName) +'"}}'
	 * 
	 * alert( JsonPrettify(cJSON) ) // -> {"Product": {"Name": "Cool\" and \\ cool\""}}
	 * ----
	 *
	 * @param cJsStr - The String you want to escape
	 * @return cJsStr - Escaped JSON string
	**/
	
	#xtranslate EscpJsonStr(<cJsStr>)                => U_EscpJsonStr(<cJsStr>)
	
	
	/**
	 * (User) Function: JsonPrettify(cJstr [,nTab])
	 * Prettify a JSON string. It will indent and make it more readable
	 *
	 * Example:
	 * -----
	 * cJSON := '{"Products": [{"Name": "Water", "Cost": 1.30}, {"Name": "Bread", "Cost": 0.40}]}'
	 * 
	 * alert( JsonPrettify(cJSON, 4) )
	 * 
	 * Result:
	 *
	 * {
	 *     "Products": [
	 *         {
	 *             "Name": "Water",
	 *             "Cost": 1.30
	 *         },
	 *         {
	 *             "Name": "Bread",
	 *             "Cost": 0.40
	 *         }
	 *     ]
	 * }
	 * ---- 
	 *
	 * @param cJstr - The JSON string to prettify
	 * @param nTab (optional) - number of spaces for each indentation, -1 for tabs (\t) (Default: -1)
	 * @return string - Prettified JSON string
	**/

	#xtranslate JsonPrettify(<cJstr> [,<nTab>])          => U_JsonPrettify(<cJstr>, <nTab>)
	
	
	/**
	 * (User) Function: JsonMinify(cJstr)
	 * Remove spaces, breaklines, and comments
	 *
	 * Comments are not allowed in the JSON specification, but we can remove them with this function.
	 * Allowed comments:
	 * 
	 *  // Single line comment
	 *  
	 *  /*  Multiple Lines
	 *      Multiple Lines
	 *      Multiple Lines   */
	/*
	 * Example:
	 * -----
	 * cJSON := '{' + CRLF
	 * cJSON += '  // this is a comment' + CRLF
	 * cJSON += '  "Products": [35, 50]' + CRLF
	 * cJSON += '}'
	 * 
	 * cJSON := JsonMinify(cJSON) // -> returns '{"Products":[35,50]}'
	 * -----
	 *
	 * Function ported from Chris Dary's JSONLint:
	 * http://jsonlint.com/c/js/jsl.format.js
	 * https://github.com/arc90/jsonlintdotcom/blob/master/c/js/jsl.format.js
	 *
	 * A copy of his license should be at the top of this file.
	 *
	 * @param cJstr - The JSON string to Minify
	 * @return string - Minified JSON string
	**/

	#xtranslate JsonMinify(<cJstr>)                 => U_JsonMinify(<cJstr>)
	
	
	/**
	 * (User) Function: ReadJsonFile(cFileName [,lStripComments])
	 * Reads JSON from a JSON file.
	 *
	 * Example:
	 * -----
	 * aaConf := ReadJsonFile("D:\TOTVS\Config.json")
	 * alert(aaConf[#'Product'][35][#'name'])
	 * -----
	 *
	 * @param cFileName - Filename
	 * @param lStripComments (Optional) - .T. removes comments, .F. doesn't. (Default .T.)
	 * @return AnyValue - Returns the value of the JSON file
	**/
	
	#xtranslate ReadJsonFile(<cFileName> [,<lStripComments>])       => U_ReadJsonFile(<cFileName>, <lStripComments>)

	
	
	// ASCII Characteres
	
	#DEFINE CHR_BS    chr(8)
	#DEFINE CHR_HT    chr(9)
	#DEFINE CHR_LF    chr(10)
	#DEFINE CHR_VT    chr(11)
	#DEFINE CHR_FF    chr(12)
	#DEFINE CHR_CR    chr(13)
	#DEFINE CRLF      chr(13)+chr(10)
	
	#IFNDEF __HARBOUR__
		#Include "Protheus.ch"
	#ELSE
		#xcommand DEFAULT <uVar1> := <uVal1> ;
			[, <uVarN> := <uValN> ] => ;
			<uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
			[ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]
		#xcommand BEGIN SEQUENCE =>
		#xcommand END SEQUENCE =>
		#xtranslate CVALTOCHAR(<nNum>) => AllTrim(str(<nNum>))
	#ENDIF

#ENDIF
