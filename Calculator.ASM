include 'win32ax.inc'

.data
    szClassName db "CalculatorClass", 0
    szWindowTitle db "Calculator", 0
    szButtonText0 db "0", 0
    szButtonText1 db "1", 0
    szButtonText2 db "2", 0
    szButtonText3 db "3", 0
    szButtonText4 db "4", 0
    szButtonText5 db "5", 0
    szButtonText6 db "6", 0
    szButtonText7 db "7", 0
    szButtonText8 db "8", 0
    szButtonText9 db "9", 0
    szButtonTextPlus db "+", 0
    szButtonTextEqual db "=", 0
    szButtonTextSub db "-", 0
    szButtonTextMul db "*", 0
    szButtonTextDiv db "/", 0
    szButtonTextMod db "%", 0
    current db "", 0
    szDisplayText db "0", 0

.data
    hInstance dd ?
    hwndDisplay dd ?
    msg MSG
    wc WNDCLASS
    operand1 dd ?
    operand2 dd ?
    result dd ?
    isAdding db 0
    isSub db 0
    isMul db 0
    isDiv db 0
    isMod db 0
    isoperation db  0

.code
start:

    ; Register the window class
    mov eax, szClassName
    mov [wc.lpfnWndProc], WindowProc
    mov [wc.hInstance], eax
    mov [wc.lpszClassName], szClassName
    mov [wc.hbrBackground], COLOR_BTNFACE + 1
    invoke RegisterClass, wc

    ; Create the main window
    invoke CreateWindowEx, 0, szClassName, szWindowTitle, WS_OVERLAPPEDWINDOW, \
                           CW_USEDEFAULT, CW_USEDEFAULT, 250, 400, 0, 0, [hInstance], 0

    ; Show and update the window
    invoke ShowWindow, eax, SW_SHOWNORMAL
    invoke UpdateWindow, eax

    ; Message loop
message_loop:
    invoke GetMessage, msg, 0, 0, 0
    test eax, eax
    jz exit_program
    invoke TranslateMessage, msg
    invoke DispatchMessage, msg
    jmp message_loop

exit_program:
    invoke ExitProcess, 0

proc WindowProc hwnd, uMsg, wParam, lParam
    cmp [uMsg], WM_CREATE
    je .create_controls
    cmp [uMsg], WM_COMMAND
    je .handle_command
    cmp [uMsg], WM_DESTROY
    je .destroy_window

    ; Default window procedure
    invoke DefWindowProc, [hwnd], [uMsg], [wParam], [lParam]
    ret

.create_controls:
    ; Create display area
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, "STATIC", szDisplayText, \
                           WS_VISIBLE or WS_CHILD or SS_CENTER, \
                           10, 10, 220, 50, [hwnd], 100, [hInstance], 0
    mov [hwndDisplay], eax

    ; Create buttons for numbers 0-9
    invoke CreateWindowEx, 0, "BUTTON", szButtonText0, WS_VISIBLE or WS_CHILD, \
                           10, 70, 50, 50, [hwnd], 101, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText1, WS_VISIBLE or WS_CHILD, \
                           70, 70, 50, 50, [hwnd], 102, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText2, WS_VISIBLE or WS_CHILD, \
                           130, 70, 50, 50, [hwnd], 103, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText3, WS_VISIBLE or WS_CHILD, \
                           190, 70, 50, 50, [hwnd], 104, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText4, WS_VISIBLE or WS_CHILD, \
                           10, 130, 50, 50, [hwnd], 105, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText5, WS_VISIBLE or WS_CHILD, \
                           70, 130, 50, 50, [hwnd], 106, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText6, WS_VISIBLE or WS_CHILD, \
                           130, 130, 50, 50, [hwnd], 107, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText7, WS_VISIBLE or WS_CHILD, \
                           190, 130, 50, 50, [hwnd], 108, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText8, WS_VISIBLE or WS_CHILD, \
                           10, 190, 50, 50, [hwnd], 109, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonText9, WS_VISIBLE or WS_CHILD, \
                           70, 190, 50, 50, [hwnd], 110, [hInstance], 0


    ; Create operator and equal buttons
    invoke CreateWindowEx, 0, "BUTTON", szButtonTextPlus, WS_VISIBLE or WS_CHILD, \
                           130, 190, 50, 50, [hwnd], 111, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonTextEqual, WS_VISIBLE or WS_CHILD, \
                           190, 250, 50, 50, [hwnd], 112, [hInstance], 0

        invoke CreateWindowEx, 0, "BUTTON", szButtonTextSub, WS_VISIBLE or WS_CHILD, \
                           190,190, 50, 50, [hwnd], 113, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonTextMul, WS_VISIBLE or WS_CHILD, \
                           10, 250, 50, 50, [hwnd], 114, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonTextDiv, WS_VISIBLE or WS_CHILD, \
                           70, 250, 50, 50, [hwnd], 115, [hInstance], 0

    invoke CreateWindowEx, 0, "BUTTON", szButtonTextMod, WS_VISIBLE or WS_CHILD, \
                           130, 250, 50, 50, [hwnd], 116, [hInstance], 0
    ret

