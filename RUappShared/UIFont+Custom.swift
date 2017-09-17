//
//  UIFont+Custom.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 16/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

#if os(macOS)
    public typealias Font = NSFont
#else
    public typealias Font = UIFont
#endif

public extension Font {
    
    static var appBarItem: UIFont {
        return Font(name: "Dosis-SemiBold", size: 18)!
    }
    
    static var appBarItemDone: UIFont {
        return Font(name: "Dosis-Bold", size: 18)!
    }
    
    static var appLargeNavTitle: UIFont {
        return Font(name: "Dosis-Bold", size: 34)!
    }
    
    static var appNavTitle: UIFont {
        return Font(name: "Dosis-SemiBold", size: 20)!
    }
    
    static var appTableSectionHeader: UIFont {
        return Font(name: "Dosis-Book", size: 16)!
    }
    
    static func appRegisterFonts() {
        let bundle = Bundle(for: Student.self)
        try? ["Dosis-Light", "Dosis-Medium", "Dosis-ExtraLight", "Dosis-ExtraBold", "Dosis-SemiBold", "Dosis-Bold", "Dosis-Book"].forEach {
            guard let url = bundle.url(forResource: $0, withExtension: "otf") else { throw FontError.resourceDoesntExist }
            let data = try Data(contentsOf: url)
            guard let provider = CGDataProvider(data: data as CFData) else { throw FontError.providerCreationFailed }
            guard let font = CGFont(provider) else { throw FontError.fontCreationFailed }
            guard CTFontManagerRegisterGraphicsFont(font, nil) else { throw FontError.registerFailed }
        }
    }
}

public enum FontError: Error {
    case resourceDoesntExist
    case providerCreationFailed
    case fontCreationFailed
    case registerFailed
}
