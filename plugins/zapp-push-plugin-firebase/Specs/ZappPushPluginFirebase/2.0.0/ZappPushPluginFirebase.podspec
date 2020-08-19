Pod::Spec.new do |s|
    s.name             = 'ZappPushPluginFirebase'
    s.version          = '2.0.0'
    s.summary          = 'FirebasePushPlugin for Zapp iOS.'
    s.description      = <<-DESC
                          FirebasePushPlugin for Zapp iOS.
                          DESC
    s.homepage         = 'https://github.com/applicaster/zapp-push-plugin-firebase.git'
    s.license          = 'CMPS'
    s.author           = { 'Egor Brel' => 'brel@scand.com' }
    s.source           = { :git => 'https://github.com/applicaster/zapp-push-plugin-firebase.git', :tag => s.version.to_s }
    s.platform     = :ios, '10.0'
    s.requires_arc = true
    s.swift_version = '5.1'
    s.source_files = 'iOS/ZappPushPluginFirebase/**/*.{swift}'
    s.default_subspec = 'Base'
    s.static_framework = true

    s.subspec 'Base' do |base|
      base.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
          'FRAMEWORK_SEARCH_PATHS' => '$(inherited)',
          'OTHER_LDFLAGS' => '$(inherited)',
          'ENABLE_BITCODE' => 'YES',
          'OTHER_CFLAGS'  => '-fembed-bitcode'
      }

      base.dependency 'ZappPushPluginsSDK'
      base.dependency 'ZappPlugins'
      base.dependency 'Firebase/Messaging'
      base.dependency 'Firebase/Core'
    end

    s.subspec 'NotificationServiceExtension' do |service_extension|
      service_extension.xcconfig = {
          'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
          'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) FIREBASE_EXTENSIONS_ENABLED=1',
          'OTHER_SWIFT_FLAGS' => '$(inherited) "-D" "FIREBASE_EXTENSIONS_ENABLED"',
          'ENABLE_BITCODE' => 'YES',
          'OTHER_CFLAGS'  => '-fembed-bitcode'
      }
      service_extension.dependency 'Firebase'
      service_extension.dependency 'Firebase/Messaging'

    end
end
