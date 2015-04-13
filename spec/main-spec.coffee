path = require 'path'
main = require '../lib/main'

describe "Main module", ->
  [journalPath, workspaceElement] = []

  beforeEach ->
    journalPath = path.join(__dirname, 'fixtures')
    atom.config.set('journal.path', journalPath)

    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise -> atom.packages.activatePackage('journal')

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
      waitsFor ->
        atom.workspace.getActiveTextEditor()?.getPath() is expectedPath

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        expect(editor.lineTextForBufferRow(0)).toBe "# 9:05 AM"
        expect(editor.getCursorBufferPosition()).toEqual [2, 0]
