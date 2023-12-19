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
	;窗口和控件相关的量
	hInstance dd ?  ;存放应用程序的句柄
	hWinMain dd ?   ;存放窗口的句柄
	showButton byte 'button',0
	button db 'button',0
	sStart db 'start',0
	showStart byte 'start',0
	showPause byte 'pause',0
	showEnd byte 'end',0
	sPause db 'Pause',0
	sEnd db 'End',0
;若干方块
;0,1,2,3,4,5,6
block db 2,1,3,4 ;I
 db 22,2,42,41   ;J
 db 21,1,41,42   ;L
 db 2,1,21,22    ;O
 db 2,3,22,21    ;S
 db 2,1,3,22     ;T
 db 2,1,22,23    ;Z
;用来选择方块的随机数
rand dw 2
	;41*20 的指示矩阵，第41行不供玩家使用
	;id是从1开始的

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
db "00111111111111111111"
db "55555555555555555555"
	
	;正在下降的方块
	;向下移动 pos+20
	;向右移动 pos+1
		;如果pos%20==0，那限制向右移动
	;向左移动 pos-1
		;如果pos%20==1,那限制向左移动
	;如果 pos'的位置上有非0的，
		;如果此时是左右移动，限制移动
		;如果此时是向下移动，终止，生成新的方块

	;四个部分的坐标	
	fallBlock dw 1
			  dw 2
			  dw 3
			  dw 4
	;四个部分的临时坐标	
	fallBlockTemp dw 1
			  dw 2
			  dw 3
			  dw 4
	;记录方块的颜色49,50,51,52
	fallColor db 49
	;记录方块向三个方向移动
	fallDelta db 0
	fallLDelta db 0
	fallRDelta db 0
	accTric db 0
	fallTurn db 0
	;当前是0：清空的状态,1:正在掉落方块,2：暂停的状态
	procState db 0

	;当前是0:没有正在掉落的方块，需要创建
	;当前是1:有正在掉落的方块
	fallState db 0

	;用户相关的
	score dq 0h
	;bestscore dq 0h

	;一个flag
	flag db 0
	;另一个flag
	flag1 db 0

	;翻转用到的临时变量
	tempx dw ?
	tempy dw ?
.const
szClassName db 'MyClass',0
szCaptionMain db 'MyTetris',0
szText db 'Win32 Assembly,Simple and powerful!',0

.code
;-----------------
;修改mapArray
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
;从一个小块的id获取x,y坐标
;-----------------
_GetPos proc C idc
	xor eax,eax
	mov eax,idc
	xor edx,edx
	mov ecx,20
	div ecx
	;edx中存放余数，eax中存放商
	.if edx==0
		mov edx,20
		sub eax,1
	.endif
	ret
_GetPos endp
;-----------------
;从一个小块的id获取在窗口中的x,y坐标（block右下角）
;-----------------
_GetWinPos proc C a,d
	mov eax,a
	mov edx,d
	;根据行和列值计算屏幕坐标
	imul eax, eax, 18;
	imul edx, edx, 18; 
	;起始坐标
	add edx,125;屏幕x坐标
	add eax, 50 ;屏幕y坐标
	ret
_GetWinPos endp
;-----------------
;翻转
;-----------------
_TurnTetris proc C
	lea ebx, fallBlock
	invoke _GetPos,fallBlock
	mov tempx,ax
	mov tempy,dx
	mov esi,1
	add ebx,2
	.while esi<4
		;先把mapArray中旧的清零
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
		;ax中是新的id
		mov WORD PTR [ebx],ax
		;把mapArray中新的置为Color
		invoke _SetMap,word ptr [ebx],fallColor
		;这里还没有进行碰撞检测
		add ebx,2
		inc esi
	.endw
	ret 
_TurnTetris endp
;-----------------
;消除检查
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
				;可以消除这一行
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
;创建新的方块
;-----------------
_CreateBlock proc C 
		;方块的位置
	;（伪）随机选择一种方块的类型，取模的结果在edx中
	xor eax,eax
	mov ax,rand
	xor edx,edx
	mov ecx,7
	div ecx
	add rand,5
	.if rand > 2000
		mov rand , 3
	.endif

	;eax中存放的是fallBLock的地址
	xor eax,eax
	lea eax,offset fallBlock

	;ebx中存放的是block的地址
	xor ebx,ebx
	lea ebx,offset block
	;加上增量
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
	;当前有正在下落的方块
	mov fallState,1
	;方块的颜色
	xor edx,edx
	lea edx,fallColor
	add BYTE PTR [edx],1
	;49，50，51，52
	.if BYTE PTR [edx] > 52
		mov BYTE PTR [edx],49
	.endif
	ret
