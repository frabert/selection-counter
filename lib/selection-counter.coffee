{CompositeDisposable} = require 'atom'
selectionCounterView = null

module.exports =
  config:
    hideWhenEmpty:
      type: 'boolean'
      default: true
      description: 'Whether the status hides when there is only one empty cursor'
    statusString:
      type: 'string'
      default: "S%n"
      description: 'The text to show in the status. %n = n. of cursors minus n. of selections, %c = n. of cursors, %s = n. of selections'

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

  consumeStatusBar: (statusBar) ->
    SelectionCounterView = require './selection-counter-view'
    selectionCounterView = new SelectionCounterView()
    selectionCounterView.initialize(statusBar)
    selectionCounterView.attach()

  deactivate: ->
    selectionCounterView?.destroy()
    selectionCounterView = null
    @subscriptions.dispose()

  serialize: ->

  toggle: ->
    console.log 'SelectionCounter was toggled!'