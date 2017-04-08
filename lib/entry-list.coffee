{SelectListView} = require 'atom-space-pen-views'

module.exports =
class EntryList extends SelectListView
  viewForItem: ({displayText}) ->
    element = document.createElement('li')
    element.innerText = displayText
    element

  getFilterKey: -> 'displayText'

  confirmed: ({filePath, row}) ->
    atom.workspace.open(filePath, initialLine: row)
