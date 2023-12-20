.386
.model flat,stdcall
option casemap:none

include windows.inc
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
includelib msvcrt.lib

.data
	;���ںͿؼ���ص���
	hInstance dd ?  ;���Ӧ�ó���ľ��
	hWinMain dd ?   ;��Ŵ��ڵľ��
	showButton byte 'button',0
	button db 'button',0
	showStart byte 'start',0
	showPause byte 'pause',0
	showEnd byte 'end',0
	sEnd db 'MyTetris',0
	sScore db '000000',0
	sBestScore db '000000',0
;���ɷ���
;0,1,2,3,4,5,6
block db 2,1,3,4 ;I
 db 22,2,42,41   ;J
 db 21,1,41,42   ;L
 db 2,1,21,22    ;O
 db 2,3,22,21    ;S
 db 2,1,3,22     ;T
 db 2,1,22,23    ;Z
;����ѡ�񷽿�������
	rand dw 6
	;41*20 ��ָʾ���󣬵�41�в������ʹ��
	;id�Ǵ�1��ʼ��

	mapArray	db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "00000000000000000000"
db "55555555555555555555"
	
	;�����½��ķ���
	;�����ƶ� pos+20
	;�����ƶ� pos+1
		;���pos%20==0�������������ƶ�
	;�����ƶ� pos-1
		;���pos%20==1,�����������ƶ�
	;��� pos'��λ�����з�0�ģ�
		;�����ʱ�������ƶ��������ƶ�
		;�����ʱ�������ƶ�����ֹ�������µķ���

	;�ĸ����ֵ�����	
	fallBlock dw 1
			  dw 2
			  dw 3
			  dw 4
	;�ĸ����ֵ���ʱ����	
	fallBlockTemp dw 1
			  dw 2
			  dw 3
			  dw 4
	;��¼�������ɫ49,50,51,52
	fallColor db 49
	;��¼���������������ƶ�
	fallDelta db 0
	fallLDelta db 0
	fallRDelta db 0
	accTric db 0
	fallTurn db 0
	;��ǰ��0����յ�״̬,1:���ڵ��䷽��,2����ͣ��״̬
	procState db 0

	;��ǰ��0:û�����ڵ���ķ��飬��Ҫ����
	;��ǰ��1:�����ڵ���ķ���
	fallState db 0

	;�û��ķ���
	score dw 0
	bestscore dw 0
	;bestscore dq 0h

	;һ��flag
	flag db 0
	;��һ��flag
	flag1 db 0
	flag2 db 0
	;��ת�õ�����ʱ����
	tempx dw ?
	tempy dw ?
	;����rect�õ�����ʱ����
	rtLeft dw ?
	rtTop dw ?
	rtBottom dw ?
	rtRight dw ?
	;������
	fallTime dw 240
	fallHigher dw 120
	fallHigh dw 240
	fallLow dw 500
.const
szClassName db 'MyClass',0
szCaptionMain db 'MyTetris',0
szText db "��ᶪʧ��ǰ��Ϸ����,��ȷ��Ҫ������ǰ��Ϸ��?",0
szEndText db "��Ϸ����",0
szNoteA db "A:����",0
szNoteD db "D:����",0
szNoteQ db "Q:����",0
szNoteE db "E:��ת",0
szScore db "SCORE:",0
szBestScore db "BEST SCORE:",0
showQuick db "Higher",0
showMid db "High",0
showSlow db "Low",0
.code
;-----------------
;intת��str
;-----------------
_int2str proc C x,sAddr
;��
	mov eax,sAddr
	mov esi,0
	.while esi<6
		mov ebx,eax
		add ebx,esi
		mov byte ptr [ebx],48
		inc esi
	.endw
;��
	mov eax,x
	mov esi,5
	add esi,sAddr
	.while eax>0
		xor edx,edx
		mov ecx,10
		div ecx

		mov ebx,edx
		add ebx,48
		mov BYTE PTR [esi],bl
		sub esi,1
	.endw
	ret
