import os
import strutils

when isMainModule:
  var command: string = ""
  var debugMode = false
  var execute = true

  while true:
    execute = true
    stdout.write "T> "
    command = readLine(stdin)

    if command == "exit":
      break

    if command == "debugMode":
      debugMode = not debugMode
      execute = false

    elif command == "gs":
      command = "git status"

    elif command.startsWith("gcam"):
      command = command.replace("gcam ", "git commit -am \"")
      command.add("\"")

    if execute:
      if debugMode:
        echo(command)

      discard os.execShellCmd(command)