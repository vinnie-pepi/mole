class Profile
  constructor: (seedData) ->
    @seedData = seedData
    @initHTML()
    @registerEvents()

  initHTML: ->
    @template = """
               li.list-group-item
                 .list-group-item-heading.name= n 
                 .list-group-item-text.categories= (category_labels || []).join(',')
                 .details
                   input.geoRef(type="hidden", data-latitude=latitude, data-longitude=longitude, data-locality=locality, data-name=n, data-address=address, data-factual_id=factual_id, data-category=category_labels)
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
    @$entityList   = $(".entityList")
    @$schedule     = $("#schedule")
    @$selectedList = $(".selectedList")
    @$searchForm   = $("#searchForm")
    @$saveSchedule = $("#save")
    @showSeedData()

  registerEvents: ->
    @$searchForm.ajaxForm({
      success: (rows) =>
        @showEntities(rows)
    })
    geoRefs = []
    @$saveSchedule.click (e) =>
      e.preventDefault()
      profileId = @$schedule.find('input[name=profile_id]').val()
      @$schedule.find('input.geoRef').each ->
        ref = $(this).data()
        ref.id = profileId
        geoRefs.push(ref)
      $.post '/profile/'+profileId+"/createEvents", { targets: geoRefs }, (data) =>
        showRefs(data)
        
  showEntities: (rows) ->
    jadeTemp = jade.compile(@template)
    for row in rows
      # for some reason adding row.name breaks jade
      row.n = row.name
      @appendSearchResult(row, jadeTemp)

  showSeedData: () ->
    jadeTemp = jade.compile(@template)
    for row in @seedData
      # for some reason adding row.name breaks jade
      row.n = row.name
      $row = $(jadeTemp(row))
      @$selectedList.append($row)

  appendSearchResult: (row, jadeTemp) ->
    $row = $(jadeTemp(row))
    $row.click (e) =>
      @$selectedList.append($row.clone().addClass("schedule-item"))
      if @$saveSchedule.hasClass('disabled')
        @$saveSchedule.removeClass('disabled')
    @$entityList.append($row)
      
window.Profile = Profile
