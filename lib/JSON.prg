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
 * the U_, look at the aarray.ch header file to understand it better.
 *
\*----------------------------------------------------------------------*/

#Include "aarray.ch"
#Include "json.ch"


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
 *  * I don't know how I can make an Unicode or UTF-8 character in AdvPL,
 *    So, the json \uXXXX converts an ASCII code. Values outside the ASCII table becomes '?' (quotation marks).
 *
 * @param cJstr - The JSON string you want to convert from
 * @return - The converted JSON string, it can be any type. Or Nil in case of a bad formatted JSON string. 
**/

Function FromJson(cJstr)
Return GetJsonVal(cJstr)[1]





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

Function ToJson (uAnyVar)
	Local cRet, nI, cType, aAsKeys
	
	cType := valType(uAnyVar)
	DO CASE
		case cType == "C"
			return '"'+ EscpJsonStr(uAnyVar) +'"'
		case cType == "N"
			return CvalToChar(uAnyVar)
		case cType == "L"
			return if(uAnyVar,"true","false") 
		case cType == "D"
			return '"'+ DtoS(uAnyVar) +'"'
		case cType == "U"
			return "null"
		case cType == "A"
			cRet := '['
			For nI := 1 to len(uAnyVar)
				if(nI != 1)
					cRet += ', '
				endif
				cRet += ToJson(uAnyVar[nI])
			Next
			return cRet + ']'
		case cType == "B"
			return '"Type Block"'
		case cType == "M"
			return '"Type Memo"'
		case cType =="O"
			if uAnyVar:cClassName == "SHASH"
				cRet := '{'
				For nI := 1 to len(uAnyVar:aData)
					if(nI != 1)
						cRet += ', '
					endif
					cRet += '"'+ EscpJsonStr(uAnyVar:aData[nI][SPROPERTY_KEY]) +'": '+ ToJson(uAnyVar:aData[nI][SPROPERTY_VALUE])
				Next
				return cRet + '}'
		   	endif
			return '"Type Object"'
#IFDEF __HARBOUR__
		case cType =="H" //Harbour Associative Array
			aAsKeys := hb_hkeys(uAnyVar)
			cRet := '{'
			For nI := 1 to len(aAsKeys)
				if(nI != 1)
					cRet += ', '
				endif
				cRet += '"'+ EscpJsonStr(aAsKeys[nI]) +'": '+ ToJson(uAnyVar[aAsKeys[nI]])
			Next
			return cRet + '}'
#ENDIF
	ENDCASE
Return '"Unknown Data Type ('+ cType +')"'


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

