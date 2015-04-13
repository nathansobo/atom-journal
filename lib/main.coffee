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
      'journal:list-entries': => @showEntryList()

  getCurrentDate: -> new Date

  deactivate: ->
    @disposables.dispose()

  consumeSnippetsService: (service) ->
    @journal.setSnippetsService(service)
    new Disposable => @journal.setSnippetsService(null)

  showEntryList: ->
    @createEntryList()

    @entryListPanel.show()
    @journal.listEntries().then (entries) =>
      @entryList.setItems(entries)
      @entryList.focusFilterEditor()

  createEntryList: ->
    return @entryListPanel if @entryListPanel?

    EntryList = require './entry-list'
    @entryList = new EntryList
    @entryList.cancelled = =>
      @entryListPanel.hide()
      atom.workspace.getActivePane().activate()

    @entryListPanel = atom.workspace.addModalPanel(item: @entryList.element)
