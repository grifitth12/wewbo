import pkg/illwill
import ui/asset
import std/[strutils, terminal]

type WewboLogger* = ref object of RootObj
  height: int
  width: int
  tb: TerminalBuffer
  logs: seq[string]
  bannerHeight: int = 8

proc cleanup() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)    

proc newWewboLogger*(height = terminalHeight(), width = terminalWidth()) : WewboLogger =
  result = WewboLogger(
    width: width,
    height: height,
    tb: newTerminalBuffer(width, height)
  )
  try :
    hideCursor()
    illwillInit(fullscreen=false)
    setControlCHook(cleanup)
  except IllwillError :
    discard

proc renderLogs(l: WewboLogger) =
  var
    padding: int
    rijal = l.bannerHeight
  
  for message in l.logs :
    padding = l.width - message.len - 2
    l.tb.write(0, rijal, fgCyan, "║", fgWhite, "  " & message & " ".repeat(padding), fgCyan, "║")
    rijal += 1
  
  for i in rijal .. l.height - 2 :
    l.tb.write(0, i, fgCyan, "║" & " ".repeat(l.width - 2) & "║")

proc render(l: WewboLogger) =
  l.tb.renderBanner()
  l.tb.renderTopBorder(7)
  l.renderLogs()
  l.tb.renderBottomBorder(l.width, l.height - 1)
  l.tb.display()

proc info*(l: WewboLogger, text: string) =
  l.logs.add(text)
  l.render()

var log* = newWewboLogger()