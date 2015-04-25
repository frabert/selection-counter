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
    selections = editor?.getSelectedBufferRanges()
    cursors = editor?.getCursorBufferPositions()

    numSelections = 0
    if selections
      for sel in selections
        unless sel.isEmpty
          numSelections = numSelections + 1
    # Now we have to make some reasonings...
    # For example, if we have just one selection it may mean
    # that there is actually just one selection,
    # or it may mean that the only selection is the cursor, or...
    # that we have a selection BUT getSelectedBufferRanges hasn't noticed yet.
    if cursors?
      @style.display = 'inline-block'
      @textContent = @buildStatusString(numSelections, cursors.length)
      ###
      if cursors.length == 0
        @textContent = buildStatusString(0)
      else if cursors.length == 1
        if selections[0].isEmpty
          @textContent = buildStatusString(0)
        else
          @textContent = buildStatusString(1)
      else
        @textContent = buildStatusString(cursors.length)
      ###
    else
      @style.display = 'none'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    #@selectionSubscription?.dispose()
    #@positionSubscription?.dispose()

module.exports = document.registerElement('selection-counter-status', prototype: SelectionCounterView.prototype)
