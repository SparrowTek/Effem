//
//  ThemeSettingsView.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import SwiftUI

struct ThemeSettingsView: View {
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.colorScheme) private var colorSchemeString: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.self) var environment
    @State private var selectedColorScheme = 0
    @State private var lightModeColor: Color = .accentColor
    @State private var darkModeColor: Color = .accentColor
    
    var body: some View {
        Form {
            Section("color scheme") {
                Picker("Selected Color Scheme", selection: $selectedColorScheme) {
                    Text("system").tag(0)
                    Text("light").tag(1)
                    Text("dark").tag(2)
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                ColorPicker("light mode tint", selection: $lightModeColor)
                ColorPicker("dark mode tint", selection: $darkModeColor)
            }
        }
        .onAppear(perform: setSelectedColorScheme)
        .onAppear(perform: setTintColors)
        .onChange(of: selectedColorScheme, updateColorScheme)
        .onChange(of: lightModeColor, saveLightThemeColor)
        .onChange(of: darkModeColor, saveDarkThemeColor)
    }
    
    private func saveLightThemeColor() {
        let resolvedColor = lightModeColor.resolve(in: environment)
        
        guard let colorData = try? JSONEncoder().encode(resolvedColor) else { return }
        lightThemeColor = String(decoding: colorData, as: UTF8.self)
    }
    
    private func saveDarkThemeColor() {
        let resolvedColor = darkModeColor.resolve(in: environment)
        
        guard let colorData = try? JSONEncoder().encode(resolvedColor) else { return }
        darkThemeColor = String(decoding: colorData, as: UTF8.self)
    }
    
    private func setSelectedColorScheme() {
        switch colorSchemeString {
        case Build.Constants.Theme.light: selectedColorScheme = 1
        case Build.Constants.Theme.dark: selectedColorScheme = 2
        default: selectedColorScheme = 0
        }
    }
    
    private func setTintColors() {
        setLightThemeColor()
        setDarkThemeColor()
    }
    
    private func setLightThemeColor() {
        guard let lightThemeColor,
              let colorData = lightThemeColor.data(using: .utf8),
              let colorResolved = try? JSONDecoder().decode(Color.Resolved.self, from: colorData) else { return }
        lightModeColor = Color(colorResolved)
    }
    
    private func setDarkThemeColor() {
        guard let darkThemeColor,
              let colorData = darkThemeColor.data(using: .utf8),
              let colorResolved = try? JSONDecoder().decode(Color.Resolved.self, from: colorData) else { return }
        darkModeColor = Color(colorResolved)
    }
    
    private func updateColorScheme() {
        switch selectedColorScheme {
        case 1: colorSchemeString = Build.Constants.Theme.light
        case 2: colorSchemeString = Build.Constants.Theme.dark
        default: colorSchemeString = nil
        }
    }
}

#Preview {
    ThemeSettingsView()
}