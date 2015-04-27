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
      selectionCounter = document.querySelector('selection-counter-status')
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
        pattern = atom.config.get 'selection-counter.statusString'
        hideWhenEmpty = atom.config.get 'selection-counter.hideWhenEmpty'
        hideWhenNoSelections = atom.config.get 'selection-counter.hideWhenNoSelections'
        editor.setText "'some dummy string'; 'Nothing special, really';"

    it 'behaves according to the config', ->
      expect(selectionCounter.style.display).toBe('none') if hideWhenEmpty
      unless hideWhenEmpty
        expect(selectionCounter.style.display).toBe('inline-block')
        expect(selectionCounter.textContent).toBe(pattern.replace('%c', '1').replace('%s', '0'))

    it 'shows correctly the number of cursors', ->
      # Keep in mind we already have one cursor
      editor.addCursorAtBufferPosition([0, 5])
      editor.addCursorAtBufferPosition([0, 7])
      unless hideWhenNoSelections
        expect(selectionCounter.style.display).toBe('inline-block')
        expect(selectionCounter.textContent).toBe(pattern.replace('%c', '3').replace('%s', '0'))
        editor.setCursorBufferPosition([0, 0])
        expect(selectionCounter.style.display).toBe('none') if hideWhenEmpty

      if hideWhenNoSelections
        expect(selectionCounter.style.display).toBe('none')
        editor.setCursorBufferPosition([0, 0])
        expect(selectionCounter.style.display).toBe('none') if hideWhenEmpty

    it 'shows correctly the number of cursors and selections', ->
      editor.setCursorBufferPosition([0, 0])
      editor.addSelectionForBufferRange([[0, 0], [0, 5]])
      editor.addSelectionForBufferRange([[0,7], [0, 9]])
      expect(selectionCounter.style.display).toBe('inline-block')
      expect(selectionCounter.textContent).toBe(pattern.replace('%c', '0').replace('%s', '2'))

      editor.setCursorBufferPosition([0, 0])
      editor.addCursorAtBufferPosition([0, 5])
      editor.addCursorAtBufferPosition([0, 7])
      editor.addSelectionForBufferRange([[0,9], [0, 11]])
      expect(selectionCounter.style.display).toBe('inline-block')
      expect(selectionCounter.textContent).toBe(pattern.replace('%c', '3').replace('%s', '1'))
