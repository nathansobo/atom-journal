path = require 'path'
Journal = require '../lib/journal'

describe "Journal", ->
  [journalPath, journal] = []

  beforeEach ->
    journalPath = path.join(__dirname, 'fixtures')
    atom.config.set('journal.path', journalPath)
    journal = new Journal

  describe "::listEntries()", ->
    it "returns a promise that resolves to a list of journal entries in reverse chronological order", ->
      entries = null
      waitsForPromise ->
        journal.listEntries().then (result) -> entries = result

      runs ->
        expect(entries).toEqual [
          {
            displayText: "2015/04/05 @ 11:00 PM",
            filePath: "#{journalPath}/2015/04/05.md"
            row: 4,
          }
          {
            displayText: "2015/04/05 @ 10:00 AM",
            filePath: "#{journalPath}/2015/04/05.md"
            row: 0
          }
          {
            displayText: "2015/04/01 @ 9:00 AM – April Fools",
            filePath: "#{journalPath}/2015/04/01.md"
            row: 0
          }
          {
            displayText: "2015/03/15 @ 12:00 PM – The Ides of March",
            filePath: "#{journalPath}/2015/03/15.md"
            row: 0
          }
        ]
