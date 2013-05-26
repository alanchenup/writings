class ArticleEdit.NoteManager
  constructor: (@manager) ->
    @article = @manager.article
    @space = @manager.space

    @notes = $('#notes')
    @ids = []

    @updateNoteContext()
    @article.find('img').one 'load', =>
      @updateNoteContext()

    @bindActions()

  bindActions: ->
    @manager.editor.editable.on 'editor:change', =>
      @updateNoteContext()
      @article.find('img').one 'load', =>
        @updateNoteContext()

    @manager.article.on 'mouseover', 'p, h1, h2, h3, h4, pre, li', ->
      if this.id
        $("#note-context-#{this.id}").addClass('show-on-mouseover').siblings().removeClass('show-on-mouseover')

    @manager.article.on 'click', 'p, h1, h2, h3, h4, pre, li', ->
      if this.id
        $("#note-context-#{this.id}").addClass('show-on-click').siblings().removeClass('show-on-click')

    _this = this
    $('#notes').on 'click', '.add-note-button', ->
      _this.openContext($(this).closest('.note-context').data('element-id'))

    $('#notes').on 'click', '.close-button', ->
      $(this).closest('.note-context').html('<a class="add-note-button"><i class="icon-pushpin"></i></a>').removeClass('actived')

  openContext: (id) ->
    $("#note-context-#{id}").siblings().html('<a class="add-note-button"><i class="icon-pushpin"></i></a>').removeClass('actived')
    $.ajax(
      url: "/~#{@space}/notes/new?article_id=#{@article.data('id')}&element_id=#{id}"
      dataType: 'script'
    )

  updateNoteContext: ->
    _this = this
    @currentIds = []
    @article.find('p, h1, h2, h3, h4, pre, li').each ->
      if this.id is '' or $("##{this.id}")[0] isnt this
        this.id = Math.random().toString(36).substring(2, 10)
      _this.currentIds.push this.id

    # remove
    for id in @ids when @currentIds.indexOf(id) < 0
      $("#note-context-#{id}").remove()

    # new
    for id in @currentIds
      element = $("##{id}")
      context = $("#note-context-#{id}")
      if !context.length
        context = $("<div id='note-context-#{id}' class='note-context'>").data('element-id', id)
        context.html('<a class="add-note-button"><i class="icon-pushpin"></i></a>')
        @notes.append(context)

      top = element.position().top + parseInt(element.css('margin-top'))
      context.css(
        top: "#{element.position().top}px"
        height: "#{element.innerHeight()}px"
        'padding-top': "#{parseInt(element.css('margin-top'))}px"
        'padding-bottom': "#{parseInt(element.css('margin-bottom'))}px"
      )

    @ids = @currentIds
