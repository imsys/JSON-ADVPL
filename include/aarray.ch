/*----------------------------------------------------------------------*\
 * Associative Arrays for AdvPL
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
 * The SHASH class is an adapted version of Marinaldo de Jesus' THASH Class.
 * 
 *----------------------------------------------------------------------*
 *
 * -- How to install this program:
 *
 * 1 - Add the file SHash.prg to your project.
 *
 * 2 - Compile SHash.prg.
 *
 * 3 - Include the header file to any project you want to use it:
 *
 *   #Include "aarray.ch"
 *
 * 4 - Use it. ;)
 *
 *
 * -- How to use Associative Arrays:
 *
 * It's easier to learn from examples, isn't it?
 *
 * Example:
 *
 * // Start an Associative Array
 * aaFriends := Array(#)
 *
 * // Start another another Associative Array on top of the other
 * aaFriends[#"Arthur"] := Array(#)
 *
 * // Set values:
 * aaFriends[#"Arthur"][#"Name"] := "Arthur"
 * aaFriends[#"Arthur"][#"Account"] := 230251
 * aaFriends[#"Arthur"][#"Work"] := "Software Developer"
 * 
 * // Start a new Associative Array and set values
 * aaFriends[#"David"] := Array(#)
 * aaFriends[#"David"][#"Name"] := "David"
 * aaFriends[#"David"][#"Account"] := 187204
 * aaFriends[#"David"][#"Work"] := "Web Designer"
 *
 * // Let's do something interesting:
 *
 * aaFriends[#"David"][#"Best Friend"] := aaFriends[#"Arthur"]
 *
 * // And test it:
 *
 * Alert (aaFriends[#"David"][#"Best Friend"][#"Name"])
 * Alert (aaFriends[#"David"][#"Best Friend"][#"Work"])
 *
 * // We can also mix it with the regular Array:
 * aaFriends[#"Arthur"][#"Friends"] := Array(1)
 * aaFriends[#"Arthur"][#"Friends"][1] := aaFriends[#"David"]
 *
 * Alert (aaFriends[#"Arthur"][#"Friends"][1][#"Name"])
 *
 *
 * -- How does it work on the background?
 *
 * When we create an Associative Array, we are in reality instantiating
 * a Class and creating an Object.
 *
 * Take a look at it working, this:
 * aaFriends := Array(#)
 * aaFriends[#"David"] := Array(#)
 * aaFriends[#"David"][#"Account"] := 187204
 * 
 * is translated to this by the precompiler:
 * aaFriends := SHash():New()
 * aaFriends:Set("David", SHash():New())
 * aaFriends:Get("David"):Set("Account", 187204)
 *
 * The SHash object has the aData array that stores all the data, so you
 * can easily access all the data thought a loop:
 *
 * For i := 1 to len(aaFriends:aData)
 *   QOut( aaFriends:aData[i][1] +': '+ aaFriends:aData[i][2] )
 * Next
 *
\*----------------------------------------------------------------------*/

#IFNDEF _AARRAY_CH

    #DEFINE _AARRAY_CH
	
	#IFNDEF __HARBOUR__
		#include "shash.ch" 

		#xtranslate \[\#<k>\] := <v>        => :Set(<k>,<v>)
		#xtranslate \[\#<k>\]               => :Get(<k>)
		#xtranslate Array(\#)               => SHash():New()
	#ELSE
		#xtranslate \[\#<k>\] := <v>        => \[<k>\] := <v>
		#xtranslate \[\#<k>\]               => \[<k>\]
		#xtranslate Array(\#)               => \{\=\>\}    
	#ENDIF

#ENDIF
