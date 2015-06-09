Pod::Spec.new do |s|

  s.name         = "AppPeerIOS-smorel"
  s.version      = "1.0.0"
  s.summary      = "Synchronize your application resources from dropbox to the app and experience dynamic reload on simulator and devices."
  s.homepage     = "https://github.com/smorel/AppPeer"
  s.license      = { :type => 'Apache Licence 2.0', :file => 'LICENSE.txt' }
  s.author       = { 'Sebastien Morel' => 'morel.sebastien@gmail.com' }
  s.source       = { :git => 'https://github.com/smorel/AppPeer.git', :tag => 'v1.0.0' }
  s.platform     = :ios, '7.0'

  s.description = 'AppPeer is a multipeer connection framework that works both on iOS and Mac. It allows to detect, connect and brodcast data to peers that are on the same network.'

  s.default_subspec = 'All'

  s.frameworks =  'Security', 'QuartzCore'

  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2', 'OTHER_LDFLAGS' => '-ObjC -all_load -weak_library /usr/lib/libstdc++.dylib' } 

  s.dependency 'CocoaAsyncSocket'

  s.requires_arc = true

  s.subspec 'All' do |al|    
    al.source_files = 'AppPeer/AppPeer/*.{h,m,mm}'
    al.private_header_files = 'AppPeer/AppPeer/**/*.{h}'
  end

end
