{CompositeDisposable} = require 'atom'

module.exports =
  config:
    path:
      type: 'string'
      default: '~/journal'

  disposables: null

  activate: (state) ->
    @disposables = new CompositeDisposable

  deactivate: ->
    @disposables.dispose()
