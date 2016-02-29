platform :ios, '8.1'
use_frameworks!

target 'RUapp' do
    
    pod 'Alamofire'
    pod 'Crashlytics'
    pod 'Fabric'
    pod 'GoogleAnalytics'
    pod 'iRate'
    
end

target 'RUappService' do
    
    pod 'Alamofire'
    
end

pre_install do | installer |
    # Remove unused translations
    supported_locales = ['base', 'en', 'pt']
    Dir.glob(File.join('Pods', '**', '*.lproj')).each do |bundle|
        if (!supported_locales.include?(File.basename(bundle, ".lproj").downcase))
            puts "Removing #{bundle}"
            FileUtils.rm_rf(bundle)
        end
    end
end

post_install do | installer |
    # Acknowledgements
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-RUapp/Pods-RUapp-acknowledgements.plist', 'RUapp/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end