.handle_command:
    cmp word [wParam], 101
    je .handle_0
    cmp word [wParam], 102
    je .handle_1
    cmp word [wParam], 103
    je .handle_2
    cmp word [wParam], 104
    je .handle_3
    cmp word [wParam], 105
    je .handle_4
    cmp word [wParam], 106
    je .handle_5
    cmp word [wParam], 107
    je .handle_6
    cmp word [wParam], 108
    je .handle_7
    cmp word [wParam], 109
    je .handle_8
    cmp word [wParam], 110
    je .handle_9
    cmp word [wParam], 111
    je .handle_plus
    cmp word [wParam], 112
    je .handle_equal
    cmp word [wParam], 113
    je .handle_sub
    cmp word [wParam], 114
    je .handle_mul
    cmp word [wParam], 115
    je .handle_div
    cmp word [wParam], 116
    je .handle_mod
    ret

.handle_0:

  cmp byte [isoperation], 0
    je .store_operand1_0
    mov eax,[operand2]
    imul eax,10
    add eax,0
    mov [operand2], eax
    cmp byte [current],0
    je .only_zero
    jne .append
    ret

.store_operand1_0:
    mov eax,[operand1]
    imul eax,10
    add eax,0
    mov [operand1], eax
    cmp byte [current],0
    je .only_zero
    jne .append
    ret
.only_zero:
  invoke SetWindowText, [hwndDisplay], szButtonText0
  ret
.append:
    lea eax, [current]
    lea ebx, [szButtonText0]
    invoke wsprintf, eax, "%s%s", current, szButtonText0
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    ret
.handle_1:
    ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText1]
    invoke wsprintf, eax, "%s%s", current, szButtonText1
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_1
    mov eax,[operand2]
    imul eax,10
    add eax,1
    mov [operand2], eax

    ret

.store_operand1_1:
    mov eax,[operand1]
    imul eax,10
    add eax,1
    mov [operand1], eax
    ret

.handle_2:
        ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText2]
    invoke wsprintf, eax, "%s%s", current, szButtonText2
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_2
    mov eax,[operand2]
    imul eax,10
    add eax,2
    mov [operand2], eax
    ret

.store_operand1_2:
    mov eax,[operand1]
    imul eax,10
    add eax,2
    mov [operand1], eax
    ret

.handle_3:
    ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText3]
    invoke wsprintf, eax, "%s%s", current, szButtonText3
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_3
    mov eax,[operand2]
    imul eax,10
    add eax,3
    mov [operand2], eax
    ret

.store_operand1_3:
    mov eax,[operand1]
    imul eax,10
    add eax,3
    mov [operand1], eax
    ret

.handle_4:
        ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText4]
    invoke wsprintf, eax, "%s%s", current, szButtonText4
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_4
    mov eax,[operand2]
    imul eax,10
    add eax,4
    mov [operand2], eax
    ret

.store_operand1_4:
    mov eax,[operand1]
    imul eax,10
    add eax,4
    mov [operand1], eax
    ret

