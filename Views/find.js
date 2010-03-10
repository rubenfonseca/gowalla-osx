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
  content = "<%= spot.name.escape_javascript %> <a href=\"javascript:window.gowalladelegate.checkin_(<%= spot.url.gsub(%r{/spots/}, '').escape_javascript %>, <%= spot.lat.doubleValue %>, <%= spot.lng.doubleValue %>);\">(check in)</a>";
  imageurl = "<%= spot.image_url.escape_javascript %>";
  
  add_marker(latlng, content, imageurl);
<% end %>
