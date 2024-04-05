import os
import strutils
import terminal
import sequtils

type
  Feature {. pure .} = enum
    git = "git"

const preprint = " T> "

proc handleLiveInput(cursorStart: int, history: seq[string]): string =
  var ret = false
  var value = ""
  var currentCursorPos = 0
  var historyIndex = history.len()

  proc clearCurrentOutput() =
    stdout.setCursorXPos(cursorStart)
    stdout.write repeat(" ", value.len())
    stdout.setCursorXPos(cursorStart)

  proc printVal() =
    stdout.setCursorXPos(cursorStart)
    stdout.write value, " "
    stdout.setCursorXPos(cursorStart+currentCursorPos)

  proc historyLoad() =
    var element: string
    if historyIndex >= history.len():
      element = ""
    else:
      element = history[historyIndex]
    clearCurrentOutput()
    value = element
    currentCursorPos = element.len()
    printVal()

  while not ret:
    var key = getch()
    #echo toHex(byte(key))
    if key == '\r':
      ret = true
      echo ""

    elif int(key) == 0x1b:
      key = getch()
      if key == '[':
        # Now we have arrow keys
        key = getch()
        case key:
        of 'A':
          if historyIndex > 0:
            historyIndex -= 1
            historyLoad()
        of 'B':
          if historyIndex < history.len():
            historyIndex += 1
            historyLoad()
        of 'C':
          if currentCursorPos < value.len():
            stdout.cursorForward(1)
            currentCursorPos += 1
        of 'D':
          if currentCursorPos > 0:
            stdout.cursorBackward(1)
            currentCursorPos -= 1
        of '3':
          # Other codes?
          key = getch()
          case key:
          of '~':
            if currentCursorPos < value.len():
              value.delete(currentCursorPos..currentCursorPos)
              printVal()
          else:
            echo "Strange, got sth else l2 ", key
        else:
          echo "Strange, got sth else ", key

    elif int(key) == 0x7f:
      if currentCursorPos > 0:
        value.delete(currentCursorPos-1..currentCursorPos-1)
        currentCursorPos -= 1
        printVal()

    else:
      value.insert($key, currentCursorPos)
      currentCursorPos += 1
      printVal()

  value

when isMainModule:
  var command: string = ""
  var debugMode = false
  var execute = true
  var featureMap: array[Feature, bool]
  var history: seq[string]

  for f in featureMap.mitems:
    f = true

  while true:
    execute = true
    var currentPath = getCurrentDir()
    stdout.styledWrite(fgGreen, currentPath, fgCyan, preprint)
    command = handleLiveInput(currentPath.len() + preprint.len(), history)
    history.add(command)
    #echo "e:", command

    if command == "exit":
      break

    if command == "debugMode":
      debugMode = not debugMode
      execute = false

    if command.startsWith("toggle-mode"):
      var spl = command.splitWhitespace()
      if spl.len() < 2:
        echo "Please specify a feature of: ", join(Feature.mapIt($it), ", ")
      else:
        try:
          var f = parseEnum[Feature](spl[1])
          featureMap[f] = not featureMap[f]
          echo "Set ", f, " to ", featureMap[f]
        except:
          echo "Invalid option, please chose one of: ", join(Feature.mapIt($it), ", ")
      execute = false

    if command.startsWith("cd "):
      # Todo handle paths with whitespace elements
      var spl = command.splitWhitespace()
      if spl.len() > 1:
        try:
          setCurrentDir(spl[1])
        except:
          echo getCurrentExceptionMsg()
      execute = false

    if featureMap[git]:
      if command == "gs":
        command = "git status"

      elif command.startsWith("gcam"):
        command = command.replace("gcam ", "git commit -am \"")
        command.add("\"")

      elif command.startsWith("gcm"):
        command = command.replace("gcm ", "git commit -m \"")
        command.add("\"")

      elif command == "gaa":
        command = "git add -A"

      elif command == "gp":
        command = "git pull"

      elif command == "gpu":
        command = "git push"

    if execute:
      if debugMode:
        echo(command)

      discard os.execShellCmd(command)