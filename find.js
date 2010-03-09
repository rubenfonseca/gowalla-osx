function add_marker(latlng, content, imageurl) {
  var image = new google.maps.MarkerImage(imageurl, null, null, null, new google.maps.Size(32, 32));
  
  var marker = new google.maps.Marker({
    map: map,
    position: latlng,
    icon: image
  });
  marker.setFlat(false);
  
  google.maps.event.addListener(marker, 'click', function() {
    infoWindow.setContent(content);
    infoWindow.open(map, marker);
  });
}

map.clearMarkers();

<% spots.each do |spot| %>
  latlng = new google.maps.LatLng(<%= spot.lat.doubleValue %>, <%= spot.lng.doubleValue %>);
  content = "<a href=\"javascript:window.gowalladelegate.checkin_(<%= spot.url.gsub(%r{/spots/}, '') %>, <%= spot.lat.doubleValue %>, <%= spot.lng.doubleValue %>);\"><%= spot.name %></a>";
  imageurl = "<%= spot.image_url %>";
  
  add_marker(latlng, content, imageurl);
<% end %>
