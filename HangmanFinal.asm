; Hangman Game Final Project.  Matthew Mabrey CSE-210-100  Professor Nagbe
; Play a game of hangman. This program keeps track of the original string, the hidden string,
; and the guessed letters string. It also changes the display based on the amount of incorrect
; guesses. 

INCLUDE Irvine32.inc


.data

hangmanTitle BYTE "-----------HANGMAN GAME-----------", 0

hangmanDisplay BYTE " _________________________", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |  		             ", 0dh, 0ah
BYTE " |  		             ", 0dh, 0ah
BYTE " |  		              ", 0dh, 0ah
BYTE " |\  		             ", 0dh, 0ah
BYTE " | \		              ", 0dh, 0ah
BYTE " |  \		             ", 0dh, 0ah
BYTE " |___\		              ", 0

hangmanHead BYTE " _________________________", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |  		         O", 0dh, 0ah
BYTE " |  		             ", 0dh, 0ah
BYTE " |  		              ", 0dh, 0ah
BYTE " |\  		             ", 0dh, 0ah
BYTE " | \		              ", 0dh, 0ah
BYTE " |  \		             ", 0dh, 0ah
BYTE " |___\		              ", 0

hangmanChest BYTE " _________________________", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |  		         O ", 0dh, 0ah
BYTE " |  		         :", 0dh, 0ah
BYTE " |  		              ", 0dh, 0ah
BYTE " |\  		             ", 0dh, 0ah
BYTE " | \		              ", 0dh, 0ah
BYTE " |  \		             ", 0dh, 0ah
BYTE " |___\		              ", 0

hangmanLeftArm BYTE " _________________________", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |  		         O ", 0dh, 0ah
BYTE " |  		        /: ", 0dh, 0ah
BYTE " |  		              ", 0dh, 0ah
BYTE " |\  		             ", 0dh, 0ah
BYTE " | \		              ", 0dh, 0ah
BYTE " |  \		             ", 0dh, 0ah
BYTE " |___\		              ", 0

hangmanRightArm BYTE " _________________________", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |  		         O", 0dh, 0ah
BYTE " |  		        /:\", 0dh, 0ah
BYTE " |  		              ", 0dh, 0ah
BYTE " |\  		             ", 0dh, 0ah
BYTE " | \		              ", 0dh, 0ah
BYTE " |  \		             ", 0dh, 0ah
BYTE " |___\		              ", 0

hangmanLeftLeg BYTE " _________________________", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |  		         O", 0dh, 0ah
BYTE " |  		        /:\", 0dh, 0ah
BYTE " |  		        /", 0dh, 0ah
BYTE " |\  		             ", 0dh, 0ah
BYTE " | \		              ", 0dh, 0ah
BYTE " |  \		             ", 0dh, 0ah
BYTE " |___\		              ", 0

hangmanRightLeg BYTE " _________________________", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |                       |", 0dh, 0ah
BYTE " |  		         O", 0dh, 0ah
BYTE " |  		        /:\", 0dh, 0ah
BYTE " |  		        / \", 0dh, 0ah
BYTE " |\  		             ", 0dh, 0ah
BYTE " | \		              ", 0dh, 0ah
BYTE " |  \		             ", 0dh, 0ah
BYTE " |___\		              ", 0


prompt BYTE "To begin type in word or phrase you would like others to guess: ", 0
guessedPrompt BYTE "The letters guessed so far: ", 0
letterPrompt BYTE "Guess a letter: ", 0
correctPrompt BYTE "You guessed correctly!", 0
incorrectPrompt BYTE "You guessed incorrectly!", 0

winMsg BYTE "Congratulations! You have won!", 0
lossMsg BYTE "You are out of guesses! Game Over!", 0
showWord BYTE "The word/phrase to guess was: ", 0

guessedBuffer BYTE 27 DUP(0)	;collection of all letters guessed so far (max 27 because alphabet is 26 + 1 for null)
guessedIndex DWORD 0

hiddenStringBuffer BYTE 51 DUP(0)

stringBuffer BYTE 51 DUP(0)		;the string to be guessed
stringBufferSize DWORD ?

guessedLetter BYTE ?
guessBoolean BYTE 0
gameOver BYTE 0
gameWon BYTE 0 
gameLost BYTE 0

.code
main PROC
		
		call DisplayHangman		
		call InputTheString
		call HideString

		mov ebx, 0		;index for hangmanParts 
		
	.WHILE gameOver == 0 
			call Clrscr
			call DisplayHangman
			call DisplayGuessed
			call DisplayHidden
			call InputGuessLetter
			call CheckString

			mov cl, guessedLetter
			mov esi, guessedIndex
		
			mov guessedBuffer[esi], cl	;move the guessed letter to the collection of all letters guessed so far
			inc guessedIndex		;move to next space in the buffer

		
			call modifyHangman
			call GameOverCheck

	.ENDW 

	call Clrscr
	call DisplayHangman

	.IF(gameWon == 1)
		mov edx, OFFSET winMsg
	.ELSEIF(gameLost == 1)
		mov edx, OFFSET lossMsg
	.ENDIF
	call WriteString
	call Crlf

	mov edx, OFFSET showWord		; show the word after game ends
	call WriteString
	mov edx, OFFSET stringBuffer	
	call WriteString
	call Crlf

	exit


main ENDP


