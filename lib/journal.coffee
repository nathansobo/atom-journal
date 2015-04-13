path = require 'path'

module.exports =
class Journal
  createNewEntry: (date) ->
    atom.workspace.open(@entryPathForDate(date))

  entryPathForDate: (date) ->
    year = date.getFullYear().toString()
    month = (date.getMonth() + 1).toString()
    month = "0" + month if month.length is 1
    day = date.getDate().toString()
    day = "0" + day if day.length is 1
    path.join(@getPath(), year, month, day + '.md')

  getPath: ->
    atom.config.get('journal.path').replace('~', process.env.HOME ? process.env.USERPROFILE)
