/****************************************************************************
**  V O I D O N E   E N G I N E
**  Copyright (C) 2026 VoidOne-App | SPDX-License-Identifier: MIT
****************************************************************************/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

Window {
    id: root

    width: 1280
    height: 720
    minimumWidth: 960
    minimumHeight: 540
    visible: true

    title: "VoidOne Engine"
    color: "#0a0d12"

    // این متغیر صفحه فعلی را مدیریت می‌کند. سایدبار هم وضعیت کلیدها را از این می‌خواند.
    property string currentPage: "library"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ۱. اتصال سایدبار در سمت چپ
        Sidebar {
            id: sidebar
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            
            // دریافت سیگنال از سایدبار برای تغییر صفحه
            onPageChanged: function(page) {
                root.currentPage = page
                
                if (page === "library") contentStack.currentIndex = 0
                else if (page === "marketplace") contentStack.currentIndex = 1
                else if (page === "settings") contentStack.currentIndex = 2
            }
        }

        // خط جداکننده نئونی بین سایدبار و محتوا
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: "#00ffee20"
        }

        // ۲. بخش محتوای اصلی (سمت راست)
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0 // پیش‌فرض روی کتابخانه است

            // صفحه ۰: کتابخانه بازی‌ها (Library)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    anchors.fill: parent
                    anchors.margins: 20
                    cellWidth: 300
                    cellHeight: 210
                    clip: true
                    
                    // اتصال به بک‌اند ++C برای دریافت لیست بازی‌ها
                    model: gameModel 
                    
                    // لود کردن کارت بازی به ازای هر رکورد در دیتابیس
                    delegate: GameCard {
                        gameId: model.id || 0
                        gameName: model.name || "Unknown Game"
                        exePath: model.exePath || ""
                        iconPath: model.iconPath || ""
                        platform: model.platform || "Custom"
                        itemIndex: index
                    }
                    
                    // پیام راهنما در صورت خالی بودن دیتابیس
                    Text {
                        anchors.centerIn: parent
                        text: trManager.currentLanguage === "fa" 
                            ? "هیچ بازی‌ای در کتابخانه یافت نشد.\n\nاز طریق اسکنر استیم یا تنظیمات بازی اضافه کنید." 
                            : "No games found in the library.\n\nAdd games via Steam Scanner or settings."
                        color: "#00ffee80"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        visible: parent.count === 0
                    }
                }
            }

            // صفحه ۱: فروشگاه (Marketplace)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                Text {
                    anchors.centerIn: parent
                    text: trManager.currentLanguage === "fa" 
                        ? "🛒 بخش فروشگاه در حال ساخت است..." 
                        : "🛒 Marketplace is under construction..."
                    color: "#00ffee80"
                    font.pixelSize: 22
                }
            }

            // صفحه ۲: تنظیمات و بکاپ (Settings)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // لود کردن کامپوننت بکاپی که ساختی در مرکز صفحه
                SaveBackupView {
                    anchors.centerIn: parent
                }
            }
        }
    }
}
