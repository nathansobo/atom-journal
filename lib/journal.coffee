JournalView = require './journal-view'
{CompositeDisposable} = require 'atom'

module.exports = Journal =
  journalView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @journalView = new JournalView(state.journalViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @journalView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'journal:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @journalView.destroy()

  serialize: ->
    journalViewState: @journalView.serialize()

  toggle: ->
    console.log 'Journal was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