_int2str endp
;-----------------
;�޸�mapArray
;-----------------
_SetMap proc C idc,val
	lea eax,mapArray
	add eax,idc
	dec eax
	mov ecx,val
	mov byte ptr [eax],cl
	ret
_SetMap endp
;-----------------
;��һ��С���id��ȡx,y����
;-----------------
_GetPos proc C idc
	xor eax,eax
	mov eax,idc
	xor edx,edx
	mov ecx,20
	div ecx
	;edx�д��������eax�д����
	.if edx==0
		mov edx,20
		sub eax,1
	.endif
	ret
_GetPos endp
;-----------------
;��һ��С���id��ȡ�ڴ����е�x,y���꣨block���½ǣ�
;-----------------
_GetWinPos proc C a,d
	;�����к���ֵ������Ļ����
	imul eax, a, 18;
	imul edx, d, 18; 
	;��ʼ����
	add edx,125;��Ļx����
	add eax, 50 ;��Ļy����
	ret
_GetWinPos endp
_GetWinRect proc C
	mov esi ,0
	.while esi<4
		imul ebx,esi,2
		add ebx,offset fallBlock
		mov bx,word ptr [ebx]
		invoke _GetPos,bx
		invoke _GetWinPos,eax,edx
		.if esi==0
			mov rtBottom,ax
			sub ax,18
			mov rtTop,ax
			mov rtRight,dx
			sub dx,18
			mov rtLeft,dx
		.else
			.if ax > rtBottom
				mov rtBottom,ax
			.endif
			sub ax,18
			.if ax < rtTop
				mov rtTop,ax
			.endif
			.if dx > rtRight
				mov rtRight,dx
			.endif
			sub dx,18
			.if dx < rtLeft
				mov rtLeft,dx
			.endif
		.endif
		inc esi
	.endw
	ret
_GetWinRect endp
;-----------------
;��ת
;-----------------
_TurnTetris proc C
	invoke _GetPos,fallBlock
	mov tempx,ax
	mov tempy,dx
	;���ŵ�һ������ת,�Ȱ���ת֮��Ľ���ŵ�temp
	mov esi,1
	.while esi<4
		;�Ȱ�mapArray�оɵ�����
		imul ebx,esi,2
		add ebx,offset fallBlock
		invoke _SetMap,word ptr [ebx],48
		mov ax ,word ptr [ebx]
		invoke _GetPos,ax
		sub ax,tempx
		sub dx,tempy

		.if ax >= 0
			.if dx >= 0
				imul ax,ax,-1
			.elseif dx < 0
				imul dx,dx,-1
			.endif
		.elseif ax < 0
			.if dx >= 0
				imul dx,dx,-1
			.elseif dx < 0
				imul ax,ax,-1
			.endif
		.endif
		add ax,tempy
		add dx,tempx
		imul dx,dx,20
		add ax,dx
		;ax�����µ�id
		imul ebx, esi,2
		add ebx,offset fallBlockTemp
		mov word ptr [ebx],ax
		;���ﻹû�н�����ײ���
		inc esi
	.endw
	;�����쳣���֮���پ���
	mov flag,0
	mov flag1,0
	mov flag2,0
	mov esi,0
	
	.while esi<4
		imul ebx,esi,2
		add ebx,offset fallBlockTemp
		mov bx,word ptr [ebx]
		xor edx,edx
		mov dx,bx
		lea eax,mapArray
		add eax,edx
		dec eax
		.if byte ptr [eax]!=48
			mov flag,1
		.endif
		invoke _GetPos,bx
		.if edx==1
			mov flag1,1
		.endif
		.if edx==20
			mov flag2,1
		.endif
		add esi,1
	.endw
	.if flag1==1 && flag2==1
		mov flag,1
	.endif
	;���û�����⣬ִ���޸�
	.if flag==0
		mov esi,1
		.while esi<4
			imul ebx,esi,2
			add ebx,offset fallBlock
			;��֮ǰ��mapΪ0
			invoke _SetMap,word ptr [ebx],48
			;���µ�mapΪcolor
			imul edx,esi,2
			add edx,offset fallBlockTemp
			mov dx,word ptr [edx]
			invoke _SetMap,dx,fallColor
			;�ı�fallBlock�е�ֵ
			mov word ptr [ebx],dx
			inc esi
		.endw
	.endif
	ret 
