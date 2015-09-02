_ = require 'underscore-plus'

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
      @updateSelectionText()

    @selectionAddSubscription?.dispose()
    @selectionAddSubscription = editor?.onDidAddSelection =>
      @updateSelectionText()

    @selectionRemoveSubscription?.dispose()
    @selectionRemoveSubscription = editor?.onDidRemoveSelection =>
      @updateSelectionText()

    @updateSelectionText()

  buildStatusString: (linesSelections, selections, cursors) ->
    pattern = atom.config.get 'selection-counter.statusString'
    hideWhenEmpty = atom.config.get 'selection-counter.hideWhenEmpty'
    hideWhenNoSelections = atom.config.get 'selection-counter.hideWhenNoSelections'

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
    mergeSelections = (selections) ->
      flattenedSelections = _.map selections, (s) -> s.getBufferRowRange()
      sortedSelections = _.sortBy flattenedSelections, (x) -> x[0]
      reduceLines = (s) ->
        if(s.length is 0 or s.length is 1)
          return s
        else
          a = s[0]
          b = s[1]
          tail = s.slice 2
          inRange = (x) -> (a[0] <= x) && (a[1] >= x)
          if(inRange b[0])
            if(inRange b[1])
              tail.unshift a
              return reduceLines tail
            else
              c = [a[0], b[1]]
              tail.unshift c
              return reduceLines tail
          else
            tail.unshift b
            tail = reduceLines tail
            tail.unshift a
            return tail

      reduced = reduceLines sortedSelections
      return reduced

    if editor?
      selections = editor.getSelectedBufferRanges()
      cursors = editor.getCursorBufferPositions()

      reducedSelections = mergeSelections editor.getSelections()
      selectionLengths = _.map reducedSelections, (s) -> s[1] - s[0] + 1
      linesSelections = _.reduce selectionLengths, ((memo, l) -> memo + l), 0

      numSelections = 0
      i = 0
      while i < selections.length
        if !selections[i].isEmpty()
          numSelections++
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
