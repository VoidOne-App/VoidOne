#include "TranslationManager.h"

TranslationManager::TranslationManager(QObject *parent) : QObject(parent) {
    initDictionary();
}

void TranslationManager::setCurrentLanguage(const QString &lang) {
    if (m_currentLanguage != lang && (lang == "en" || lang == "fa")) {
        m_currentLanguage = lang;
        emit languageChanged();
    }
}

void TranslationManager::initDictionary() {
    // English
    m_dictionary["en"]["app_title"] = "Neon Launcher Pro";
    m_dictionary["en"]["launch"] = "Play Game";
    m_dictionary["en"]["scan_steam"] = "Scan Steam Library";
    m_dictionary["en"]["auto_save"] = "Real-Time Cloud Backup";
    m_dictionary["en"]["settings"] = "Settings";

    // Persian
    m_dictionary["fa"]["app_title"] = "لانچر نئون پرو";
    m_dictionary["fa"]["launch"] = "اجرای بازی";
    m_dictionary["fa"]["scan_steam"] = "اسکن کتابخانه استیم";
    m_dictionary["fa"]["auto_save"] = "پشتیبان‌گیری ابری خودکار";
    m_dictionary["fa"]["settings"] = "تنظیمات";
}

QString TranslationManager::getText(const QString &key) const {
    if (m_dictionary.contains(m_currentLanguage) && m_dictionary[m_currentLanguage].contains(key)) {
        return m_dictionary[m_currentLanguage][key];
    }
    return key;
}
