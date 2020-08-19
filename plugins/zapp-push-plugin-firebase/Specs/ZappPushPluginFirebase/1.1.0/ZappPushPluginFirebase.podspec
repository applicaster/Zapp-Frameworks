Pod::Spec.new do |s|
    s.name             = 'ZappPushPluginFirebase'
    s.version          = '1.1.0'
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
    s.swift_version = '4.2'
    s.static_framework = true
    s.source_files = 'iOS/ZappPushPluginFirebase/**/*.{swift}'

    s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
        'FRAMEWORK_SEARCH_PATHS' => '$(inherited)',
        'OTHER_LDFLAGS' => '$(inherited)',
        'ENABLE_BITCODE' => 'YES',
        'SWIFT_VERSION' => '4.2',
        'OTHER_CFLAGS'  => '-fembed-bitcode'
    }

    s.dependency 'ZappPushPluginsSDK'
    s.dependency 'ZappPlugins'
    s.dependency 'Firebase/Messaging'
    s.dependency 'Firebase/Core'
    
end
