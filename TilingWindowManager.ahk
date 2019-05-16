#Persistent
#SingleInstance force

;; tiling window manager for windows 7-10 designed for 1 or 2 monitors arranging
;; windows in the following pattern with configurable window sizes and borders:
;;  _________     _________
;; |   |     |   |     |___| <- primary monitor
;; |   |     |   |     |   |
;; '---i-----'   '-----i---'

;; todo override windows move keys, eg, win + left

;; -- window sizing options

;; size of space between windows
windowBorder = 10
;; width of the large windows that appear closest to the center of the screen
windowLeftWidth = 1200
;; height of the small top right window
windowRightSmallTopHeight = 550

;; monitor geometry
;; todo: automate this
monitorBorderRight = A_screenWidth
monitorBorderLeft = 0
monitorWidth := A_screenWidth
monitorHeight := A_screenHeight
taskbarHeight = 0

;; override system, here you can define a default offset and specific program offsets
;; this will allow you to setup for custom themes and programs that wont behave
;; I tried to make this work with WinGetPosEx but even that had many faults
global windowOverrides                            := Object()

windowOverrides["default"]                   := Object()
windowOverrides["default"]["left"]           := -8
windowOverrides["default"]["top"]            := 0
windowOverrides["default"]["width"]          := +16
windowOverrides["default"]["height"]         := +8

windowOverrides["explorer.exe"]                   := Object()
windowOverrides["explorer.exe"]["left"]           := -8
windowOverrides["explorer.exe"]["top"]            := 0
windowOverrides["explorer.exe"]["width"]          := +16
windowOverrides["explorer.exe"]["height"]         := +8

windowOverrides["chrome.exe"]                   := Object()
windowOverrides["chrome.exe"]["left"]           := -8
windowOverrides["chrome.exe"]["top"]            := 0
windowOverrides["chrome.exe"]["width"]          := +16
windowOverrides["chrome.exe"]["height"]         := +8

windowOverrides["ApplicationFrameHost.exe"]                   := Object()
windowOverrides["ApplicationFrameHost.exe"]["left"]           := -8
windowOverrides["ApplicationFrameHost.exe"]["top"]            := 0
windowOverrides["ApplicationFrameHost.exe"]["width"]          := +16
windowOverrides["ApplicationFrameHost.exe"]["height"]         := +8

SysGet, MonitorCount, MonitorCount
SysGet, MonitorPrimary, MonitorPrimary
;;MsgBox, Monitor Count:`t%MonitorCount%`nPrimary Monitor:`t%MonitorPrimary%
Loop, %MonitorCount%
{
    SysGet, MonitorName, MonitorName, %A_Index%
    SysGet, Monitor, Monitor, %A_Index%
    SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
    ;;MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`nTop:`t%MonitorTop% (%MonitorWorkAreaTop% work)`nRight:`t%MonitorRight% (%MonitorWorkAreaRight% work)`nBottom:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
}

;; what happens when:

;; -- TaskbarMontior1 Montitor2
;; -- TaskbarMonitor2 Monitor1

;; -- Monitor1 TaskbarMonitor2
;; -- Monitor2 TaskbarMontior1
;; * Monitor2: -1920
;; * Monitor1: 0


;;calculated variables used below
windowHeightTall := monitorHeight - (windowBorder * 2)
windowHeightTallTaskbar := monitorHeight - (windowBorder * 2) - taskbarHeight
windowRightWidth := monitorWidth - windowLeftWidth - (windowBorder * 3)


;;  _________     _________
;; |   |     |   |     |___| -- RightLeft
;; |   |     |   |  X  |   |
;; '---i-----'   '-----i---'
RightLeftWidth := windowLeftWidth
RightLeftHeight := windowHeightTallTaskbar
RightLeftLeft := windowBorder
RightLeftTop := windowBorder

;;  _________     _________
;; |   |     |   |     |   | -- RightRight
;; |   |     |   |     | X |
;; '---i-----'   '-----i---'
RightRightWidth := windowRightWidth
RightRightHeight := windowHeightTallTaskbar
RightRightLeft := windowLeftWidth + (windowBorder * 2)
RightRightTop := windowBorder