_CreateBlock endp
;-----------------------
;碰撞检查，flag：1 下一步的移动会导致碰撞 ； edge:0 fall;1 left;20 right;-1 acc
;-----------------------
_CheckLLimits proc C edge
	mov flag,0
	.if edge>0
		xor esi,esi
		xor eax,eax
		mov esi,1
		;ebx: fallBlock 的指针
		lea ebx,fallBlock
		.while esi<=4
			;----------------
			;碰到边界了吗
			;----------------
			invoke _GetPos,word ptr [ebx]
			;如果碰到左or右边界
			.if edx==edge
				mov flag,1
			.endif

			.break .if flag==1
			add esi,1
			add ebx,2
		.endw
	.endif
	mov esi,0
	;ebx: fallBlock 的指针
	lea ebx,fallBlock
	.if flag==0
		.while esi<4
			;----------------
			;和其他的块冲突吗
			;----------------
			imul ecx,esi,2
			add ecx,ebx

			;看看这个的左or右边是不是自己人
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
			add ax,WORD PTR [ecx];ecx里面是当前的fallBlock
			.if edge == 1
				sub eax,2
			.elseif edge == 0
				add eax,19
			.elseif edge == -1
				add eax,39
			.endif
			.if BYTE PTR [eax]!=48;这里异常退出
				.if flag1==0
					mov flag,1
				.endif
			.endif

			.break .if flag==1
			;计数器++ 
			add esi,1
		.endw
	.endif
	ret
