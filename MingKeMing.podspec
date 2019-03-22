Pod::Spec.new do |s|
    s.name             = "MingKeMing"
    s.version          = "0.0.2"
    s.summary          = "The account module for DIM."
    s.homepage         = "https://github.com/Ceezy/mkm-objc"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { "Ceezy Chen" => "ceezychen@gmail.com" }
    s.source           = { :git => "https://github.com/Ceezy/mkm-objc.git", :tag => s.version }
#    s.social_media_url = ''

    s.platform     = :ios, '11.0'

    s.public_header_files = 'Classes/*.h'
    s.source_files = 'Classes/*.{h,m}'

    s.frameworks = 'Security'
    s.libraries = 'c++'

    s.subspec 'bitcoin' do |ss|
        ss.source_files = 'Classes/bitcoin/src/*.{h,cpp}', 'Classes/bitcoin/src/**/*.{h,cpp}'
        ss.public_header_files = 'Classes/bitcoin/src/*.h', 'Classes/bitcoin/src/**/*.h'
    end

    s.subspec 'extends' do |ss|
        ss.source_files = 'Classes/extends/*.{h,m,mm}'
        ss.public_header_files = 'Classes/extends/*.h'
	ss.dependency 'MingKeMing/bitcoin'
    end

    s.subspec 'types' do |ss|
        ss.source_files = 'Classes/types/*.{h,m}'
        ss.public_header_files = 'Classes/types/*.h'
	ss.dependency 'MingKeMing/extends'
    end

    s.subspec 'crypto' do |ss|
        ss.source_files = 'Classes/crypto/*.{h,m}'
        ss.public_header_files = 'Classes/crypto/*.h'
	ss.dependency 'MingKeMing/extends'
	ss.dependency 'MingKeMing/types'
    end

    s.subspec 'entity' do |ss|
        ss.source_files = 'Classes/entity/*.{h,m}'
        ss.public_header_files = 'Classes/entity/*.h'
	ss.dependency 'MingKeMing/extends'
	ss.dependency 'MingKeMing/types'
	ss.dependency 'MingKeMing/crypto'
    end

    s.subspec 'group' do |ss|
        ss.source_files = 'Classes/group/*.{h,m}'
        ss.public_header_files = 'Classes/group/*.h'
	ss.dependency 'MingKeMing/crypto'
	ss.dependency 'MingKeMing/entity'
    end
end