_TurnTetris endp
;-----------------
;�������
;-----------------
_CheckRow proc C
	mov esi,0
	lea eax,mapArray 
	.while esi<800
		mov ebx,eax
		add ebx,esi
		mov edi,0
		.while edi<20
			.break.if BYTE PTR [ebx]==48
			.if edi==19
				;����������һ��
					add score,01h
					mov eax,esi
					.while 1
						mov ecx,ebx
						sub ecx,20
						xor edx,edx
						mov dl,BYTE PTR [ecx]
						mov BYTE PTR [ebx],dl
						.break .if eax==20
						sub eax,1
						sub ebx,1
					.endw
				xor eax,eax
				mov eax,1
				ret 
			.endif
			add ebx,1
			add edi,1
		.endw
		add esi,20
	.endw

	xor eax,eax
	ret
_CheckRow endp
;-----------------
;��������� �����edx
;-----------------
_CreateRandom proc C x
	local @sysTime:SYSTEMTIME
	invoke GetSystemTime, addr @sysTime
	mov ax,@sysTime.wMilliseconds
	xor edx,edx
	mov ecx,x
	div ecx
	ret
_CreateRandom endp
;-----------------
;�����µķ���
;-----------------
_CreateBlock proc C 
	
		;�����λ��
	;���ѡ��һ�ַ�������ͣ�ȡģ�Ľ����edx��
	invoke _CreateRandom,7



	;ebx�д�ŵ���block�ĵ�ַ
	xor ebx,ebx
	lea ebx,offset block
	;��������
	imul edx,edx,4
	add ebx,edx
	mov esi,1
	invoke _CreateRandom,15
	;eax�д�ŵ���fallBLock�ĵ�ַ
	xor eax,eax
	lea eax,fallBlock
	.while esi<=4
		xor ecx,ecx
		mov cl,BYTE PTR [ebx]
		add cl,dl;λ���ƶ���
		mov WORD PTR [eax],cx
		add eax,2
		add ebx,1
		add esi,1
	.endw
	;��ǰ����������ķ���
	mov fallState,1
	;�������ɫ
	xor edx,edx
	lea edx,fallColor
	add BYTE PTR [edx],1
	;49��50��51��52
	.if BYTE PTR [edx] > 52
		mov BYTE PTR [edx],49
	.endif
	ret
_CreateBlock endp
;-----------------------
;��ײ��飬flag��1 ��һ�����ƶ��ᵼ����ײ �� edge:0 fall;1 left;20 right;-1 acc
;-----------------------
_CheckLLimits proc C edge
	mov flag,0
	.if edge>0
		xor esi,esi
		xor eax,eax
		mov esi,1
		;ebx: fallBlock ��ָ��
		lea ebx,fallBlock
		.while esi<=4
			;----------------
			;�����߽�����
			;----------------
			invoke _GetPos,word ptr [ebx]
			;���������or�ұ߽�
			.if edx==edge
				mov flag,1
			.endif

			.break .if flag==1
			add esi,1
			add ebx,2
		.endw
	.endif
	mov esi,0
	;ebx: fallBlock ��ָ��
	lea ebx,fallBlock
	.if flag==0
		.while esi<4
			;----------------
			;�������Ŀ��ͻ��
			;----------------
			imul ecx,esi,2
			add ecx,ebx

			;�����������or�ұ��ǲ����Լ���
			mov flag1,0
			mov edi,0
			.while edi<4
				imul eax,edi,2
				add eax,ebx
							
				mov ax,WORD PTR [eax]
				.if edge == 1
					add ax,1
				.elseif edge == 20
					sub ax,1
				.elseif edge == 0
					sub ax,20
				.elseif edge == -1
					sub ax,40
				.endif
				.if ax==WORD PTR [ecx]
					mov flag1,1
				.endif
				inc edi
							
			.endw

			xor eax,eax
			mov eax,offset mapArray
			add ax,WORD PTR [ecx];ecx�����ǵ�ǰ��fallBlock
			.if edge == 1
				sub eax,2
			.elseif edge == 0
				add eax,19
			.elseif edge == -1
				add eax,39
			.endif
			.if BYTE PTR [eax]!=48;�����쳣�˳�
				.if flag1==0
					mov flag,1
				.endif
			.endif

			.break .if flag==1
			;������++ 
			add esi,1
		.endw
	.endif
	ret
