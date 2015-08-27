class SelectionCounterView extends HTMLDivElement
  initialize: (@statusBar) ->
    @classList.add('selection-counter', 'inline-block')
    @handleEvents()

  attach: ->
    alignment = atom.config.get 'selection-counter.statusAlignment'
    if alignment == 'left'
      @tile = @statusBar.addLeftTile(item: this)
    else
      @tile = @statusBar.addRightTile(item: this)

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    editor = @getActiveTextEditor()

    @positionSubscription?.dispose()
    @positionSubscription = editor?.onDidChangeCursorPosition =>
      console.log 'onDidChangeCursorPosition'
      @updateSelectionText()

    @selectionAddSubscription?.dispose()
    @selectionAddSubscription = editor?.onDidAddSelection =>
      console.log 'onDidAddSelection'
      @updateSelectionText()

    @selectionRemoveSubscription?.dispose()
    @selectionRemoveSubscription = editor?.onDidRemoveSelection =>
      console.log 'onDidRemoveSelection'
      @updateSelectionText()

    @selectionRangeChangeSubscription?.dispose()
    @selectionRangeChangeSubscription = editor?.onDidChangeSelectionRange =>
      console.log 'onDidChangeSelectionRange'
      @updateSelectionText()

    @updateSelectionText()

  buildStatusString: (linesSelections, selections, cursors) ->
    pattern = atom.config.get 'selection-counter.statusString'
    hideWhenEmpty = atom.config.get 'selection-counter.hideWhenEmpty'
    console.log hideWhenEmpty
    hideWhenNoSelections = atom.config.get 'selection-counter.hideWhenNoSelections'
    console.log hideWhenNoSelections

    if selections == 0 and hideWhenNoSelections
      return ''
    if selections == 0 and cursors == 1 and hideWhenEmpty
      return ''
    else
      pattern.replace('%s', selections.toString())
        .replace('%c', cursors.toString())
        .replace('%l', linesSelections.toString())

  updateSelectionText: ->
    editor = @getActiveTextEditor()
    if editor?
      selections = editor.getSelectedBufferRanges()
      cursors = editor.getCursorBufferPositions()

      linesSelections = 0
      numSelections = 0
      i = 0
      while i < selections.length
        if !selections[i].isEmpty()
          numSelections++
          linesSelections += selections[i].getRowCount()
        i++

      statusString = @buildStatusString(linesSelections, numSelections, cursors.length - numSelections)
      if statusString == ''
        @style.display = 'none'
      else
        @style.display = 'inline-block'
        @textContent = statusString
    else
      @style.display = 'none'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @positionSubscription?.dispose()
    @selectionAddSubscription?.dispose()
    @selectionRemoveSubscription?.dispose()
    @tile?.destroy()

module.exports = document.registerElement('selection-counter-status', prototype: SelectionCounterView.prototype)