.handle_5:
        ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText5]
    invoke wsprintf, eax, "%s%s", current, szButtonText5
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_5
    mov eax,[operand2]
    imul eax,10
    add eax,5
    mov [operand2], eax
    ret

.store_operand1_5:
    mov eax,[operand1]
    imul eax,10
    add eax,5
    mov [operand1], eax
    ret

.handle_6:
   ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText6]
    invoke wsprintf, eax, "%s%s", current, szButtonText6
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_6
    mov eax,[operand2]
    imul eax,10
    add eax,6
    mov [operand2], eax
    ret

.store_operand1_6:
    mov eax,[operand1]
    imul eax,10
    add eax,6
    mov [operand1], eax
    ret
.handle_7:
        ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText7]
    invoke wsprintf, eax, "%s%s", current, szButtonText7
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================  7
    cmp byte [isoperation], 0
    je .store_operand1_7
    mov eax,[operand2]
    imul eax,10
    add eax,7
    mov [operand2], eax
    ret

.store_operand1_7:
    mov eax,[operand1]
    imul eax,10
    add eax,7
    mov [operand1], eax
    ret
.handle_8:
       ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText8]
    invoke wsprintf, eax, "%s%s", current, szButtonText8
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_8
    mov eax,[operand2]
    imul eax,10
    add eax,8
    mov [operand2], eax
    ret

.store_operand1_8:
    mov eax,[operand1]
    imul eax,10
    add eax,8
    mov [operand1], eax
    ret
.handle_9:
        ;APPEND the last string
    lea eax, [current]
    lea ebx, [szButtonText9]
    invoke wsprintf, eax, "%s%s", current, szButtonText9
    ;========================
    ;print
    invoke SetWindowText, [hwndDisplay], current
    ;===================
    cmp byte [isoperation], 0
    je .store_operand1_9
    mov eax,[operand2]
    imul eax,10
    add eax,9
    mov [operand2], eax
    ret

.store_operand1_9:
    mov eax,[operand1]
    imul eax,10
    add eax,9
    mov [operand1], eax
    ret
.handle_plus:
    ; Set addition mode
    mov byte [isAdding], 1
     mov byte [isoperation],1
    invoke SetWindowText, [hwndDisplay], szButtonTextPlus
    mov byte [current], 0
    ret

.handle_sub:
 ; Set subtraction mode
  mov byte [isSub],1
  mov byte [isoperation],1
  invoke SetWindowText, [hwndDisplay], szButtonTextSub
  mov byte [current], 0
    ret
.handle_mul:
; Set Multiblication mode
  mov byte [isMul],1
  mov byte [isoperation],1
  invoke SetWindowText, [hwndDisplay], szButtonTextMul
  mov byte [current], 0
    ret

.handle_div:
; Set Division mode
  mov byte [isDiv],1
  mov byte [isoperation],1
  invoke SetWindowText, [hwndDisplay], szButtonTextDiv
  mov byte [current], 0
    ret
.handle_mod:
; Set Modulation mode
  mov byte [isMod],1
  mov byte [isoperation],1
  invoke SetWindowText, [hwndDisplay], szButtonTextMod
  mov byte [current], 0
    ret
