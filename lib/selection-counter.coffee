{CompositeDisposable} = require 'atom'
SelectionCounterView = require './selection-counter-view'
selectionCounterView = null

module.exports =
  config:
    hideWhenEmpty:
      type: 'boolean'
      default: true
      description: 'Whether the status hides when there is only one empty cursor'
    statusString:
      type: 'string'
      default: "S%s"
      description: 'The text to show in the status. %c = n. of cursors, %s = n. of selections'

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    selectionCounterView = new SelectionCounterView()

  consumeStatusBar: (statusBar) ->
    selectionCounterView.initialize(statusBar)
    selectionCounterView.attach()

  deactivate: ->
    selectionCounterView?.destroy()
    selectionCounterView = null
    @subscriptions.dispose()

  serialize: ->

  toggle: ->
    console.log 'SelectionCounter was toggled!'
