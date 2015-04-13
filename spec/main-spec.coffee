describe "Main module", ->
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise -> atom.packages.activatePackage('journal')