.handle_equal:
    ; Perform addition and show result
    mov byte [current], 0
    cmp byte [isoperation], 1
    jne .reset
     cmp byte [isAdding], 1
    je .add
         cmp byte [isMul], 1
    je .multiply
         cmp byte [isDiv], 1
    je .divide
    cmp  byte [isSub],1
    je .sub
    cmp  byte [isMod],1
    je .mod

    ;=============================================
   .add:
       mov eax, [operand1]
    add eax, [operand2]
    mov [result], eax
     lea eax, [szDisplayText]
    invoke wsprintf, eax, "%d", [result]
    invoke SetWindowText, [hwndDisplay], szDisplayText

    ; Reset operands and flags after displaying result
    mov dword [operand1], 0
    mov dword [operand2], 0
    mov dword [result], 0
    mov byte [isAdding], 0
    mov byte [isoperation], 0
    ret
    ;=============================
    .sub:
     mov eax, [operand1]
    sub eax, [operand2]
    mov [result], eax
     lea eax, [szDisplayText]
    invoke wsprintf, eax, "%d", [result]
    invoke SetWindowText, [hwndDisplay], szDisplayText

    ; Reset operands and flags after displaying result
    mov dword [operand1], 0
    mov dword [operand2], 0
    mov dword [result], 0
    mov byte [isSub],0
    mov byte [isoperation], 0
    ret
    ;==============================
    .divide:
    ; Load operand1 and operand2 into registers
    mov eax, [operand1]       ; Load operand1 into EAX
    mov ebx, [operand2]       ; Load operand2 into EBX

    ; Check for division by zero
    cmp ebx, 0                ; Compare operand2 with 0
    je .handle_zero_division  ; Jump if operand2 is zero

    ; Perform fixed-point division with better precision handling
    mov ecx, 100
    imul eax, ecx
    cdq
    idiv ebx


    ; Separate integer and fractional parts
    mov ebx, 100              ; Scaling factor
    xor edx, edx              ; Clear EDX for safety
    div ebx                   ; EAX = integer part, EDX = fractional part

    ; Store result (integer part)
    mov [result], eax         ; Store the integer part (e.g., 0 for 0.89)

    ; Convert result to string
    lea esi, [szDisplayText]  ; Load the address of szDisplayText
    invoke wsprintf, esi, "%d.%02d", eax, edx ; Format as float with 2 decimals
    invoke SetWindowText, [hwndDisplay], szDisplayText ; Display the result

    ; Reset operands and flags after calculation
    mov dword [operand1], 0
    mov dword [operand2], 0
    mov dword [result], 0
    mov byte [isoperation], 0
    mov byte [isDiv], 0
    ret


    ;===========================================
    .mod:
     ; Load operands into registers
    mov eax, [operand1]  ; Load operand1 into eax
    mov ebx, [operand2]  ; Load operand2 into ebx

    ; Check for division by zero
    cmp ebx, 0
    je .handle_zero_division  ; Jump if operand2 is zero

    ; Perform division to get the remainder
    ; idiv divides eax by ebx; remainder goes into edx
    idiv ebx                ; eax / ebx => quotient in eax, remainder in edx

    ; Store the remainder in result
    mov [result], edx       ; Store remainder (edx) in result

    ; Convert result to string for display
    lea esi, [szDisplayText]
    invoke wsprintf, esi, "%d", edx  ; Format the remainder
    invoke SetWindowText, [hwndDisplay], szDisplayText  ; Display the remainder

    ; Reset operands and flags after calculation
    mov dword [operand1], 0
    mov dword [operand2], 0
    mov dword [result], 0
   mov byte [isMod],0
    mov byte [isoperation], 0
    ret
    ;===========================================
    .handle_zero_division:
    ; Display an error message for division by zero
    lea eax, [szDisplayText]
    invoke lstrcpy, eax, "Error"
    invoke SetWindowText, [hwndDisplay], szDisplayText

    ; Reset state after showing the error
    mov dword [operand1], 0
    mov dword [operand2], 0
    mov dword [result], 0
   mov byte [isDiv],0
    mov byte [isoperation], 0
    ret

    ;==============================
    .multiply:
    mov eax, [operand1]
    imul eax, [operand2]
    mov [result], eax
    lea eax, [szDisplayText]
    invoke wsprintf, eax, "%d", [result]
    invoke SetWindowText, [hwndDisplay], szDisplayText
        mov dword [operand1], 0
    mov dword [operand2], 0
    mov dword [result], 0
    mov byte [isMul],0
    mov byte [isoperation], 0
    ret
    ;==============================
.reset:
    mov byte [isAdding], 0
    mov byte [isSub], 0
    mov byte [isMul], 0
    mov byte [isDiv], 0
    mov byte [isoperation], 0
    invoke SetWindowText, [hwndDisplay], szDisplayText
    ret

.destroy_window:
    invoke PostQuitMessage, 0
    ret
endp

.end start