_CheckLLimits endp

;-------------------
;��ʼ�ͼ���
;-------------------
_StartButton proc C hWnd;�����ھ��
	;invoke MessageBox,hWnd,offset sStart,offset sStart,MB_OK
	.if  procState != 1
		.if procState==0
			mov score,0
		.endif
		;����״ֵ̬
		mov procState,1
		mov ax,fallTime
		;������ʱ����ÿXX������
		invoke SetTimer,hWnd,2,ax,NULL
		mov ax,fallTime
		add ax,5
		;������ʱ�������ڸ��»��� 
		invoke SetTimer,hWnd,1,ax,NULL
		


		;�����ǰû��falling�ķ��飬��������
		.if fallState==0
			invoke _CreateBlock
		.endif 
		;�ѽ����Button����������
		invoke SetFocus,hWnd
	.endif
	ret
_StartButton endp
;----------------
;����Ƿ����
;----------------
 _CheckEnd proc C
	mov ebx,offset fallBlock
	mov esi,0
	.while esi<4
		imul eax,esi,2
		add eax,ebx
		.if word ptr [eax] < 61
			mov eax,01h
			ret
		.endif
		add esi,1
	.endw
	xor eax,eax
	ret
 _CheckEnd endp
_EndButton proc C hWnd,endState
	local @stRect:RECT
	.if procState!=0
	;����״ֵ̬
		mov procState,0

		;���ټ�ʱ��
		invoke KillTimer, hWnd,1
		;���ټ�ʱ��
		invoke KillTimer, hWnd,2
		;�ѽ����Button����������
		invoke SetFocus,hWnd
		.if endState==1
			invoke MessageBox,hWnd,offset szText,offset sEnd,MB_YESNO
			.if eax==IDNO
				invoke _StartButton,hWnd
			.elseif eax==IDYES
				mov ax,score
				.if bestscore<ax
					mov bestscore,ax;������óɼ�
				.endif
				mov esi,0
				mov fallState,0
				.while esi<800
					lea eax,mapArray
					add eax,esi
					mov byte ptr [eax],48
					add esi,1
				.endw
				;0,800 100,510
				mov @stRect.left,5
				mov @stRect.right,510
				mov @stRect.top,0
				mov @stRect.bottom,800
				invoke InvalidateRect,hWnd,addr @stRect,TRUE
				invoke UpdateWindow,hWnd
			.endif
		.elseif endState==0
			mov ax,score
			.if bestscore<ax
				mov bestscore,ax;������óɼ�
			.endif
			mov esi,0
			mov fallState,0
			.while esi<800
				lea eax,mapArray
				add eax,esi
				mov byte ptr [eax],48
				add esi,1
			.endw
			invoke MessageBox,hWnd,offset szEndText,offset sEnd,MB_OK
		.endif
		
	.endif
	ret
_EndButton endp
;----------------
;�ƶ�block
;----------------
_MoveBlock proc C
;�޸�mapArray
	lea eax,offset mapArray
	lea ebx,offset fallBlock
	mov esi,1
	.while esi<=4
		xor ecx,ecx
		mov cx,WORD PTR [ebx]
		add ecx,eax
		dec ecx

		;��֮ǰ��λ������Ϊ0
		mov BYTE PTR [ecx],48

		;esi����
		add esi,1
		;ebx���ӣ�fallBlock�������2(dw WORD)
		add ebx,2
	.endw

	lea ebx,offset fallBlock
	mov esi,1
	.while esi<=4
		xor ecx,ecx
		mov cx, WORD PTR [ebx]
		add ecx,eax
		dec ecx

		;���µĲ�������Ϊ1
		xor edx,edx
		mov dl,fallDelta
		.if fallDelta==-1
			mov edx,-1
		.endif
		;�޸�fallBlock
		add WORD PTR [ebx],dx
		add ecx,edx
		mov dl,fallColor
		mov BYTE PTR [ecx],dl

		;esi����
		add esi,1
		;ebx���ӣ�fallBlock�������2(dw WORD)
		add ebx,2
	.endw
	ret
