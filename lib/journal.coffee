module.exports =
class Journal
  createNewEntry: (date) ->
    console.log "createNewEntry called with #{date} on journal with path #{@getPath()}"

  getPath: ->
    atom.config.get('journal.path').replace('~', process.env.HOME ? process.env.USERPROFILE)
