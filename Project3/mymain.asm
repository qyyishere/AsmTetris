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
	sStart db 'start',0
	showStart byte 'start',0
	showPause byte 'pause',0
	showEnd byte 'end',0
	sPause db 'Pause',0
	sEnd db 'End',0
;���ɷ���
;0,1,2,3,4,5,6
block db 1,2,3,4 ;I
 db 2,22,42,41   ;J
 db 1,21,41,42   ;L
 db 1,2,21,22    ;O
 db 2,3,22,21    ;S
 db 1,2,3,22     ;T
 db 1,2,22,23    ;Z
;����ѡ�񷽿�������
rand dw 2
	;41*20 ��ָʾ���󣬵�41�в������ʹ��
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

	;�ĸ����ֵ�����	;������һ��ͼ���е����ϡ����¡���������
	fallBlock dw 1
			  dw 2
			  dw 3
			  dw 4
	;��¼�������ɫ49,50,51,52
	fallColor db 49
	;��¼���������������ƶ�
	fallDelta db 0
	fallLDelta db 0
	fallRDelta db 0

	fallLDeltaTri db 0
	fallRDeltaTri db 0
	;��ǰ��0����յ�״̬,1:���ڵ��䷽��,2����ͣ��״̬
	procState db 0

	;��ǰ��0:û�����ڵ���ķ��飬��Ҫ����
	;��ǰ��1:�����ڵ���ķ���
	fallState db 0

	;�û���ص�
	score dq 0h
	;bestscore dq 0h

	;һ��flag
	flag db 0
	;��һ��flag
	flag1 db 0
.const
szClassName db 'MyClass',0
szCaptionMain db 'MyTetris',0
szText db 'Win32 Assembly,Simple and powerful!',0

.code