_MoveBlock endp
_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam  
	

	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @oldRect:RECT
	local @newRect:RECT
	local @hDc:HDC
	local @hBrush:HBRUSH
	local @BrushA:HBRUSH
	local @BrushB:HBRUSH
	local @BrushC:HBRUSH
	local @BrushD:HBRUSH
	local @BrushE:HBRUSH
	local @oldBrush:HBRUSH

	
	mov eax,uMsg 

	;----------------------
	;����
	;----------------------
	.if eax==WM_PAINT  ;���ƿͻ���
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax

		;------------------
		;���Ʊ���
		;------------------
		;������ˢ
		push 04F4F4Fh;��ɫ
		call CreateSolidBrush
		mov @hBrush,eax

		push 04F0000h
		call CreateSolidBrush
		mov @BrushA,eax

		push 000004Fh
		call CreateSolidBrush
		mov @BrushB,eax

		push 0004F00h
		call CreateSolidBrush
		mov @BrushC,eax

		push 04F5F00h
		call CreateSolidBrush
		mov @BrushD,eax

		push 06F6F6Fh
		call CreateSolidBrush
		mov @BrushE,eax

		;ѡ���ˢ
		invoke SelectObject,@hDc,@hBrush
		mov @oldBrush, eax
		;-----------------------
		;���Ʊ���
		;-----------------------
		invoke Rectangle,@hDc,100,0,510,800
		invoke SelectObject,@hDc,@BrushE
		invoke Rectangle,@hDc,100,88,510,90
		mov @stRect.left,5
		mov @stRect.right,100

		mov @stRect.top,360
		mov @stRect.bottom,390
		invoke DrawText,@hDc,addr szScore,-1,addr @stRect,DT_LEFT

		invoke _int2str,score,addr sScore
		mov @stRect.top,390
		mov @stRect.bottom,420
		invoke DrawText,@hDc,addr sScore,-1,addr @stRect,DT_LEFT

		mov @stRect.top,420
		mov @stRect.bottom,450
		invoke DrawText,@hDc,addr szBestScore,-1,addr @stRect,DT_LEFT

		invoke _int2str,bestscore,addr sBestScore
		mov @stRect.top,450
		mov @stRect.bottom,480
		invoke DrawText,@hDc,addr sBestScore,-1,addr @stRect,DT_LEFT


		mov @stRect.top,560
		mov @stRect.bottom,590
		invoke DrawText,@hDc,addr szNoteA,-1,addr @stRect,DT_LEFT

		mov @stRect.top,590
		mov @stRect.bottom,620
		invoke DrawText,@hDc,addr szNoteD,-1,addr @stRect,DT_LEFT

		mov @stRect.top,620
		mov @stRect.bottom,650
		invoke DrawText,@hDc,addr szNoteQ,-1,addr @stRect,DT_LEFT

		mov @stRect.top,650
		mov @stRect.bottom,680
		invoke DrawText,@hDc,addr szNoteE,-1,addr @stRect,DT_LEFT
		;----------------------
		;����MapArray
		;----------------------

		;ebx�д���ַ���ָ��
		;esi�������� ��i��
		lea ebx,offset mapArray
		;ѭ������
		mov esi,1
		
		.while esi <= 820
			.if BYTE PTR [ebx]!=48

				;ѡ���ˢ
				.if BYTE PTR [ebx]==49
					invoke SelectObject,@hDc,@BrushA
				.elseif BYTE PTR [ebx]==50
					invoke SelectObject,@hDc,@BrushB
				.elseif BYTE PTR [ebx]==51
					invoke SelectObject,@hDc,@BrushC
				.elseif BYTE PTR [ebx]==52
					invoke SelectObject,@hDc,@BrushD
				.elseif BYTE PTR [ebx]==53
					invoke SelectObject,@hDc,@BrushE
				.endif

				invoke _GetPos,esi
				invoke _GetWinPos,eax,edx
				
				push eax ;bottom
				push edx ;right
				sub eax,15 
				sub edx,15 
				push eax ;top
				push edx ;left
				
				push @hDc
				call Rectangle
				;ѡ��ԭ�ȵľɱ�ˢ
				invoke SelectObject,@hDc,@oldBrush
			.endif
			add ebx,1
			add esi,1
		.endw
		
		;ѡ��ԭ�ȵľɱ�ˢ
		invoke SelectObject,@hDc,@oldBrush

		;ɾ������Ҫ�ı�ˢ
		invoke DeleteObject,@hBrush
		invoke DeleteObject,@BrushA
		invoke DeleteObject,@BrushB
		invoke DeleteObject,@BrushC
		invoke DeleteObject,@BrushD
		invoke DeleteObject,@BrushE
		invoke EndPaint,hWnd,addr @stPs



	;----------------------
	;���ڵ����٣��ر�
	;----------------------
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWnd
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,0
	;----------------------
	;��������ʱ����������
	;----------------------
	.elseif eax==WM_CREATE  ;��������ʱ
		;������ʼButton
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showStart,\
				WS_CHILD or WS_VISIBLE,\
				10,10,80,30,\  
				hWnd,1,hInstance,NULL  ;��ťID��1
		
		;������ͣButton
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showPause,\
				WS_CHILD or WS_VISIBLE,\
				10,60,80,30,\  
				hWnd,2,hInstance,NULL  ;��ťID��2
		;�����ؿ�Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showEnd,\
				WS_CHILD or WS_VISIBLE,\
				10,110,80,30,\  
				hWnd,3,hInstance,NULL  ;��ťID��3
		;����Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showQuick,\
				WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,\
				10,190,80,30,\  
				hWnd,4,hInstance,NULL  ;��ťID��4
		;����Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showMid,\
				WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,\
				10,240,80,30,\  
				hWnd,5,hInstance,NULL  ;��ťID��5
		;����Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showSlow,\
				WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,\
				10,290,80,30,\  
				hWnd,6,hInstance,NULL  ;��ťID��6
	;----------------------
	;��������
	;----------------------

	.elseif eax==WM_COMMAND  ;���ʱ���������Ϣ��WM_COMMAND
		mov eax,wParam  
		
		;----------------------
		;��ʼ����(Ҳ�䵱����)
		;----------------------
		.if eax==1 
			invoke _StartButton,hWnd
			;ˢ��һ�»���
			mov @stRect.right,505
			mov @stRect.bottom,790
			mov @stRect.left,5
			mov @stRect.top,0
			invoke InvalidateRect,hWnd,addr @stRect,TRUE
			invoke UpdateWindow,hWnd
		;----------------------
		;��ͣ����
		;----------------------
		.elseif eax==2  
			;invoke MessageBox,hWnd,offset sPause,offset sPause,MB_OK
			.if procState==1
				;����״ֵ̬
				mov procState,2

				;���ټ�ʱ��
				invoke KillTimer,hWnd,1
				;���ټ�ʱ��
				invoke KillTimer, hWnd,2
				;�ѽ����Button����������
				invoke SetFocus,hWnd
			.endif

		;----------------------
		;��������
		;----------------------
		.elseif eax==3 
			invoke _EndButton,hWnd,1
		;�ٶȿ���
		.elseif eax==4
			mov ax,fallHigher
			mov fallTime,ax
				;�ѽ����Button����������
				invoke SetFocus,hWnd
		.elseif eax==5
			mov ax,fallHigh
			mov fallTime,ax
				;�ѽ����Button����������
				invoke SetFocus,hWnd
		.elseif eax==6
			mov ax,fallLow
			mov fallTime,ax
				;�ѽ����Button����������
				invoke SetFocus,hWnd
		.endif
	;----------------------
	;����ʱ����
	;----------------------

	.elseif eax==WM_TIMER
		mov eax, wParam
		.if eax==1
			;-----------------------------------------------------------
			;������Ҫ����mapArray,����ʹ������Ҫ�޸ĵĲ�����Ч(���»���)
			;-----------------------------------------------------------
			invoke _GetWinRect
			xor eax,eax
			mov ax,rtRight
			mov @oldRect.right,eax
			mov ax,rtBottom
			mov @oldRect.bottom,eax
			mov ax, rtLeft
			mov @oldRect.left,eax
			mov ax,rtTop
			mov @oldRect.top,eax
			;����תһ��
			.if fallTurn==1
				invoke _TurnTetris
				mov fallTurn ,0
			.endif
			;����һ��Ҫ���е��ƶ�����һ��

			;----------------------
			;���ƣ��ж��Ƿ�����ƶ�
			;----------------------
			.if fallDelta==20
				invoke _CheckLLimits,0
				;�Ѿ���������������ס
				.if flag==1
					mov fallDelta,0
					mov fallState,0
					invoke _CheckEnd
					.if eax==1
						invoke _EndButton,hWnd,0
					.endif
				.elseif flag==0
					invoke _MoveBlock
					mov fallDelta,0
					;�����ƶ����߱任֮��blockռ�ݵ�������
					invoke _GetWinRect
					xor eax,eax
					mov ax,rtRight
					mov @newRect.right,eax
					mov ax,rtBottom
					mov @newRect.bottom,eax
					mov ax, rtLeft
					mov @newRect.left,eax
					mov ax,rtTop
					mov @newRect.top,eax
					; ʹ����������Ч
					invoke UnionRect,addr @stRect,addr @oldRect,addr @newRect
					invoke InvalidateRect,hWnd,addr @stRect,TRUE
					invoke UpdateWindow,hWnd
				.endif
			.elseif fallDelta==40
				invoke _CheckLLimits,-1
				.if flag==1
					invoke _CheckLLimits,0
					.if flag==1
						mov fallDelta,0
						mov fallState,0
						invoke _CheckEnd
						.if eax==1
							invoke _EndButton,hWnd,0
						.endif
					.else
						mov fallDelta,20
						invoke _MoveBlock
						mov fallDelta,0
						;�����ƶ����߱任֮��blockռ�ݵ�������
						invoke _GetWinRect
						xor eax,eax
						mov ax,rtRight
						mov @newRect.right,eax
						mov ax,rtBottom
						mov @newRect.bottom,eax
						mov ax, rtLeft
						mov @newRect.left,eax
						mov ax,rtTop
						mov @newRect.top,eax
						; ʹ����������Ч
						invoke UnionRect,addr @stRect,addr @oldRect,addr @newRect
						invoke InvalidateRect,hWnd,addr @stRect,TRUE
						invoke UpdateWindow,hWnd
					.endif
					
				.endif
			.endif
			xor ebx,ebx
			;----------------------
			;���ƣ��ж��Ƿ�����ƶ�
			;----------------------
			.if fallLDelta==1
				invoke _CheckLLimits,1
				;���û��Խ��Ļ��������
				.if flag==0
					lea eax, fallDelta
					add BYTE PTR [eax], -1
				.endif
			.endif
			;--------------------------------�����жϽ���
			.if fallRDelta==1
				invoke _CheckLLimits,20
				;���û��Խ��Ļ��������
				.if flag==0
					lea eax, fallDelta
					add BYTE PTR [eax], 1
				.endif
			.endif
			;-------------------------------------�����жϽ���
			;�����ǰ�����������block
			.if fallState==1
				.if fallDelta!=0
					invoke _MoveBlock
					;�����ƶ����߱任֮��blockռ�ݵ�������
					invoke _GetWinRect
					xor eax,eax
					mov ax,rtRight
					mov @newRect.right,eax
					mov ax,rtBottom
					mov @newRect.bottom,eax
					mov ax, rtLeft
					mov @newRect.left,eax
					mov ax,rtTop
					mov @newRect.top,eax
					; ʹ����������Ч
					invoke UnionRect,addr @stRect,addr @oldRect,addr @newRect
					invoke InvalidateRect,hWnd,addr @stRect,TRUE
					invoke UpdateWindow,hWnd

					;���������ź����ó�0
					mov fallDelta,0
					mov fallLDelta,0
					mov fallRDelta,0

				.endif
			.elseif fallState==0
				;�������
				.while 1 
					invoke _CheckRow
					.if eax==1
						;����п����������У����»���
						;100,0,510,800
						mov @stRect.right,505
						mov @stRect.bottom,790
						mov @stRect.left,5
						mov @stRect.top,0
						invoke InvalidateRect,hWnd,addr @stRect,TRUE
						invoke UpdateWindow,hWnd
					.endif
					.break .if eax==0
				.endw
				;�����µ�block
				invoke _CreateBlock
			.endif
		; �������
		.elseif eax==2
			.if accTric == 0
				mov fallDelta, 20
			.else
				mov fallDelta,40
				mov accTric ,0
			.endif
		.endif

	.elseif eax==WM_CHAR
		;----------------------------
		;��ת���ٿ���
		;----------------------------
		.if wParam==101 ;����E
			;��������ת
			.if procState==1
			.if fallTurn==0
				mov fallTurn,1
			.endif
			.endif
		.elseif wParam==113 ;����Q
			.if procState==1
				mov accTric,1
			.endif
			;���������
		;----------------------------
		;�����ƶ�����
		;----------------------------
		.elseif wParam==97 ;����A
			.if procState==1
				lea eax, fallLDelta
				mov BYTE PTR [eax], 1
			.endif
		.elseif wParam==100;����D
			.if procState==1		
				lea eax, fallRDelta
				mov BYTE PTR [eax], 1	
			.endif
		.endif
	.else  ;����Ĭ�ϴ�����������Ϣ
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif
winMainEnd:
	xor eax,eax
	ret
