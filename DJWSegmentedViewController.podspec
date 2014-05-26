Pod::Spec.new do |s|
  s.name         = "DJWSegmentedViewController"
  s.version      = "0.0.1"
  s.summary      = "A segmentedControl based container view controller that manages the display of a group of view controllers."

  s.description  = <<-DESC
                  A segmentedControl based container view controller than manages the display of a group of view controllers.
                  Simply create an instance of this class, set its dataSource property, and implement the required methods.
                  Users can swap view controllers by using the in-built segmentedControl.
                  This class mimics the behavior of Apple's App Store app, in the Top Charts tab.
                   DESC

  s.homepage     = "http://github.com/danwilliams64/DJWSegmentedViewController"
  s.screenshots  = "https://raw.githubusercontent.com/danwilliams64/DJWSegmentedViewController/master/Screenshots/DJWSegmentedViewControllerDemo1.gif"
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Dan Williams" => "dan@danwilliams.co" }
  s.social_media_url   = "http://twitter.com/danielwilliams"

  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/danwilliams64/DJWSegmentedViewController.git", :tag => "0.0.1" }


  s.source_files  = "DJWSegmentedViewController"
  s.requires_arc = true
end
