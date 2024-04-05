import os
import strutils
import terminal

type
  Feature = enum
    git

proc handleLiveInput(): string =
  var ret = false
  var value = ""
  while not ret:
    var print = true
    var key = getch()
    if key == '\n':
      ret = true

    if print:
      stdout.write (int)key

  value

when isMainModule:
  var command: string = ""
  var debugMode = false
  var execute = true
  var featureMap: array[Feature, bool]

  for f in featureMap.mitems:
    f = true

  while true:
    execute = true
    stdout.styledWrite(fgBlue, "T> ")
    #stdout.write "T> "
    command = handleLiveInput()

    if command == "exit":
      break

    if command == "debugMode":
      debugMode = not debugMode
      execute = false

    if command == "toggle-git-mode":
      featureMap[git] = not featureMap[git]
      execute = false

    if featureMap[git]:
      if command == "gs":
        command = "git status"

      elif command.startsWith("gcam"):
        command = command.replace("gcam ", "git commit -am \"")
        command.add("\"")

    if execute:
      if debugMode:
        echo(command)

      discard os.execShellCmd(command)