_ProcWinMain endp

_WinMain proc  ;���ڳ���
	local @stWndClass:WNDCLASSEX  ;�����˴��ڵ�һЩ��Ҫ���ԣ�ͼ�꣬��꣬����ɫ��
	local @stMsg:MSG	

	invoke GetModuleHandle,NULL  ;�õ����̵ľ�����Ѹþ����ֵ����hInstance��
	mov hInstance,eax
	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass  ;��stWndClass��ʼ��ȫ0

	invoke LoadCursor,0,IDC_ARROW
	;��ʼ��stWndClass�еĲ���
	mov @stWndClass.hCursor,eax				
	push hInstance							
	pop @stWndClass.hInstance					
	mov @stWndClass.cbSize,sizeof WNDCLASSEX			
	mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW			
	mov @stWndClass.lpfnWndProc,offset _ProcWinMain			
	;�������������ʵ����ָ���˸ô��ڳ���Ĵ��ڹ�����_ProcWinMain	
	mov @stWndClass.hbrBackground,COLOR_WINDOW+1			
	mov @stWndClass.lpszClassName,offset szClassName	
	

	invoke RegisterClassEx,addr @stWndClass  ;ע�ᴰ����

	;��������
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,\  
			offset szClassName,offset szCaptionMain,\ 
			WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,\
			100,100,560,870,\	
			NULL,NULL,hInstance,NULL
			
	mov hWinMain,eax 
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL  ;��ʾ����
	invoke UpdateWindow,hWinMain  ;ˢ�´��ڿͻ���


	.while TRUE  
		invoke GetMessage,addr @stMsg,NULL,0,0  ;����Ϣ������ȡ����һ����Ϣ������stMsg�ṹ��
		.break .if eax==0  

		invoke TranslateMessage,addr @stMsg  ;�ѻ��ڼ���ɨ����İ�����Ϣת���ɶ�Ӧ��ASCII��
		invoke DispatchMessage,addr @stMsg  ;�ҵ��ô��ڳ���Ĵ��ڹ���WinProc��ͨ���ô��ڹ�����������Ϣ
	.endw
	ret
_WinMain endp

main proc
	call _WinMain  ;������͵����˴��ڳ���ͽ���������������
	invoke ExitProcess,NULL
	ret
main endp
end main