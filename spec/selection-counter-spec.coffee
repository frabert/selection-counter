SelectionCounter = require '../lib/selection-counter'

describe 'selection-counter', ->
  [selectionCounter] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.packages.activatePackage('selection-counter')

    runs ->
      selectionCounter = SelectionCounter.view
      expect(selectionCounter).toExist()

  it 'is hidden when there is no open editor', ->
    expect(selectionCounter.style.display).toBe('none')

  describe 'when an editor is open', ->
    [editor, pattern, hideWhenEmpty, hideWhenNoSelections] = []

    beforeEach ->
      waitsForPromise ->
        atom.workspace.open('sample.js')

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editor.setText "'some dummy string'; 'Nothing special, really';"

    it 'behaves according to the config', ->
      atom.config.set 'selection-counter.statusString', '%c %s %l'
      atom.config.set 'selection-counter.hideWhenEmpty', true
      atom.config.set 'selection-counter.hideWhenNoSelections', true
      editor.setCursorBufferPosition([0, 0])

      expect(selectionCounter.style.display).toBe('none')

      atom.config.set 'selection-counter.hideWhenEmpty', false
      atom.config.set 'selection-counter.hideWhenNoSelections', false
      editor.setText "'some dummy string'; 'Nothing special, really';"
      editor.setCursorBufferPosition([0, 0])

      expect(selectionCounter.style.display).toBe('inline-block')
      expect(selectionCounter.textContent).toBe('1 0 0')

    it 'shows correctly the number of cursors', ->
      atom.config.set 'selection-counter.statusString', '%c %s %l'
      atom.config.set 'selection-counter.hideWhenEmpty', false
      atom.config.set 'selection-counter.hideWhenNoSelections', false
      editor.setText "'some dummy string'; 'Nothing special, really';"

      # Keep in mind we already have one cursor
      editor.setCursorBufferPosition([0, 0])
      editor.addCursorAtBufferPosition([0, 5])
      editor.addCursorAtBufferPosition([0, 7])

      expect(selectionCounter.style.display).toBe('inline-block')
      expect(selectionCounter.textContent).toBe('3 0 0')

      atom.config.set 'selection-counter.hideWhenEmpty', true
      editor.setText "'some dummy string'; 'Nothing special, really';"

      editor.setCursorBufferPosition([0, 0])
      expect(selectionCounter.style.display).toBe('none')

      atom.config.set 'selection-counter.hideWhenNoSelections', true
      editor.setText "'some dummy string'; 'Nothing special, really';"

      expect(selectionCounter.style.display).toBe('none')
      editor.setCursorBufferPosition([0, 0])
      expect(selectionCounter.style.display).toBe('none')

    it 'shows correctly the number of cursors, selections and lines', ->
      atom.config.set 'selection-counter.hideWhenEmpty', false
      atom.config.set 'selection-counter.hideWhenNoSelections', false
      editor.setText "'some dummy string'; 'Nothing special, really';"

      editor.setCursorBufferPosition([0, 0])
      editor.addSelectionForBufferRange([[0, 0], [0, 5]])
      editor.addSelectionForBufferRange([[0,7], [0, 9]])
      expect(selectionCounter.style.display).toBe('inline-block')
      expect(selectionCounter.textContent).toBe('0 2 1')

      editor.setCursorBufferPosition([0, 0])
      editor.addCursorAtBufferPosition([0, 5])
      editor.addCursorAtBufferPosition([0, 7])
      editor.addSelectionForBufferRange([[0,9], [0, 11]])
      expect(selectionCounter.style.display).toBe('inline-block')
      expect(selectionCounter.textContent).toBe('3 1 1')

      editor.setText = "Hello, World!\nHola, Mundo!\nCiao, Mondo!"
      editor.setCursorBufferPosition([0, 0])
      editor.addSelectionForBufferRange([0, 0], [0, 5])
      editor.addSelectionForBufferRange([1, 6], [1, 11])
      editor.addSelectionForBufferRange([2, 4], [2, 6])
      expect(selectionCounter.style.display).toBe('inline-block')
      expect(selectionCounter.textContent).toBe('0 3 3')
