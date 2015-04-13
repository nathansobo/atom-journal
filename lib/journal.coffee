path = require 'path'

module.exports =
class Journal
  setSnippetsService: (@snippetsService) ->

  createNewEntry: (date) ->
    atom.workspace.open(@entryPathForDate(date)).then (editor) =>
      editor.setCursorBufferPosition([Infinity, Infinity])

      cursorRow = editor.getCursorBufferPosition().row
      unless editor.lineTextForBufferRow(cursorRow) is ""
        editor.insertNewline()

      cursorRow = editor.getCursorBufferPosition().row
      unless editor.lineTextForBufferRow(Math.max(0, cursorRow - 1)) is ""
        editor.insertNewline()

      if @snippetsService
        @snippetsService.insertSnippet("# #{@formattedTimeForDate(date)}${2: – $1}\n\n$3")
      else
        editor.insertText "# #{@formattedTimeForDate(date)}\n\n"

  entryPathForDate: (date) ->
    year = date.getFullYear().toString()
    month = (date.getMonth() + 1).toString()
    month = "0" + month if month.length is 1
    day = date.getDate().toString()
    day = "0" + day if day.length is 1
    path.join(@getPath(), year, month, day + '.md')

  formattedTimeForDate: (date) ->
    hours = date.getHours()
    if hours >= 12
      hours = hours - 12 if hours > 12
      suffix = "PM"
    else
      hours = 12 if hours is 0
      suffix = "AM"

    minutes = date.getMinutes()
    minutes = "0" + minutes if minutes < 10

    "#{hours}:#{minutes} #{suffix}"

  getPath: ->
    atom.config.get('journal.path').replace('~', process.env.HOME ? process.env.USERPROFILE)
