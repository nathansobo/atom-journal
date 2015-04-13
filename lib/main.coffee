{CompositeDisposable, Disposable} = require 'atom'

Journal = require './journal'

module.exports =
  config:
    path:
      type: 'string'
      default: '~/journal'

  disposables: null

  activate: (state) ->
    @disposables = new CompositeDisposable
    @journal = new Journal

    @disposables.add atom.commands.add 'atom-workspace',
      'journal:new-entry': => @journal.createNewEntry(@getCurrentDate())

  getCurrentDate: -> new Date

  deactivate: ->
    @disposables.dispose()

  consumeSnippetsService: (service) ->
    @journal.setSnippetsService(service)
    new Disposable => @journal.setSnippetsService(null)
