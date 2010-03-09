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
  end
  
  def applicationWillTerminate(notification)
    @locationManager.stopUpdatingLocation
  end
  
  # Credentials delegate
  def submitCredentials(sender)
	self.progressView.startAnimation(self)
	
	@locationManager = CLLocationManager.alloc.init
	@locationManager.delegate = self
	@locationManager.startUpdatingLocation
	
	loadMap
	
	@client = Gowalla.new(username_field.stringValue, password_field.stringValue)
	@webView.windowScriptObject.setValue(self, forKey:"gowalladelegate")
	
	NSApp.endSheet(credentials_window)
	credentials_window.orderOut(sender)
  end
  
  def hideCredentials(sender)
	NSApp.endSheet(credentials_window)
	credentials_window.orderOut(sender)
  end
  
  # Webscript Callable methods
  def searchAddress(northeast, southwest)
	@client.list_spots(:sw => southwest, :ne => northeast) do |response|
		showSpots(response)
	end
  end
  
  def geocodeAddress(sender)
	self.webView.stringByEvaluatingJavaScriptFromString("geocode(\"#{sender.stringValue}\");")
  end
  
  def updateMap(latitude, longitude)
	@client.list_spots(:lat => latitude, :lng => longitude) do |response|
		showSpots(response)
	end
  end
  
  def checkin(spot_id, lat, lng)
	@client.checkin(:spot_id => spot_id, :lat => lat, :lng => lng) do |response|
	  self.webView.mainFrame.loadHTMLString(response.bonus_html, baseURL:nil)
	  puts "Success :)"
	end
  end
     
  # WebScript informal protocol
  def self.isSelectorExcludedFromWebScript(selector)
	puts "excluded? #{selector}"
	false
  end
  
  def self.isKeyExcludedFromWebScript(name)
    puts "key? #{name}"
	false
  end
  
  # Location delegate
  def locationManager(manager, didUpdateToLocation:newLocation, fromLocation:oldLocation)
	self.progressView.stopAnimation(self)
  end
  
  def locationManager(manager, didFailWithError:error)
	puts error.localizedDescription
	self.progressView.stopAnimation(self)
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
end

