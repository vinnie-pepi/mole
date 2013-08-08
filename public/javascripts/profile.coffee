class Profile
  constructor: (@searchForm, @entities, @selectedList) ->
    @registerEvents()

  registerEvents: ->
    console.log(@searchForm)

    @searchForm.ajaxForm({
      success: (rows) => 
        @showEntities(rows)
    })

  showEntities: (rows) ->
    template = """
               li.list-group-item
                 .list-group-item-heading.name= name
                 .list-group-item-text
                   span.address= address
                   span.categories= (category_labels || []).join(',')
                   span.latitude= latitude
                   span.longitude= longitude
               """
    jadeTemp = jade.compile(template)
    for row in rows
      @entities.append(jadeTemp(row))
      
window.Profile = Profile
