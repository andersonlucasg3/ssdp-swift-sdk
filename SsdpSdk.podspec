Pod::Spec.new do |s|
  s.name             = 'SsdpSdk'
  s.version          = '0.1.0'
  s.summary          = 'SSDP for iOS & tvOS.'


  s.description      = <<-DESC
Simple implementation of advertising and device discovery over SSDP.
                       DESC

  s.homepage         = 'https://github.com/andersonlucasg3/ssdp-swift-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anderson Lucas C. Ramos' => 'andersonlucasg3@hotmail.com' }
  s.source           = { :git => 'https://github.com/andersonlucasg3/ssdp-swift-sdk.git', :tag => s.version.to_s }

  s.swift_version    = '5'
  s.requires_arc     = true

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '11.0'

  s.source_files     = 'Sources/SSDP/**/*.{swift,h}',
                       'Sources/Socket/**/*.{m,h}'

  s.dependency       'BlueSocket'
end
