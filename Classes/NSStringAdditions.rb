# NSStringAdditions.rb
# Gowalla
#
# Created by Ruben Fonseca on 3/10/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

class String
  JS_ESCAPE_MAP = {
    '\\'    => '\\\\',
    '</'    => '<\/',
    "\r\n"  => '\n',
    "\n"    => '\n',
    "\r"    => '\n',
    '"'     => '\\"',
    "'"     => "\\'" }

  # Escape carrier returns and single and double quotes for JavaScript segments.
  def escape_javascript
    self.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
  end
end
