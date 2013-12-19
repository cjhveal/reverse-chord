
chromaticNotes = teoria.scale('C', 'chromatic').notes()
notes = _.map chromaticNotes, (note) -> {note}

class KeyModel extends Backbone.Model


class KeyCollection extends Backbone.Collection
  initialize: =>
    cMajorNotes = teoria.scale('C', 'major').notes()
    @cMajorKeys = _.invoke cMajorNotes, 'key'

  model: (attrsArg, opts) =>
    defaults = {note: teoria.note('C'), ebony: false}
    attrs = _.extend {}, defaults, attrsArg
    attrs.ebony = @isEbony(attrs.note)
    new KeyModel attrs, opts

  isEbony: (note) =>
    not _.contains @cMajorKeys, note.key()

  selectedNotes: =>
    keys = @filter (key) -> key.get 'selected'
    _.map keys, (key) -> key.get('note')

class ChordView extends Backbone.View

keyViewTemplate = Handlebars.compile("<div class='key{{#if ebony}} ebony{{/if}}{{#if selected}} selected{{/if}}'></div>")

class KeyView extends Backbone.Marionette.ItemView
  template: keyViewTemplate
  events:
    "click": 'toggleSelected'
  modelEvents:
    "change:selected": 'render'

  toggleSelected: =>
    @model.set 'selected', !@model.get('selected')

class KeyboardView extends Backbone.Marionette.CollectionView
  itemView: KeyView
  el: '#keyboard'

window.view = new KeyboardView {collection: new KeyCollection(notes)}

view.render()
