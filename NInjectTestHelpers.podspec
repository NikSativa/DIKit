Pod::Spec.new do |spec|
  spec.name         = "NInjectTestHelpers"
  spec.version      = "1.7.3"
  spec.summary      = "DI extension"

  spec.source       = { :git => "git@github.com:NikSativa/NInject.git" }
  spec.homepage     = "https://github.com/NikSativa/NInject"

  spec.license          = 'MIT'
  spec.author           = { "Nikita Konopelko" => "nik.sativa@gmail.com" }
  spec.social_media_url = "https://www.facebook.com/Nik.Sativa"

  spec.ios.deployment_target = '11.0'
  spec.swift_version = '5.5'

  spec.resources = ['TestHelpers/**/*.{storyboard,xib,xcassets,json,imageset,png,strings,stringsdict}']
  spec.source_files = 'TestHelpers/**/*.swift'

  spec.dependency 'NSpry'
  spec.dependency 'NInject'

  spec.frameworks = 'XCTest', 'Foundation', 'UIKit'

  spec.test_spec 'Tests' do |tests|
    #      tests.requires_app_host = false

    tests.dependency 'Quick'
    tests.dependency 'Nimble'
    tests.dependency 'NSpry_Nimble'

    tests.source_files = 'Tests/**/*.swift'
    tests.resources = ['Tests/**/*.{storyboard,xib,xcassets,json,imageset,png,strings,stringsdict}']
    tests.exclude_files = '**/SPM/**/*.*'
  end
end