;-----------------------------------------------------
DisplayHangman PROC
;
; Displays the hangman art.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
		
		pushad

		mov edx, OFFSET hangmanTitle
		call WriteString

		call Crlf
		mov edx, OFFSET hangmanDisplay
		call WriteString

		call Crlf
		call Crlf
	
		
		popad
		ret

DisplayHangman ENDP


;-----------------------------------------------------
InputTheString PROC
;
; Prompts user for a string. Saves the string
; and its length.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------

		pushad
		mov edx, OFFSET prompt			;display prompt for input string
		call WriteString
		mov edx, OFFSET stringBuffer			;point to the buffer
		mov ecx, SIZEOF stringBuffer			;specify max characters
		call ReadString
		mov stringBufferSize, eax

		INVOKE Str_copy, OFFSET stringBuffer, OFFSET hiddenStringBuffer
		
		call Crlf

		popad
		ret

InputTheString ENDP


;-----------------------------------------------------
HideString PROC
;
; Translates the string to a series of underscores and spaces
; for the player to guess.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------

		pushad
		mov ecx, stringBufferSize		;set loop counter to size of buffer to hide string
		mov esi, 0		; set index to 0


		ConvertString:
				.IF(hiddenStringBuffer[esi] != ' ')
					mov hiddenStringBuffer[esi], '-'
				.ENDIF

				inc esi

		loop ConvertString

		popad
		ret

HideString ENDP


;-----------------------------------------------------
DisplayGuessed PROC
;
; Displays the letters guessed so far.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------

		pushad
		mov edx, OFFSET guessedPrompt
		call WriteString
		mov edx, OFFSET guessedBuffer
		call WriteString
		call Crlf

		popad
		ret


DisplayGuessed ENDP


;-----------------------------------------------------
DisplayHidden PROC
;
; Displays the hidden string with correct letters guessed
; so far.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	
	pushad
	mov edx, OFFSET hiddenStringBuffer
	call WriteString
	call Crlf
	call Crlf

	popad
	ret
		
DisplayHidden ENDP


;-----------------------------------------------------
InputGuessLetter PROC
;
; Gets the input guess letter and checks the string
; for a match.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	
	pushad
	mov edx, OFFSET letterPrompt
	call WriteString
	call ReadChar		
	mov guessedLetter, al					;read char input and store as the letter guessed
	
	popad
	ret

InputGuessLetter ENDP

;-----------------------------------------------------
CheckString PROC
;
; Checks the string for any matches to put in the
; correct hidden string spot.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	
	pushad
	mov ebx, 0				; set ebx to 0 so that we can see after the loop if a match was found
	mov ecx, stringBufferSize		; set loop counter equal to string length
	mov esi, 0				; set index to 0
	mov al, guessedLetter

	L1:
			.IF(stringBuffer[esi] == al)
				mov hiddenStringBuffer[esi], al			;change the hidden string spot '-' to the letter found
				mov ebx, 1								;set ebx to 1 if any match is found
			.ENDIF
			inc esi


			loop L1

	.IF(ebx == 1)
		mov guessBoolean, 1			;letter guessed correct
	.ELSEIF(ebx == 0)
		mov guessBoolean, 0			;letter guessed incorrect
	.ENDIF

	.IF(guessBoolean == 1)
		mov edx, OFFSET correctPrompt
	.ELSE
		mov edx, OFFSET incorrectPrompt
	.ENDIF
	call writeString
	call Crlf
	call WaitMsg


	popad
	ret
		
CheckString ENDP

;-----------------------------------------------------
ModifyHangman PROC
;
; Potentially modifies the body of the hangman if
; the letter guessed was wrong.
; Receives: EBX register for index
; Returns: EBX increased if incorrect guess
;-----------------------------------------------------
	

	.IF (guessBoolean == 0)

		.IF(ebx == 0)
		INVOKE Str_copy, OFFSET hangmanHead, OFFSET hangmanDisplay

		.ELSEIF(ebx == 1)
		INVOKE Str_copy, OFFSET hangmanChest, OFFSET hangmanDisplay

		.ELSEIF(ebx == 2)
		INVOKE Str_copy, OFFSET hangmanLeftArm, OFFSET hangmanDisplay
		
		.ELSEIF(ebx == 3)
		INVOKE Str_copy, OFFSET hangmanRightArm, OFFSET hangmanDisplay

		.ELSEIF(ebx == 4)
		INVOKE Str_copy, OFFSET hangmanLeftLeg, OFFSET hangmanDisplay

		.ELSEIF(ebx == 5)
		INVOKE Str_copy, OFFSET hangmanRightLeg, OFFSET hangmanDisplay
		mov gameLost, 1
		.ENDIF
		
		inc ebx

	.ENDIF

	
	ret
		
ModifyHangman ENDP

;-----------------------------------------------------
GameOverCheck PROC
;
; Checks to see if any conditions for the end of the
; game are met. 
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------

		pushad
		mov esi, 0 
		mov ecx, stringBufferSize
		mov edx, 0

		.IF(gameLost == 1)
		mov gameOver, 1
		.ENDIF

		L2:
			.IF(hiddenStringBuffer[esi] == '-')
			mov edx, 1
			.ENDIF
			inc esi

			loop L2

		.IF(edx == 0)
		mov gameWon, 1
		mov gameOver, 1
		.ENDIF

		popad
		ret

GameOverCheck ENDP

END main


