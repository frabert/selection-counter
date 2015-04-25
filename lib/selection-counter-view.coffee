class SelectionCounterView extends HTMLDivElement
  initialize: (@statusBar) ->
    @classList.add('selection-counter', 'inline-block')
    @handleEvents()

  attach: ->
    @tile = @statusBar.addLeftTile(item: this)

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    editor = @getActiveTextEditor()

    @selectionSubscription?.dispose()
    @selectionSubscription = editor?.onDidChangeSelectionRange =>
      @updateSelectionText()

    @positionSubscription?.dispose()
    @positionSubscription = editor?.onDidChangeCursorPosition =>
      @updateSelectionText()

    @selectionObserve?.dispose()
    @selectionObserve = editor?.observeSelections =>
      @updateSelectionText()

    @cursorObserve?.dispose()
    @cursorObserve = editor?.observeCursors =>
      @updateSelectionText()

    editor?.onDidAddCursor =>
      @updateSelectionText()

    editor?.onDidRemoveCursor =>
      @updateSelectionText()

    editor?.onDidAddSelection =>
      @updateSelectionText()

    editor?.onDidRemoveSelection =>
      @updateSelectionText()

    @updateSelectionText()

  buildStatusString: (selections, cursors) ->
    pattern = atom.config.get 'selection-counter.statusString'
    hide = atom.config.get 'selection-counter.hideWhenEmpty'
    if selections == 0 and cursors == 1 and hide == true
      return ''
    else
      return pattern.replace('%n', (cursors - selections).toString())
        .replace('%s', selections.toString())
        .replace('%c', cursors.toString())

  updateSelectionText: ->
    editor = @getActiveTextEditor()
    if(editor?)
      selections = editor.getSelectedBufferRanges()
      cursors = editor.getCursorBufferPositions()

      numSelections = 0
      i = 0
      while i < selections.length
        if !selections[i].isEmpty()
          numSelections++
        i++

      @style.display = 'inline-block'
      @textContent = @buildStatusString(numSelections, cursors.length)
    else
      @style.display = 'none'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    #@selectionSubscription?.dispose()
    #@positionSubscription?.dispose()

module.exports = document.registerElement('selection-counter-status', prototype: SelectionCounterView.prototype)
