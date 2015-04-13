{SelectListView} = require 'atom-space-pen-views'

module.exports =
class EntryList extends SelectListView
  initialize: ->
    super
    @on 'focusout', => @cancel()

  viewForItem: ({displayText}) ->
    element = document.createElement('li')
    element.innerText = displayText
    element

  getFilterKey: -> 'displayText'

  confirmed: (item) ->
