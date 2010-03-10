# CheckinResultView.rb
# Gowalla
#
# Created by Ruben Fonseca on 3/10/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

class CheckinResultView
  attr_accessor :window, :web_view, :ok_button

  def initialize
    if(!NSBundle.loadNibNamed("CheckinResult", owner:self))
      NSLog("Error loading Nib for document")
      return nil
    end
  end

  def showCheckin(main_window, result)
    web_view.mainFrame.loadHTMLString(result.bonus_html, baseURL:nil)
    NSApp.beginSheet(window, modalForWindow:main_window, modalDelegate:nil, didEndSelector:nil, contextInfo:nil)
  end

  def ok_pressed(sender)
    NSApp.endSheet(window)
    window.orderOut(sender)
    window.close
  end
end