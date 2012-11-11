.386
.model flat,stdcall
option casemap :none
include \PROGRAMS\CODING~1\compil~1\masm32\include\windows.inc
include \PROGRAMS\CODING~1\compil~1\masm32\include\user32.inc
include \PROGRAMS\CODING~1\compil~1\masm32\include\kernel32.inc
includelib \PROGRAMS\CODING~1\compil~1\masm32\lib\user32.lib
includelib \PROGRAMS\CODING~1\compil~1\masm32\lib\kernel32.lib

WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
BtnYesProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

.data
  hInstance     dd 0
  dlgname       db "PCP",0
  szMsg         db "man, sorry to hear it =(",0
  szTitle	  db "=P",0
  hwndno	  dd ?
  hwndyes       dd ?
  bLeft         BOOL TRUE
  npoint        POINT <?>
  ypoint        POINT <?> 
  OldWndProcY   dd ?

.code
start:
  invoke DialogBoxParam, hInstance, addr dlgname, 0, addr WndProc, 0
  invoke ExitProcess,eax

;takes care of the main window...naturally
WndProc proc hwnd :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD
  LOCAL rect :RECT
  LOCAL point :POINT
  .if uMsg == WM_INITDIALOG
    invoke GetDlgItem, hwnd, IDOK
    mov hwndno, eax
    invoke GetDlgItem, hwnd, IDOK
    mov hwndyes, eax
    invoke GetWindowRect, hwndno, addr rect
    mov eax, rect.left
    mov npoint.x, eax
    mov eax, rect.top
    mov npoint.y, eax
    invoke GetWindowRect, hwndyes, addr rect
    mov eax, rect.left
    mov ypoint.x, eax
    mov eax, rect.top
    mov ypoint.y, eax
    invoke ScreenToClient, hwnd, addr npoint
    invoke ScreenToClient, hwnd, addr ypoint
    invoke GetWindowLong, hwndyes, GWL_WNDPROC
    mov OldWndProcY, eax
    invoke SetWindowLong, hwndyes, GWL_WNDPROC, addr BtnYesProc
  .elseif uMsg == WM_COMMAND
	  mov eax,wParam
    .if ax == IDCANCEL
      invoke MessageBox, hwnd, addr szMsg, addr szTitle, MB_OK
      invoke EndDialog, hwnd, 0
    .endif
  .else
    invoke DefWindowProc, hwnd, uMsg, wParam, lParam
  .endif
  xor eax, eax
ret

WndProc endp

;Takes care of the Yes button
BtnYesProc proc hwnd :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD
  .if uMsg == WM_MOUSEMOVE
    .if bLeft == TRUE
      mov bLeft, FALSE
      invoke SetWindowPos, hwndyes, HWND_TOP, npoint.x, npoint.y, 0, 0, SWP_NOZORDER+SWP_NOSIZE
      invoke SetWindowPos, hwndno, HWND_TOP, ypoint.x, ypoint.y, 0, 0, SWP_NOZORDER+SWP_NOSIZE
    .else
      mov bLeft, TRUE
      invoke SetWindowPos, hwndyes, HWND_TOP, ypoint.x, ypoint.y, 0, 0, SWP_NOZORDER+SWP_NOSIZE
      invoke SetWindowPos, hwndno, HWND_TOP, npoint.x, npoint.y, 0, 0, SWP_NOZORDER+SWP_NOSIZE
    .endif
  .elseif uMsg == WM_KEYDOWN
    mov eax, 1
    ret
  .else
    invoke CallWindowProc, OldWndProcY, hwnd, uMsg, wParam, lParam
  .endif
  ret 
BtnYesProc endp

end start