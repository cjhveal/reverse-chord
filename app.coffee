class KeyModel extends Backbone.Model
  toggleSelected: =>
    @set 'selected', !@get('selected')
    @collection.trigger 'change:selected'

class KeyCollection extends Backbone.Collection
  initialize: =>
    cMajorNotes = teoria.scale('C', 'major').notes()
    @cMajorKeys = _.invoke cMajorNotes, 'key'

  model: (attrsArg, opts) =>
    defaults = {note: teoria.note('C'), ebony: false, collection: @collection}
    attrs = _.extend {}, defaults, attrsArg
    attrs.ebony = @isEbony(attrs.note)
    new KeyModel attrs, opts

  isEbony: (note) =>
    not _.contains @cMajorKeys, note.key()

  selectedNotes: =>
    keys = @filter (key) -> key.get 'selected'
    _.map keys, (key) -> key.get('note')

class MainView extends Backbone.Marionette.Layout
  el: '#app'
  template: _.template("<div id='keyboard' class='keyboard'></div><div id='chords' class='chords'></div>")
  regions:
    'keyboard': '#keyboard'
    'chords': '#chords'

  initialize: =>
    octave1 = teoria.scale('C', 'chromatic').notes()
    octave2 = teoria.scale('C', 'chromatic').notes()
    chromaticNotes = octave1.concat octave2
    notes = _.map chromaticNotes, (note) -> {note}
    @keyCollection = new KeyCollection(notes)

    @chordView = new ChordView(collection: @keyCollection)
    @keyboardView = new KeyboardView(collection: @keyCollection)

  renderRegions: =>
    @keyboard.show(@keyboardView.render())
    @chords.show(@chordView.render())

chordViewTemplate = Handlebars.compile("{{#each chords}}<div class='chord-name'>{{this}}</div>{{/each}}")
class ChordView extends Backbone.Marionette.ItemView
  template: chordViewTemplate
  collectionEvents:
    'change:selected': 'render'

  serializeData: =>
    notes = @collection.selectedNotes()
    chords = piu.infer(notes).map(piu.name)
    {chords: chords}



keyViewTemplate = Handlebars.compile("<div class='key{{#if ebony}} ebony{{/if}}{{#if selected}} selected{{/if}}'></div>")

class KeyView extends Backbone.Marionette.ItemView
  template: keyViewTemplate
  events:
    "click": 'toggleSelected'
  modelEvents:
    "change:selected": 'render'

  toggleSelected: =>
    @model.toggleSelected()

class KeyboardView extends Backbone.Marionette.CollectionView
  itemView: KeyView

window.view = new MainView()

view.render()
view.renderRegions()