_CheckLLimits endp
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
	;绘制
	;----------------------
	.if eax==WM_PAINT  ;绘制客户区
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax

		;------------------
		;绘制背景
		;------------------
		;创建笔刷
		push 04F4F4Fh;颜色
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

		;选择笔刷
		invoke SelectObject,@hDc,@hBrush
		mov @oldBrush, eax
		;-----------------------
		;绘制背景
		;-----------------------
		invoke Rectangle,@hDc,100,0,510,800

		;----------------------
		;绘制MapArray
		;----------------------

		;ebx中存放字符串指针
		;esi用来计数 “i”
		lea ebx,offset mapArray
		;循环绘制
		mov esi,1
		
		.while esi <= 820
			.if BYTE PTR [ebx]!=48

				;选择笔刷
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
				;选择原先的旧笔刷
				invoke SelectObject,@hDc,@oldBrush
			.endif
			add ebx,1
			add esi,1
		.endw
		
		;选择原先的旧笔刷
		invoke SelectObject,@hDc,@oldBrush

		;删除不需要的笔刷
		invoke DeleteObject,@hBrush
		invoke DeleteObject,@BrushA
		invoke DeleteObject,@BrushB
		invoke DeleteObject,@BrushC
		invoke DeleteObject,@BrushD
		invoke DeleteObject,@BrushE
		invoke EndPaint,hWnd,addr @stPs



	;----------------------
	;窗口的销毁，关闭
	;----------------------
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWnd
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,0
	;----------------------
	;创建窗口时，创建按键
	;----------------------
	.elseif eax==WM_CREATE  ;创建窗口时
		;创建开始Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showStart,\
				WS_CHILD or WS_VISIBLE,\
				10,10,80,30,\  
				hWnd,1,hInstance,NULL  ;按钮ID：1
		
		;创建暂停Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showPause,\
				WS_CHILD or WS_VISIBLE,\
				10,80,80,30,\  
				hWnd,2,hInstance,NULL  ;按钮ID：2
		;创建重开Button
		invoke CreateWindowEx,NULL,\
				offset button,\
				offset showEnd,\
				WS_CHILD or WS_VISIBLE,\
				10,150,80,30,\  
				hWnd,3,hInstance,NULL  ;按钮ID：3
	;----------------------
	;处理命令
	;----------------------

	.elseif eax==WM_COMMAND  ;点击时候产生的消息是WM_COMMAND
		mov eax,wParam  
		
		;----------------------
		;开始按键(也充当继续)
		;----------------------
		.if eax==1 
			;invoke MessageBox,hWnd,offset sStart,offset sStart,MB_OK
			xor eax,eax
			mov al,procState
			.if  eax != 1
				;设置状态值
				lea eax,offset procState
				mov BYTE PTR [eax],1

				;创建计时器，用于更新画面 200 毫秒画面还比较稳定，我懒得算局部更新的Rect了
				invoke SetTimer,hWnd,1,200,NULL
				;创建计时器，每0.5秒下落
				invoke SetTimer,hWnd,2,500,NULL

				;如果当前没有falling的方块，创建方块
				.if fallState==0
					invoke _CreateBlock
				.endif 
				;把焦点从Button交还主窗口
				invoke SetFocus,hWnd
			.endif

		;----------------------
		;暂停按键
		;----------------------
		.elseif eax==2  
			;invoke MessageBox,hWnd,offset sPause,offset sPause,MB_OK
			xor eax,eax
			mov al,procState
			.if eax==1
				;设置状态值
				lea eax,offset procState
				mov BYTE PTR [eax],2

				;销毁计时器
				invoke KillTimer,hWnd,1
				;销毁计时器
				invoke KillTimer, hWnd,2
				;把焦点从Button交还主窗口
				invoke SetFocus,hWnd
			.endif

		;----------------------
		;结束按键
		;----------------------
		.elseif eax==3 
			;invoke MessageBox,hWnd,offset sEnd,offset sEnd,MB_OK
			xor eax,eax
			mov al,procState
			.if eax!=0
				;设置状态值
				lea eax,offset procState
				mov BYTE PTR [eax],0

				;销毁计时器
				invoke KillTimer, hWnd,1
				;销毁计时器
				invoke KillTimer, hWnd,2
				;把焦点从Button交还主窗口
				invoke SetFocus,hWnd
			.endif
		.endif
	;----------------------
	;处理定时任务
	;----------------------

	.elseif eax==WM_TIMER
		mov eax, wParam
		.if eax==1
			;-----------------------------------------------------------
			;在这里要更新mapArray,并且使窗口中要修改的部分无效(更新画面)
			;-----------------------------------------------------------
			;先旋转一下
			.if fallTurn==1
				invoke _TurnTetris
				mov fallTurn ,0
			.endif
			;把这一步要进行的移动结算一下

			;----------------------
			;下移，判断是否可以移动
			;----------------------
			.if fallDelta==20
				invoke _CheckLLimits,0
				;已经触底了在这里拦住
				.if flag==1
					mov fallDelta,0
					mov fallState,0
				.endif
			.elseif fallDelta==40
				invoke _CheckLLimits,-1
				.if flag==1
					invoke _CheckLLimits,0
					.if flag==1
						mov fallDelta,0
						mov fallState,0
					.else
						mov fallDelta,20
					.endif
					
				.endif
			.endif
			xor ebx,ebx
			;----------------------
			;左移，判断是否可以移动
			;----------------------
			.if fallLDelta==1
				invoke _CheckLLimits,1
				;如果没有越界的话允许操作
				.if flag==0
					lea eax, fallDelta
					add BYTE PTR [eax], -1
				.endif
			.endif
			;--------------------------------左移判断结束
			.if fallRDelta==1
				invoke _CheckLLimits,20
				;如果没有越界的话允许操作
				.if flag==0
					lea eax, fallDelta
					add BYTE PTR [eax], 1
				.endif
			.endif
			;-------------------------------------右移判断结束
			;如果当前右正在下落的block
			.if fallState==1
				.if fallDelta!=0
					;修改mapArray
					lea eax,offset mapArray
					lea ebx,offset fallBlock
					mov esi,1
					.while esi<=4
						xor ecx,ecx
						mov cx,WORD PTR [ebx]
						add ecx,eax
						dec ecx

						;将之前的位置设置为0
						mov BYTE PTR [ecx],48

						;esi增加
						add esi,1
						;ebx增加，fallBlock数组后移2(dw WORD)
						add ebx,2
					.endw

					lea ebx,offset fallBlock
					mov esi,1
					.while esi<=4
						xor ecx,ecx
						mov cx, WORD PTR [ebx]
						add ecx,eax
						dec ecx

						;将新的部分设置为1
						xor edx,edx
						mov dl,fallDelta
						.if fallDelta==-1
							mov edx,-1
						.endif
						add WORD PTR [ebx],dx
						add ecx,edx
						mov dl,fallColor
						mov BYTE PTR [ecx],dl

						;esi增加
						add esi,1
						;ebx增加，fallBlock数组后移2(dw WORD)
						add ebx,2
					.endw
					invoke _GetPos,fallBlock
					invoke _GetWinPos,eax,edx
					add eax,72
					add edx,72
					; 使部分区域无效
					mov @stRect.right,edx
					mov @stRect.bottom,eax
					sub eax,144
					sub edx,144
					mov @stRect.left,edx
					mov @stRect.top,eax


					;三个操纵信号设置成0
					lea eax,fallDelta
					mov BYTE PTR [eax],0

					lea eax,fallLDelta
					mov BYTE PTR [eax],0

					lea eax,fallRDelta
					mov BYTE PTR [eax],0

					invoke InvalidateRect,hWnd,addr @stRect,TRUE
					invoke UpdateWindow,hWnd
				.endif
			.elseif fallState==0
				;消除检查
				.while 1 
					invoke _CheckRow
					.if eax==1
						;如果有可以消除的行，更新画面
						;100,0,510,800
						mov @stRect.right,505
						mov @stRect.bottom,790
						mov @stRect.left,105
						mov @stRect.top,0
						invoke InvalidateRect,hWnd,addr @stRect,TRUE
						invoke UpdateWindow,hWnd
					.endif
					.break .if eax==0
				.endw
				;创建新的block
				invoke _CreateBlock
			.endif
		; 下落控制
		.elseif eax==2
			.if accTric == 0
				mov fallDelta, 20
			.else
				mov fallDelta,40
				mov accTric ,0
			.endif
		.endif
	;----------------------------
	;左右移动控制
	;----------------------------
	.elseif eax==WM_LBUTTONDOWN
		;左键按下
			.if procState==1
				lea eax, fallLDelta
				mov BYTE PTR [eax], 1
			.endif
	.elseif eax==WM_RBUTTONDOWN
		;右键按下
			.if procState==1		
				lea eax, fallRDelta
				mov BYTE PTR [eax], 1	
			.endif
	.elseif eax==WM_KEYDOWN
		.if wParam==041h ;按键A
			;在这里旋转
			.if procState==1
			.if fallTurn==0
				mov fallTurn,1
			.endif
			.endif
		.elseif wParam==042h ;按键B
			.if procState==1
				mov accTric,1
			.endif
			;在这里加速
		.endif
	.else  ;否则按默认处理方法处理消息
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif
winMainEnd:
	xor eax,eax
	ret
