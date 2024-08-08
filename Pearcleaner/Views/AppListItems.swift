//
//  AppListDetails.swift
//  Pearcleaner
//
//  Created by Alin Lupascu on 11/10/23.
//

import Foundation
import SwiftUI
import AlinFoundation

struct AppListItems: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var search: String
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("displayMode") var displayMode: DisplayMode = .system
    @AppStorage("settings.general.miniview") private var miniView: Bool = true
    @AppStorage("settings.general.mini") private var mini: Bool = false
    @AppStorage("settings.general.glass") private var glass: Bool = true
    @AppStorage("settings.menubar.enabled") private var menubarEnabled: Bool = false
    @AppStorage("settings.interface.animationEnabled") private var animationEnabled: Bool = true
    @AppStorage("settings.interface.minimalist") private var minimalEnabled: Bool = true
    @Binding var showPopover: Bool
    @EnvironmentObject var locations: Locations
    let itemId = UUID()
    let appInfo: AppInfo
    var isSelected: Bool { appState.appInfo.path == appInfo.path }
    @State private var hoveredItemPath: URL? = nil
    @State private var bundleSize: Int64 = 0

    var body: some View {

        VStack() {

            HStack(alignment: .center) {

                if let appIcon = appInfo.appIcon {
                    ZStack {
                        Image(nsImage: appIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                }

                if minimalEnabled {
                    Text(appInfo.appName)
                        .font(.system(size: (isSelected) ? 14 : 12))
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    VStack(alignment: .center, spacing: 2) {
                        HStack {
                            Text(appInfo.appName)
                                .font(.system(size: (isSelected) ? 14 : 12))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                        }

                        HStack(spacing: 5) {
                            Text("v\(appInfo.appVersion)")
                                .font(.footnote)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .opacity(0.5)
                            Text("•").font(.footnote).opacity(0.5)

                            Text(bundleSize == 0 ? "calculating" : "\(formatByte(size: bundleSize).human)")
                                .font(.footnote)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .opacity(0.5)
                            Spacer()
                        }

                    }
                }


                Spacer()

                if appInfo.webApp {
                    Text("web")
                        .font(.footnote)
                        .foregroundStyle(.primary.opacity(0.3))
                        .frame(minWidth: 30, minHeight: 15)
                        .padding(2)
                        .background(
                            Capsule().strokeBorder(.primary.opacity(0.3), lineWidth: 1)
                        )
                }
                if appInfo.wrapped {
                    Text("iOS")
                        .font(.footnote)
                        .foregroundStyle(.primary.opacity(0.3))
                        .frame(minWidth: 30, minHeight: 15)
                        .padding(2)
                        .background(
                            Capsule().strokeBorder(.primary.opacity(0.3), lineWidth: 1)
                        )
                }

                if minimalEnabled {
                    Text(bundleSize == 0 ? "v\(appInfo.appVersion)" : (isHovered ? "v\(appInfo.appVersion)" : formatByte(size: bundleSize).human))
                        .font(.system(size: (isHovered || isSelected) ? 12 : 10))
                        .foregroundStyle(.primary.opacity(0.5))
                }



            }

        }
        .frame(height: 35)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .help(appInfo.appName)
        .onHover { hovering in
            withAnimation(Animation.easeInOut(duration: animationEnabled ? 0.35 : 0)) {
                self.isHovered = hovering
                self.hoveredItemPath = isHovered ? appInfo.path : nil
            }
        }
        .onTapGesture {
            withAnimation(Animation.easeInOut(duration: animationEnabled ? 0.35 : 0)) {
                if isSelected {
                    appState.appInfo = .empty
                    appState.selectedItems = []
                    appState.currentView = miniView ? .apps : .empty
                    showPopover = false
                } else {
                    showAppInFiles(appInfo: appInfo, appState: appState, locations: locations, showPopover: $showPopover)
                }
            }
        }
        .background{
            Rectangle()
                .fill(isSelected && !glass ? themeManager.pickerColor : .clear)
        }
        .overlay{
            if (isHovered || isSelected) {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 50)
                        .fill(isSelected ? Color("AccentColor") : .primary.opacity(0.5))
                        .frame(width: isSelected ? 4 : 2, height: 25)
                        .padding(.trailing, 5)
                }

            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let size = totalSizeOnDisk(for: appInfo.path).logical
                DispatchQueue.main.async {
                    self.bundleSize = size

                    // Optionally, update the appInfo in the appState array
                    if let index = appState.sortedApps.firstIndex(where: { $0.path == appInfo.path }) {
                        appState.sortedApps[index].bundleSize = size
                    }
                }
            }
        }

    }

}
