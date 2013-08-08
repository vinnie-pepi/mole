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
                 .list-group-item-heading.name= n 
                 .list-group-item-text.categories= (category_labels || []).join(',')
                 .details
                  input.geoRef(type="hidden", data-lat=latitude, data-long=longitude, data-timestamp="")
                   table  
                     tr
                       th Address
                       th Latitude
                       th Longitutde
                     tr
                       td.address= address
                       td.latitude= latitude
                       td.longitude= longitude
               """
    jadeTemp = jade.compile(template)
    for row in rows
      row.n = row.name
      @appendSearchResult(row, jadeTemp)

  appendSearchResult: (row, jadeTemp) ->
    $row = $(jadeTemp(row))
    $row.click (e) =>
      @selectedList.append($row.clone())

    @entities.append($row)
      
window.Profile = Profile