_ProcWinMain endp

_WinMain proc  ;窗口程序
	local @stWndClass:WNDCLASSEX  ;定义了窗口的一些主要属性，图标，光标，背景色等
	local @stMsg:MSG	

	invoke GetModuleHandle,NULL  ;得到进程的句柄，把该句柄的值放在hInstance中
	mov hInstance,eax
	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass  ;将stWndClass初始化全0

	invoke LoadCursor,0,IDC_ARROW
	;初始化stWndClass中的参数
	mov @stWndClass.hCursor,eax				
	push hInstance							
	pop @stWndClass.hInstance					
	mov @stWndClass.cbSize,sizeof WNDCLASSEX			
	mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW			
	mov @stWndClass.lpfnWndProc,offset _ProcWinMain			
	;上面这条语句其实就是指定了该窗口程序的窗口过程是_ProcWinMain	
	mov @stWndClass.hbrBackground,COLOR_WINDOW+1			
	mov @stWndClass.lpszClassName,offset szClassName	
	

	invoke RegisterClassEx,addr @stWndClass  ;注册窗口类

	;创建窗口
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,\  
			offset szClassName,offset szCaptionMain,\ 
			WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,\
			100,100,560,870,\	
			NULL,NULL,hInstance,NULL
			
	mov hWinMain,eax 
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL  ;显示窗口
	invoke UpdateWindow,hWinMain  ;刷新窗口客户区


	.while TRUE  
		invoke GetMessage,addr @stMsg,NULL,0,0  ;从消息队列中取出第一个消息，放在stMsg结构中
		.break .if eax==0  

		invoke TranslateMessage,addr @stMsg  ;把基于键盘扫描码的按键信息转换成对应的ASCII码
		invoke DispatchMessage,addr @stMsg  ;找到该窗口程序的窗口过程WinProc，通过该窗口过程来处理消息
	.endw
	ret
_WinMain endp

main proc
	call _WinMain  ;主程序就调用了窗口程序和结束程序两个函数
	invoke ExitProcess,NULL
	ret
main endp
end main