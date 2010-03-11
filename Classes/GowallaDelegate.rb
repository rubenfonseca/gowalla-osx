# GowallaDelegator.rb
# Gowalla
#
# Created by Ruben Fonseca on 3/6/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

framework 'CoreLocation'

require 'erb'

class GowallaDelegate
  attr_accessor :webView, :searchField, :progressView

  attr_accessor :main_window, :credentials_window, :username_field, :password_field

  def applicationDidFinishLaunching(notification)
    NSApp.beginSheet(credentials_window, modalForWindow:main_window, modalDelegate:nil, didEndSelector:nil, contextInfo:nil)

    # warm up cache, need for WebScriptObject to find my methods
    self.respondsToSelector("updateMap:")
    self.respondsToSelector("searchAddress:")
    self.respondsToSelector("checkin:")
    self.respondsToSelector("startLocating:")
  end

  def applicationWillTerminate(notification)
    stopUpdatingLocation
  end

  # Credentials delegate
  def submitCredentials(sender)
    self.progressView.startAnimation(self)

    loadMap

    @client = Gowalla.new(username_field.stringValue, password_field.stringValue)
    @webView.windowScriptObject.setValue(self, forKey:"gowalladelegate")

    NSApp.endSheet(credentials_window)
    credentials_window.orderOut(sender)
  end

  def hideCredentials(sender)
    NSApp.endSheet(credentials_window)
    credentials_window.orderOut(sender)
    NSApp.terminate(sender)
  end

  # Webscript Callable methods
  def searchAddress(northeast, southwest)
    progressView.startAnimation(self)
    @client.list_spots(:sw => southwest, :ne => northeast) do |response|
      showSpots(response)
      progressView.stopAnimation(self) unless @locationManager
    end
  end

  def geocodeAddress(sender)
    stopUpdatingLocation

    progressView.startAnimation(self)
    self.webView.stringByEvaluatingJavaScriptFromString("geocode(\"#{sender.stringValue}\");")
  end

  def updateMap(latitude, longitude)
    @client.list_spots(:lat => latitude, :lng => longitude) do |response|
      showSpots(response)
      progressView.stopAnimation(self)
    end
  end

  def checkin(spot_id, lat, lng)
    progressView.startAnimation(self)
    @client.checkin(:spot_id => spot_id, :lat => lat, :lng => lng) do |response|
      CheckinResultView.new.showCheckin(main_window, response)
      progressView.stopAnimation(self)
      NSLog("Success :)")
    end
  end

  def startLocating(sender)
    @locationManager = CLLocationManager.alloc.init
    @locationManager.delegate = self
    @locationManager.startUpdatingLocation
  end

  # WebScript informal protocol
  def self.isSelectorExcludedFromWebScript(selector)
    false
  end

  # Location delegate
  def locationManager(manager, didUpdateToLocation:newLocation, fromLocation:oldLocation)  
    self.webView.stringByEvaluatingJavaScriptFromString("map.panTo(new google.maps.LatLng(#{newLocation.betterCoordinates['latitude'].doubleValue}, #{newLocation.betterCoordinates['longitude'].doubleValue}));")
    updateMap(newLocation.betterCoordinates['latitude'].doubleValue, newLocation.betterCoordinates['longitude'].doubleValue)
    self.progressView.stopAnimation(self)
    self.searchField.cell.setPlaceholderString("")

    stopUpdatingLocation
  end

  def locationManager(manager, didFailWithError:error)
    NSLog(error.localizedDescription)
    self.progressView.stopAnimation(self)
    self.searchField.cell.setPlaceholderString("Couldn't find your location")

    stopUpdatingLocation
  end

  private
  def loadMap
    template = NSString.stringWithContentsOfFile(NSBundle.mainBundle.pathForResource("index", ofType:"html"),
    encoding: NSUTF8StringEncoding,
    error: nil)

    html = ERB.new(template)
    self.webView.mainFrame.loadHTMLString(html.result(binding), baseURL:nil)
  end

  def showSpots(spots)
    template = NSString.stringWithContentsOfFile(NSBundle.mainBundle.pathForResource("find", ofType:"js"),
    encoding: NSUTF8StringEncoding,
    error:nil)

    js = ERB.new(template).result(binding)
    self.webView.stringByEvaluatingJavaScriptFromString(js)
  end

  def stopUpdatingLocation
    if @locationManager
      @locationManager.stopUpdatingLocation
      @locationManager = nil
    end
  end
end

