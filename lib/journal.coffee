path = require 'path'

module.exports =
class Journal
  createNewEntry: (date) ->
    atom.workspace.open(@entryPathForDate(date)).then (editor) =>
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
    if hours > 12
      hours = hours - 12
      suffix = "PM"
    else
      suffix = "AM"

    minutes = date.getMinutes()
    minutes = "0" + minutes if minutes < 10

    "#{hours}:#{minutes} #{suffix}"

  getPath: ->
    atom.config.get('journal.path').replace('~', process.env.HOME ? process.env.USERPROFILE)
