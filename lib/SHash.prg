/*----------------------------------------------------------------------*\
 * SHASH - A Simple Hash (Associative Array) for AdvPL
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
 * This class is an adapted version of Marinaldo de Jesus' THASH Class:
 *
 * https://code.google.com/p/totvs-AdvPL-naldodj/source/browse/trunk/templates/P10/ndj_01/Projeto/NDJLib/NDJLIB022.prg
 *
 * See the aarray.ch header file for instruction on how to use it.
 * 
\*----------------------------------------------------------------------*/

#include "msobject.ch"
#include "shash.ch"

/*/
	CLASS:        SHASH
	Autor:        Marinaldo de Jesus
	Adaptado por: Arthur Helfstein Fragoso
	Descricao:    Simple Hash, Associative Array
	Sintaxe:      SHASH():New() -> Objeto do Tipo SHASH
/*/
CLASS SHASH

	DATA aData
	DATA cClassName

	METHOD NEW() CONSTRUCTOR

	METHOD ClassName()

	METHOD GetAt( uPropertyKey )
	METHOD Get( uPropertyKey , uDefaultValue )
	METHOD Set( uPropertyKey , uValue )
	METHOD Remove( uPropertyKey )
	METHOD GetAll( )

ENDCLASS

User Function SHASH()
Return( SHASH():New() )

/*/
	METHOD:		New
	Autor:		Marinaldo de Jesus
	Data:		04/12/2011
	Descricao:	CONSTRUCTOR
	Sintaxe:	SHASH():New() -> Self
/*/
METHOD New() CLASS SHASH

	Self:aData			:= Array( 0 )
	Self:cClassName		:= "SHASH"

Return( Self )

/*/
	METHOD:		ClassName
	Autor:		Marinaldo de Jesus
	Data:		04/12/2011
	Descricao:	Retornar o Nome da Classe
	Sintaxe:	SHASH():ClassName() -> cClassName
/*/
METHOD ClassName() CLASS SHASH
Return( Self:cClassName )

/*/
	METHOD:		GetAt
	Autor:		Marinaldo de Jesus
	Data:		04/12/2011
	Descricao:	Obter a Posicao da Propriedade Passada por parametro e de acordo com a Secao
	Sintaxe:	SHASH():GetAt( uPropertyKey ) -> nATProperty
/*/
METHOD GetAt( uPropertyKey ) CLASS SHASH

	Local nATProperty	:= 0

	BEGIN SEQUENCE

		nATProperty		:= aScan( Self:aData, { |aValues| ( Compare( aValues[ SPROPERTY_KEY ] , uPropertyKey ) ) } )

	END SEQUENCE

Return( nATProperty )

/*/
	METHOD:		Get
	Autor:		Marinaldo de Jesus
	Data:		04/12/2011
	Descricao:	Obter o valor da Propriedade Passada por parametro e de acordo com a Secao
	Sintaxe:	SHASH():Get( uPropertyKey , uDefaultValue ) -> uPropertyValue
/*/
METHOD Get( uPropertyKey , uDefaultValue ) CLASS SHASH

	Local uPropertyValue	:= "@__PROPERTY_NOT_FOUND__@"

	Local nProperty

	BEGIN SEQUENCE

		nProperty			:= Self:GetAt( @uPropertyKey )
		IF ( nProperty == 0 )
			BREAK
		EndIF

		uPropertyValue		:= Self:aData[ nProperty ][ SPROPERTY_VALUE ]

	END SEQUENCE

	IF ( Compare( uPropertyValue , "@__PROPERTY_NOT_FOUND__@" ) )
		IF !Empty( uDefaultValue )
			uPropertyValue	:= uDefaultValue
		Else
			uPropertyValue	:= NIL
		EndIF	
	EndIF

Return( uPropertyValue )

/*/
	METHOD:		AddNewProperty
	Autor:		Marinaldo de Jesus
	Data:		04/12/2011
	Descricao:	Adiciona ou Edita uma propriedade
	Sintaxe:	SHASH():Set( uPropertyKey , uValue ) -> lSuccess
/*/
METHOD Set( uPropertyKey , uValue ) CLASS SHASH

	Local lSuccess			:= .F.
	
	Local nProperty

	BEGIN SEQUENCE

		nProperty			:= Self:GetAt( @uPropertyKey )

		IF ( nProperty == 0 )
			aAdd( Self:aData , Array( SPROPERTY_ELEMENTS ) )
			nProperty		:= Len( Self:aData )
		EndIF	

		Self:aData[ nProperty ][ SPROPERTY_KEY   ] := uPropertyKey
		Self:aData[ nProperty ][ SPROPERTY_VALUE ] := uValue

		lSuccess			:= .T.

	END SEQUENCE

Return( lSuccess )

/*/
	METHOD:		Remove
	Autor:		Marinaldo de Jesus
	Data:		04/12/2011
	Descricao:	Remover Determinada Propriedade
	Sintaxe:	SHASH():Remove( uPropertyKey ) -> lSuccess
/*/
METHOD Remove( uPropertyKey ) CLASS SHASH

	Local lSuccess		:= .F.
	
	Local nProperty

	BEGIN SEQUENCE

		nProperty		:= Self:GetAt( @uPropertyKey )
		IF ( nProperty == 0 )
			BREAK
		EndIF

		lSuccess		:= .T.

		aDel( Self:aData , nProperty )
		aSize( Self:aData , Len( Self:aData[ nSession ][ SPROPERTY_POSITION ] ) - 1 )

	END SEQUENCE

Return( lSuccess )

/*/
	METHOD:		GetAll
	Autor:		Marinaldo de Jesus
	Data:		04/12/2011
	Descricao:	Retornar todas as propriedades
	Sintaxe:	SHASH():GetAll( ) -> aAllProperties
/*/
METHOD GetAll() CLASS SHASH
Return( Self:aData )


