class @Map
  constructor: (element, lat, lng) ->
    lat = 0 unless lat != undefined
    lng = 0 unless lng != undefined
    @point =  new google.maps.LatLng lat, lng

    @options =
      zoom: 8
      maxZoom: 15
      center: @point
      mapTypeControlOptions: {
        mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE, google.maps.MapTypeId.HYBRID, google.maps.MapTypeId.TERRAIN],
        style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
      },
      mapTypeId: google.maps.MapTypeId.ROADMAP

    @map = new google.maps.Map element, @options

  populate: (points) ->
    $.get points, (data) =>
      infoWindow = new google.maps.InfoWindow()

      pointList = []
      for point in data
        latlng = new google.maps.LatLng point['latitude'], point['longitude']
        pointList.push latlng
        @.addPoint(latlng, point['name'], point['id'], point['path'], infoWindow)
      @.zoomToFit pointList

  addPoint: (latlng, name, point, link, infoWindow) ->
    marker = new google.maps.Marker
      position: latlng
      map: @map
      title: name

    $("#point_#{point}").data('marker', marker)

    if link != undefined
      google.maps.event.addListener marker, 'click', =>
        @.showInfoWindow(@map, marker, infoWindow, link)

    marker

  showInfoWindow: (map, marker, infoWindow, path) ->
    $.get path, (data) =>
      id = "cloudchart_#{data.id}"

      content =
        '<div class="pointinfo">' +
        "<div id='#{id}' class='cloudchart'></div>" +
        '</div>'

      infoWindow.setContent(content)
      infoWindow.open(map,marker)

      google.maps.event.addListener infoWindow, 'domready', ->
        chart = new Chart("##{id}", data)
        chart.processPoint()



  zoomToFit: (latlngs) ->
    bounds = new google.maps.LatLngBounds()

    bounds.extend latlng for latlng in latlngs

    @map.fitBounds bounds

  zoomToFitCenter: ->
    @.zoomToFit [@point]


readyCallback = ->
  map = new Map($('#map').get(0), 60, 10)
  map.populate($('#map').data('points'))

$(document).ready(readyCallback)
$(document).on('page:load', readyCallback)