{CompositeDisposable} = require 'atom'

module.exports =
  disposables: null

  activate: (state) ->
    @disposables = new CompositeDisposable

  deactivate: ->
    @disposables.dispose()
