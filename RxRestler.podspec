Pod::Spec.new do |spec|
spec.name         = 'RxRestler'
spec.version      = '0.0.0.1'
spec.license      = { :type => 'MIT', :file => 'LICENSE.md'}
spec.homepage     = 'https://github.com/VladimirBorodko/RxRestler'
spec.authors      = { 'Vladimir Borodko' => 'vladimirborodko@gmail.com' }
spec.summary      = 'Rx REST api client'
spec.source       = { :path => 'Sources/' }
spec.module_name  = 'RxRestler'
spec.platform     = :ios, :tvos, :macos, :watchos
spec.ios.deployment_target  = '10.0'
spec.source_files       = 'Sources'
spec.framework      = 'SystemConfiguration'
spec.dependency   'RxSwift', '~> 4.0'
spec.dependency   'Alamofire', '~> 4.8'
end