;;  _________     _________
;; |   |     |   |     |_X_| -- RightRightTop
;; |   |     |   |     |   |
;; '---i-----'   '-----i---'
RightRightTopWidth := windowRightWidth
RightRightTopHeight := windowRightSmallTopHeight
RightRightTopLeft := windowLeftWidth + (windowBorder * 2)
RightRightTopTop := windowBorder

;;  _________     _________
;; |   |     |   |     |___| -- RightRightBot
;; |   |     |   |     | X |
;; '---i-----'   '-----i---'
RightRightBotWidth := windowRightWidth
RightRightBotHeight := monitorHeight - taskbarHeight - (windowBorder * 3) - windowRightSmallTopHeight
RightRightBotLeft := windowLeftWidth + (windowBorder * 2)
RightRightBotTop := windowRightSmallTopHeight + (windowBorder * 2)

;; simplified winmove function call
ResizeWinMine(Width = 0,Height = 0, MyLeft = 0, MyTop = 0)
{
    WinGetPos,X,Y,W,H,A

    If %Width% = 0
      Width := W

    If %Height% = 0
      Height := H


    tmpArray := windowOverrides
    ;;PrintArray(tmpArray)

    noOverrides = 1

    For index, value in tmpArray{
      ;;MsgBox, index:`t%index%`n
      if(WinActive("ahk_exe" . index)){
        MyLeft := MyLeft + windowOverrides[index]["left"]
        MyTop := MyTop + windowOverrides[index]["top"]
        Width := Width + windowOverrides[index]["width"]
        Height := Height + windowOverrides[index]["height"]
        noOverrides = 0
        ;;MsgBox, MyLeft:`t%MyLeft%`n | MyTop:`t%MyTop% | Width:`t%Width% | Height:`t%Height%
      }
    }

    if(noOverrides == 1) {
      MyLeft := MyLeft + windowOverrides["default"]["left"]
      MyTop := MyTop + windowOverrides["default"]["top"]
      Width := Width + windowOverrides["default"]["width"]
      Height := Height + windowOverrides["default"]["height"]
      ;;MsgBox, test2
    }

    WinMove,A,,%MyLeft%,%MyTop%,%Width%,%Height%

}

;; configure menu
Menu, Tray, Icon , icon.ico
Menu, tray, NoStandard
Menu, Tray, Add, Exit, Exit
Menu, Tray, Add
Menu, Tray, Add
Menu, Tray, Add, &Right Left Large, LeftLarge
Menu, Tray, Add, &Right Right Small, RightSmall
Menu, Tray, Add
Menu, Tray, Add, &Right Right Small Top, RightSmallTop
Menu, Tray, Add, &Right Right Small Bottom, RightSmallBottom

;; keyboard shortcuts
#q::ResizeWinMine(RightLeftWidth,RightLeftHeight, RightLeftLeft, RightLeftTop)
#w::ResizeWinMine(RightRightWidth,RightRightHeight, RightRightLeft, RightRightTop)
#s::ResizeWinMine(RightRightTopWidth,RightRightTopHeight, RightRightTopLeft, RightRightTopTop)
#x::ResizeWinMine(RightRightBotWidth,RightRightBotHeight, RightRightBotLeft, RightRightBotTop)

;; menu items
;; for the menu we have to activate the previos window (may not be perfect in all case)
;; because the tray popup itself counts as a window
Exit:
ExitApp

LeftLarge:
Send !{Esc} ; Activate previous window
ResizeWinMine(RightLeftWidth,RightLeftHeight, RightLeftLeft, RightLeftTop)
return

RightSmall:
Send !{Esc} ; Activate previous window
ResizeWinMine(RightRightWidth,RightRightHeight, RightRightLeft, RightRightTop)
return

RightSmallTop:
Send !{Esc} ; Activate previous window
ResizeWinMine(RightRightTopWidth,RightRightTopHeight, RightRightTopLeft, RightRightTopTop)
return

RightSmallBottom:
Send !{Esc} ; Activate previous window
ResizeWinMine(RightRightBotWidth,RightRightBotHeight, RightRightBotLeft, RightRightBotTop)
return