_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam  
	

	local @stPs:PAINTSTRUCT
	local @stRect:RECT
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

				;���Ʒ���,���㷽��λ��
				mov eax,esi
				xor edx,edx
				mov ecx,20
				div ecx
				;edx�д��������eax�д����
				.if edx==0
					mov edx,20
					sub eax,1
				.endif
				;�����к���ֵ������Ļ����
				imul eax, eax, 18;
				imul edx, edx, 18; 
				;��ʼ����
				add edx,125;x����
				add eax, 50 ;y����

				
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
				10,10,100,30,\  
				hWnd,1,hInstance,NULL  ;��ťID��1
		;������ͣButton
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showPause,\
				WS_CHILD or WS_VISIBLE,\
				10,80,100,30,\  
				hWnd,2,hInstance,NULL  ;��ťID��2
		;�����ؿ�Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showEnd,\
				WS_CHILD or WS_VISIBLE,\
				10,150,100,30,\  
				hWnd,3,hInstance,NULL  ;��ťID��3
	;----------------------
	;��������
	;----------------------

	.elseif eax==WM_COMMAND  ;���ʱ���������Ϣ��WM_COMMAND
		mov eax,wParam  
		
		;----------------------
		;��ʼ����(Ҳ�䵱����)
		;----------------------
		.if eax==1 
			;invoke MessageBox,hWnd,offset sStart,offset sStart,MB_OK
			xor eax,eax
			mov al,procState
			.if  eax != 1
				;����״ֵ̬
				lea eax,offset procState
				mov BYTE PTR [eax],1

				;������ʱ�������ڸ��»��� 200 ���뻭�滹�Ƚ��ȶ�����������ֲ����µ�Rect��
				invoke SetTimer,hWnd,1,200,NULL
				;������ʱ����ÿ0.5������
				invoke SetTimer,hWnd,2,500,NULL

				;�����ǰû��falling�ķ��飬��������
				.if fallState==0
					;�����λ��

					;��α�����ѡ��һ�ַ�������ͣ�ȡģ�Ľ����edx��
					xor eax,eax
					mov ax,rand
					xor edx,edx
					mov ecx,7
					div ecx
					add rand,5
					.if rand > 2000
						mov rand , 3
					.endif

					;eax�д�ŵ���fallBLock�ĵ�ַ
					xor eax,eax
					lea eax,offset fallBlock

					;ebx�д�ŵ���block�ĵ�ַ
					xor ebx,ebx
					lea ebx,offset block
					;��������
					imul edx,edx,4
					add ebx,edx
					mov esi,1
					xor ecx,ecx
					.while esi<=4
						mov cl,BYTE PTR [ebx]
						mov WORD PTR [eax],cx
						add eax,2
						add ebx,1
						add esi,1
					.endw
					;
					mov fallState,1
					;�������ɫ
					xor edx,edx
					lea edx,fallColor
					add BYTE PTR [edx],1
					;49��50��51��52
					.if BYTE PTR [edx] > 52
						mov BYTE PTR [edx],49
					.endif
				.endif 
			.endif

		;----------------------
		;��ͣ����
		;----------------------
		.elseif eax==2  
			;invoke MessageBox,hWnd,offset sPause,offset sPause,MB_OK
			xor eax,eax
			mov al,procState
			.if eax==1
				;����״ֵ̬
				lea eax,offset procState
				mov BYTE PTR [eax],2

				;���ټ�ʱ��
				invoke KillTimer,hWnd,1
				;���ټ�ʱ��
				invoke KillTimer, hWnd,2
			.endif

		;----------------------
		;��������
		;----------------------
		.elseif eax==3 
			;invoke MessageBox,hWnd,offset sEnd,offset sEnd,MB_OK
			xor eax,eax
			mov al,procState
			.if eax!=0
				;����״ֵ̬
				lea eax,offset procState
				mov BYTE PTR [eax],0

				;���ټ�ʱ��
				invoke KillTimer, hWnd,1
				;���ټ�ʱ��
				invoke KillTimer, hWnd,2
			.endif
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
			;����һ��Ҫ���е��ƶ�����һ��

			lea eax, fallDelta
			xor ebx,ebx
			.if fallLDelta==1
				;���ƣ��ж��Ƿ�����ƶ�
				xor esi,esi
				xor eax,eax

				mov esi,1
				;ebx: fallBlock ��ָ��
				lea ebx,fallBlock
				mov flag,0
				.while esi<=4
					;----------------
					;�����߽�����
					;----------------
					;���㷽��λ��
					xor eax,eax
					mov ax,WORD PTR [ebx]
					xor edx,edx
					mov ecx,20
					div ecx
					;edx�д��������eax�д����
					.if edx==0
						mov edx,20
						sub eax,1
					.endif

					;���������߽�
					.if edx==1
						mov flag,1
					.endif

					.break .if flag==1
					add esi,1
					add ebx,2
				.endw

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

						;�������������ǲ����Լ���
						mov flag1,0
						mov edi,0
						.while edi<4
							imul eax,edi,2
							add eax,ebx
							
							mov ax,WORD PTR [eax]
							add ax,1
							.if ax==WORD PTR [ecx]
								mov flag1,1
							.endif
							inc edi
							
						.endw

						xor eax,eax
						mov eax,offset mapArray
						add ax,WORD PTR [ecx];ecx�����ǵ�ǰ��fallBlock
						sub eax,2
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
				;���û��Խ��Ļ��������
				.if flag==0
					lea eax, fallDelta
					add BYTE PTR [eax], -1
				.endif
			.endif
			.if fallRDelta==1
				;���ƣ��ж��Ƿ�����ƶ�
				add BYTE PTR [eax], 1
			.endif
			.if fallDelta!=0
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
					add WORD PTR [ebx],dx
					add ecx,edx
					mov dl,fallColor
					mov BYTE PTR [ecx],dl

	
					

					;esi����
					add esi,1
					;ebx���ӣ�fallBlock�������2(dw WORD)
					add ebx,2
				.endw

				; ʹ����������Ч
				mov @stRect.left,110
				mov @stRect.top,0
				mov @stRect.right,500
				mov @stRect.bottom,800

				;���������ź����ó�0
				lea eax,fallDelta
				mov BYTE PTR [eax],0

				lea eax,fallLDelta
				mov BYTE PTR [eax],0

				lea eax,fallRDelta
				mov BYTE PTR [eax],0

				invoke InvalidateRect,hWnd,addr @stRect,TRUE
				invoke UpdateWindow,hWnd
			.endif
		; �������
		.elseif eax==2
			lea eax,fallDelta
			mov BYTE PTR [eax], 20

		.endif
	;----------------------------
	;�����ƶ�����
	;----------------------------
	.elseif eax==WM_LBUTTONDOWN
		;�������
			.if procState==1
				lea eax, fallLDelta
				mov BYTE PTR [eax], 1
			.endif
	.elseif eax==WM_RBUTTONDOWN
		;�Ҽ�����
			.if procState==1		
				lea eax, fallRDelta
				mov BYTE PTR [eax], 1	
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
			100,100,1000,1000,\	
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