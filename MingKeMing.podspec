Pod::Spec.new do |s|
    s.name             = "MingKeMing"
    s.version          = "0.0.1"
    s.summary          = "The account module for DIM."
    s.homepage         = "https://github.com/Ceezy/dkd-objc"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { "Ceezy Chen" => "ceezychen@gmail.com" }
    s.source           = { :git => "https://github.com/Ceezy/mkm-objc.git", :tag => s.version }
#    s.social_media_url = ''

    s.platform     = :ios, '11.0'

    s.public_header_files = 'Classes/*.h', 'Classes/**/*.h'
    s.private_header_files = 'Classes/bitcoin/src/*.h', 'Classes/bitcoin/src/**/*.h'
    s.source_files = 'Classes/*.{h,m}', 'Classes/**/*.{h,m}'

    s.frameworks = 'Security'
end
