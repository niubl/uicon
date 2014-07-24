;ALL by ����Ѫ�� 2009.12.19
 
;�Զ���дU��ͼ��
 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.386
.model flat, stdcall
option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include Comdlg32.inc
includelib Comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN equ 100
DLG_MAIN equ 1000
IDC_FILE equ 101
IDC_BROWSE equ 102
ICO_ICON equ 103
ICO_ICO equ 104
IDC_HIDE equ 105
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.data?
hInstance dd ?
hWinMain dd ?
szFileName db MAX_PATH dup (?)
szProfileName db MAX_PATH dup (?)
szCurrent db MAX_PATH dup (?)
hFile dd ?
Count1 dd ?
Count2 dd ?
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.const
szFilter db 'Text Files(*.ico)',0,'*.ico',0,'All Files(*.*)',0,'*.*',0,0
szNewFile db '\x.ico',0
szErrOpenFile db 'Error To Opean File',0
szBuffer1 db '[autorun]',0dh,0ah
szBuffer2 db 'icon=x.ico',0
szMake db '\autorun.inf',0
szUSB db '��������ѡ��"�����ļ�"�����Բ�ѡ����Ȼ��"�رճ���"���γ�U�̣������²���',0
szCaption db '��ϲ�㣬�����ɹ�',0
szTitle db '��ʾ!!!',0
szWarn db '�뽫�����򿽱���������U�̸�Ŀ¼',0
 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ʾ�����ļ����Ի���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_OpenFile proc
local @stOF:OPENFILENAME
invoke RtlZeroMemory,addr @stOF,sizeof @stOF
mov @stOF.lStructSize,sizeof @stOF
push hWinMain
pop @stOF.hwndOwner
mov @stOF.lpstrFilter,offset szFilter
mov @stOF.lpstrFile,offset szFileName
mov @stOF.nMaxFile,MAX_PATH
mov @stOF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
invoke GetOpenFileName,addr @stOF
ret
 
_OpenFile endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain proc uses ebx edi esi hWnd,wMsg,wParam,lParam
local @szBuffer[128]:byte
local @ps:PAINTSTRUCT
 
mov eax,wMsg
.if eax == WM_CLOSE
invoke EndDialog,hWinMain,NULL
;*********************************************************************
.elseif eax == WM_INITDIALOG
push hWnd
pop hWinMain
 
invoke MessageBox,hWinMain,addr szWarn,addr szTitle,MB_OK
 
invoke LoadIcon,hInstance,ICO_MAIN
invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
 
invoke GetDlgItem,hWinMain,IDOK
invoke EnableWindow,eax,FALSE
 
invoke GetDlgItem,hWinMain,IDC_HIDE
invoke EnableWindow,eax,FALSE
 
invoke GetCurrentDirectory,MAX_PATH,addr szProfileName
invoke lstrcpy,addr szCurrent,addr szProfileName
mov esi,offset szProfileName
invoke lstrlen,esi
mov ecx,offset szNewFile
.if byte ptr [esi+eax-1] == '\'
;'
inc ecx
.endif
invoke lstrcat,esi,ecx
;*********************************************************************
.elseif eax == WM_COMMAND
mov eax,wParam
.if ax == IDC_BROWSE
;*******************************************
invoke _OpenFile
.if eax
invoke GetDlgItem,hWinMain,IDOK
invoke EnableWindow,eax,TRUE
invoke GetDlgItem,hWinMain,IDC_HIDE
invoke EnableWindow,eax,TRUE
invoke SetDlgItemText,hWnd,IDC_FILE,addr szFileName
.endif
;*******************************************
.elseif ax == IDOK
invoke CopyFile,addr szFileName,addr szProfileName,FALSE
mov esi,offset szCurrent
invoke lstrlen,esi
mov ecx,offset szMake
.if byte ptr [esi+eax-1] == '\'
;'
inc ecx
.endif
invoke lstrcat,esi,ecx
invoke CreateFile,addr szCurrent,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
.if eax == INVALID_HANDLE_VALUE
ret
.endif
mov hFile,eax
mov edx,sizeof szBuffer1
invoke WriteFile,hFile,addr szBuffer1,edx,addr Count1,NULL
xor edx,edx
mov edx,sizeof szBuffer2
invoke WriteFile,hFile,addr szBuffer2,edx,addr Count2,NULL
 
invoke CloseHandle,hFile
 
invoke MessageBox,hWinMain,addr szUSB,addr szCaption,MB_OK
;*******************************************
.elseif ax ==IDC_HIDE
invoke SetFileAttributes,addr szCurrent,FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_SYSTEM
invoke SetFileAttributes,addr szProfileName,FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_SYSTEM
.endif
;********************************************************************
.else
mov eax,FALSE
ret
.endif
mov eax,TRUE
ret
_ProcDlgMain endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
invoke GetModuleHandle,NULL
mov hInstance,eax
invoke DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
invoke ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
end start