Function EscpJsonStr(cJsStr)
	cJsStr := StrTran(cJsStr, '\', '\\') // we must escape \ first, so it won't bug the rest
	cJsStr := StrTran(cJsStr, '"', '\"')
	cJsStr := StrTran(cJsStr, CHR_FF, '\f')
	cJsStr := StrTran(cJsStr, CHR_LF, '\n')
	cJsStr := StrTran(cJsStr, CHR_CR, '\r')
	cJsStr := StrTran(cJsStr, CHR_HT, '\t')
Return cJsStr


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
 * @param nTab (opitional) - number of spaces for each indentation, -1 for tabs (\t) (Default: -1)
 * @return string - Prettified JSON string
**/

Function JsonPrettify(cJstr, nTab)
	Local nConta, cBefore, cTab
	Local cLetra := ""
	Local lInString := .F.
	Local cNewJsn := ""
	Local nIdentLev := 0
	Default nTab := -1

	if nTab > 0
		cTab := REPLICATE(" ", nTab)
	else
	    cTab := CHR_HT
	endif
		

	For nConta:= 1 To Len(cJstr)
	
		cBefore := cLetra
		cLetra := SubStr(cJstr, nConta, 1)		
		
		if cLetra == "{" .or. cLetra == "["
			if !lInString
				nIdentLev++
				cNewJsn += cLetra + CRLF + REPLICATE( cTab, nIdentLev)
			else
				cNewJsn += cLetra
			endif
		elseif cLetra == "}" .or. cLetra == "]"
			if !lInString
				nIdentLev--
				cNewJsn += CRLF + REPLICATE(cTab, nIdentLev) + cLetra
			else
				cNewJsn += cLetra
			endif
		elseif cLetra == ","
	   		if !lInString
				cNewJsn += cLetra + CRLF + REPLICATE(cTab, nIdentLev)
			else
				cNewJsn += cLetra
			endif
		elseif cLetra == ":"
	   		if !lInString
				cNewJsn += ": "
			else
				cNewJsn += cLetra
			endif
		elseif cLetra == " " .or. cLetra == CHR_LF .or. cLetra == CHR_HT
			if lInString
				cNewJsn += cLetra
			endif
		elseif cLetra == '"'
	   		if cBefore != "\"
				lInString := !lInString
			endif
			cNewJsn += cLetra
		else
			cNewJsn += cLetra
		endif
	Next
Return cNewJsn


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

Function JsonMinify(cJstr)
	Local nConta, cBefore
	Local cLetra := ""
	Local lInString := .F.
	Local cNewJsn := ""
	Local lInLineCommt := .F.
	Local lMultLineCommt := .F.

	For nConta:= 1 To Len(cJstr)
	
		cBefore := cLetra
		cLetra := SubStr(cJstr, nConta, 1)
		
		// strip comments
		if lInLineCommt
			if cLetra == CHR_LF // \n
				lInLineCommt := .F.
			endif
		elseif lMultLineCommt
			if cBefore == "*" .and. cLetra == "/"
				lMultLineCommt := .F.
			endif
		elseif !lInString .and. cLetra == "/" .and. SubStr(cJstr, nConta+1, 1) == "/"
			lInLineCommt := .T.
		elseif !lInString .and. cLetra == "/" .and. SubStr(cJstr, nConta+1, 1) == "*"
			lMultLineCommt := .T.
		
		// real json
		elseif cLetra == "{" .or. cLetra == "["
			cNewJsn += cLetra
		elseif cLetra == "}" .or. cLetra == "]"
			cNewJsn += cLetra
		elseif cLetra == ","
			cNewJsn += cLetra
		elseif cLetra == ":"
			cNewJsn += cLetra
		elseif cLetra == " " .or. cLetra == CHR_LF .or. cLetra == CHR_HT .or. cLetra == CHR_CR
			if lInString
				cNewJsn += cLetra
			endif
		elseif cLetra == '"'
	   		if cBefore != "\"
				lInString := !lInString
			endif
			cNewJsn += cLetra
		else
			cNewJsn += cLetra
		endif
	Next
Return cNewJsn


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

Function ReadJsonFile(cFileName, lStripComments)
	Default lStripComments := .T.
	if !File(cFileName)
		Return Nil
	endif

	if lStripComments
		Return FromJson(JsonMinify(MemoRead(cFileName, .F.)))
	else
		Return FromJson(MemoRead(cFileName, .F.))
	endif
Return



/// End of User Functions


////////////////////////////////////////////////////////////////////////////////////////////////////////
// Bellow there are only internal functions which are necessary for the FromJson function

/// Begin of Internal Functions 



/**
 * Internal Function: GetJsonVal(cJstr)
 * Converts from a JSON string into any value it holds
 *
 * @param cJstr - The JSON string you want to convert from
 * @return array(
 *           uVal, - Value of the converted JSON string, or Nil in case of a bad formatted JSON string. 
 *           nPos  - Position of the last processed character. Returns -1 in case of a bad formatted JSON string.
 *         )
**/

Static Function GetJsonVal(cJstr) 
	Local nConta
	Local cLetra := ""
	Local aTmp
    
	BEGIN SEQUENCE

		For nConta:= 1 To Len(cJstr)
		
			cLetra := SubStr(cJstr, nConta, 1)
	
			if cLetra == '"'
				aTmp := JsonStr(SubStr(cJstr, nConta))
				BREAK
			elseif at(cLetra, "0123456789.-") > 0
				aTmp := JsonNum(SubStr(cJstr, nConta))
				BREAK
			elseif cLetra == "["
				aTmp := JsonArr(SubStr(cJstr, nConta))
				BREAK
			elseif cLetra == "{"
				aTmp := JsonObj(SubStr(cJstr, nConta))
				BREAK
			elseif at(cLetra, "TtFfNn") > 0 //True, False or Null
				aTmp := JsonTFN(SubStr(cJstr, nConta))
				BREAK
			endif
	
		Next
		
	END SEQUENCE
	
	if len(aTmp) > 0
		if aTmp[2] < 0
		     return {Nil, -1} // Error Code
		endif
	    
		return {aTmp[1], nConta + aTmp[2] -1}
	
	endif
	
Return {Nil, -1}


/**
 * Internal Function: JsonArr(cJstr)
 * Converts from a JSON string containing only an Array into an Array
 *
 * @param cJstr - The JSON string you want to convert from
 * @return array(
 *           aVal, - Value of the JSON array, or Nil in case of a bad formatted JSON string. 
 *           nPos  - Position of the last processed character. Returns -1 in case of a bad formatted JSON string.
 *         )
**/

Static Function JsonArr(cJstr)
	Local nConta
	Local cLetra := ""
	Local lNeedComma := .F.
	Local aRet := {}
	Local aTmp
    
	BEGIN SEQUENCE 

		For nConta:= 2 To Len(cJstr)
		
			cLetra := SubStr(cJstr, nConta, 1)
			
			if !lNeedComma .and. at(cLetra, '"{[0123456789.-') > 0
				aTmp := GetJsonVal(SubStr(cJstr, nConta))
				if aTmp[2] < 0
					return {Nil, -1} // Error Code
				endif
				AADD(aRet, aTmp[1])
				nConta := nConta + aTmp[2] -1 // -1 move to last character because the loop will add +1.
				lNeedComma := .T.
			elseif lNeedComma .and. cLetra == ','
				lNeedComma := .F.
			elseif cLetra == ']'
				return {aRet, nConta}
			endif
	
		Next
	
	END SEQUENCE
	
Return {Nil, -1}


/**
 * Internal Function: JsonObj(cJstr)
 * Converts from a JSON string containing only an Object into an Associative Array (SHash Object)
 *
 * @param cJstr - The JSON string you want to convert from
 * @return array(
 *           aaVal, - Associative Array (SHash Object) of the JSON object, or Nil in case of a bad formatted JSON string. 
 *           nPos  - Position of the last processed character. Returns -1 in case of a bad formatted JSON string.
 *         )
**/

Static Function JsonObj(cJstr)
	Local nConta
	Local cLetra := ""
	Local cTmpStr := ""
	Local nStep := 1
	Local aTmp
	Local aaRet := array(#)
	
	BEGIN SEQUENCE

		For nConta:= 2 To Len(cJstr)
		
			cLetra := SubStr(cJstr, nConta, 1)
			
			if nStep == 1 .and. cLetra == '"'
					aTmp := JsonStr(SubStr(cJstr, nConta))
					if aTmp[2] < 0
						return {Nil, -1} // Error Code
					endif
					nConta := nConta + aTmp[2] -1
					cTmpStr := aTmp[1]
					nStep := 2
	
			elseif nStep == 2 .and. cLetra == ':'
				nStep := 3
				
			elseif nStep == 3 .and. at(cLetra, '"{[0123456789.-TtFfNn') > 0
				aTmp := GetJsonVal(SubStr(cJstr, nConta))
				if aTmp[2] < 0
					return {Nil, -1} // Error Code
				endif
				nConta := nConta + aTmp[2] -1
				nStep := 4
			elseif nStep == 4 .and. cLetra == ','
				aaRet[#cTmpStr] := aTmp[1]
				nStep := 1
			elseif nStep == 4 .and. cLetra == '}'
				aaRet[#cTmpStr] := aTmp[1]
				return {aaRet, nConta}
			endif
	
		Next
	
	END SEQUENCE
	
Return {Nil, -1}


/**
 * Internal Function: JsonStr(cJstr)
 * Converts from a JSON string containing only a String into a String
 *
 * @param cJstr - The JSON string you want to convert from
 * @return array(
 *           cVal, - Value of the JSON string, or Nil in case of a bad formatted JSON string. 
 *           nPos  - Position of the last processed character. Returns -1 in case of a bad formatted JSON string.
 *         )
**/

Static Function JsonStr(cJstr)
	Local nConta
	Local cLetra := ""
	Local cTmpStr := ""
	Local nUnic
	
	BEGIN SEQUENCE

		For nConta:= 2 To Len(cJstr)
		
			cLetra := SubStr(cJstr, nConta, 1)
			
			if cLetra == "\"
				nConta++
				cLetra := SubStr(cJstr, nConta, 1)
				if cLetra == 'b'
					cTmpStr += CHR_BS
				elseif cLetra == 'f'
					cTmpStr += CHR_FF
				elseif cLetra == 'n'
					cTmpStr += CHR_LF
				elseif cLetra == 'r'
					cTmpStr += CHR_CR
				elseif cLetra == 't'
					cTmpStr += CHR_HT
				elseif cLetra == 'u'
					nUnic := CTON(UPPER(SubStr(cJstr, nConta+1, 4)),16)
					if nUnic <= 255
						cTmpStr += chr(nUnic)
					else
						cTmpStr += '?'
					endif
					nConta += 4
				else
					cTmpStr += cLetra //it will add the char if it doesn't have a special function
				endif
			
			elseif cLetra == '"'
				return {cTmpStr, nConta}
			else
				cTmpStr += cLetra
			endif
	
		Next
	
	END SEQUENCE
	
Return {Nil, -1}


/**
 * Internal Function: JsonNum(cJstr)
 * Converts from a JSON string containing only a Number into a Number
 * It accepts the (Scientific) E Notation
 *
 * @param cJstr - The JSON string you want to convert from
 * @return array(
 *           nVal, - Value of the JSON number, or Nil in case of a bad formatted JSON string. 
 *           nPos  - Position of the last processed character. Returns -1 in case of a bad formatted JSON string.
 *         )
**/

Static Function JsonNum(cJstr)
	Local nConta, nNum, aTmp
	Local cLetra := ""
	Local cTmpStr := ""
	Local lNegExp := .F.
	
	BEGIN SEQUENCE

		For nConta:= 1 To Len(cJstr)
		
			cLetra := SubStr(cJstr, nConta, 1)
	
			if at(cLetra, '0123456789.-') > 0
				cTmpStr += cLetra
	
			elseif len(cLetra) > 0 .and. UPPER(cLetra) == 'E'
				nNum := val(cTmpStr)
				cTmpStr := ""
				nConta++
				cLetra := SubStr(cJstr, nConta, 1)
				if cLetra == '-'
					lNegExp := .T.
					nConta++
				elseif cLetra == '+'
					nConta++
				endif
				cLetra := SubStr(cJstr, nConta, 1)
				
				while at(cLetra, '0123456789') > 0 
					cTmpStr += cLetra
					nConta++
					cLetra := SubStr(cJstr, nConta, 1)
				end
				
				if lNegExp
					//nNum := nNum / val('1'+REPLICATE( '0', val(cTmpStr) ))
					if val(cTmpStr) != 0
						nNum := nNum * val('0.'+REPLICATE( '0', val(cTmpStr)-1) + '1')
					endif
				else
					nNum := nNum * val('1'+REPLICATE( '0', val(cTmpStr) ))
				endif
				
				return {nNum, nConta-1}
				
			elseif len(cLetra) > 0
				return {val(cTmpStr), nConta-1}
			endif
	
		Next
	
	END SEQUENCE
	
Return {Nil, -1}


/**
 * Internal Function: JsonTFN(cJstr)
 * Converts from a JSON string containing only a logical True, False or Null
 *
 * @param cJstr - The JSON string you want to convert from
 * @return array(
 *           lVal, - Value of the JSON logical value, or Nil in case of Null or a bad formatted JSON string. 
 *           nPos  - Position of the last processed character. Returns -1 in case of a bad formatted JSON string.
 *         )
**/

Static Function JsonTFN(cJstr)
	Local cTmpStr
    
	BEGIN SEQUENCE

	    cTmpStr := lower(SubStr(cJstr, 1, 5))
	    
	    if cTmpStr == "false"
	    	return {.F., 5}
	    endif
	    
	    cTmpStr := SubStr(cTmpStr, 1, 4)
	    
	    if cTmpStr == "true"
	    	return {.T., 4}   	
	    elseif cTmpStr == "null"
	    	return {Nil, 4}
	    endif 
    
	END SEQUENCE

Return {Nil, -1}

