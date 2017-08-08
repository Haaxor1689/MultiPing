Pod::Spec.new do |s|
	s.name        = "MultiPing"
	s.platform    = :ios, "8.0"
	s.version     = "0.0.1"
	s.summary     = "Simple pod for sending multiple ping requests at once."

	s.description = <<-DESC
			Simple pod for sending multiple ping requests at once.
			DESC

	s.license = { :type => "MIT", :file => "LICENSE" }
	s.author = { "Maroš Beťko" => "betkomaros@gmail.com" }
	s.social_media_url = "http://twitter.com/Haaxor1689"

	s.source   = { :git => "https://github.com/Haaxor1689/MultiPing.git", :tag => "#{s.version}" }
	s.homepage = "https://github.com/Haaxor1689/MultiPing.git"

	s.source_files        = "MultiPing/**/*.{h,m,swift}"
	s.public_header_files = "MultiPing/**/*.h"

	s.requires_arc = true
end
