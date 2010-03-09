#
# rb_main.rb
# Gowalla
#
# Created by Ruben Fonseca on 3/6/10.
# Copyright __MyCompanyName__ 2010. All rights reserved.
#

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'

Dir.glob(File.expand_path('../Gems/*', __FILE__)).each do |gem|
  $LOAD_PATH.unshift File.join(gem, 'lib')
end

# Loading all the Ruby project files.
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
  if path != main && path !~ /clash|dash/
    require(path)
  end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
