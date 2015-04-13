path = require 'path'
main = require '../lib/main'

describe "Main module", ->
  [journalPath, workspaceElement, editor] = []

  beforeEach ->
    journalPath = path.join(__dirname, 'fixtures')
    atom.config.set('journal.path', journalPath)

    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise -> atom.packages.activatePackage('journal')
    waitsForPromise -> atom.packages.activatePackage('snippets')

  describe "when 'journal:new-entry' is dispatched on the workspace element", ->
    it "opens a file at a path based on the current date", ->
      mockDate = new Date
      mockDate.setFullYear(2015)
      mockDate.setMonth(4 - 1) # April
      mockDate.setDate(8) # 8th
      mockDate.setHours(9, 5) # 9:05
      spyOn(main, 'getCurrentDate').andReturn(mockDate)
      expectedPath = "#{journalPath}/2015/04/08.md"

      atom.commands.dispatch workspaceElement, 'journal:new-entry'
      waitsFor "editor to be opened to the correct path", ->
        atom.workspace.getActiveTextEditor()?.getPath() is expectedPath

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editorElement = atom.views.getView(editor)
        expect(editor.lineTextForBufferRow(0)).toBe "# 9:05 AM – "
        expect(editor.getCursorBufferPosition()).toEqual [0, 12]
        atom.commands.dispatch editorElement, 'snippets:next-tab-stop'
        expect(editor.getSelectedBufferRange()).toEqual [[0, 9], [0, 12]]
        atom.commands.dispatch editorElement, 'snippets:next-tab-stop'
        expect(editor.getCursorBufferPosition()).toEqual [2, 0]

        editor.insertText("Captain's Log, Stardate 43153.7. We are departing the Rana system for Starbase 133.")
        editor.setCursorBufferPosition([2, 10])

        mockDate.setHours(13, 20)
        atom.commands.dispatch workspaceElement, 'journal:new-entry'

      waitsFor "a second heading to be inserted", ->
        editor.lineTextForBufferRow(4) is "# 1:20 PM – "
