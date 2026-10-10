#include "TranslationManager.h"

#include <QSettings>

TranslationManager::TranslationManager(QObject *parent) : QObject(parent) {
    initDictionary();

    QSettings settings;
    const QString savedLanguage = settings.value(QStringLiteral("ui/backupLanguage"), QStringLiteral("en")).toString();
    if (savedLanguage == QStringLiteral("fa"))
        m_currentLanguage = savedLanguage;
}

void TranslationManager::setCurrentLanguage(const QString &lang) {
    if (m_currentLanguage != lang && (lang == "en" || lang == "fa")) {
        m_currentLanguage = lang;
        QSettings settings;
        settings.setValue(QStringLiteral("ui/backupLanguage"), m_currentLanguage);
        emit languageChanged();
    }
}

void TranslationManager::initDictionary() {
    // English
    m_dictionary["en"]["app_title"] = "VoidOne";
    m_dictionary["en"]["launch"] = "Play Game";
    m_dictionary["en"]["scan_steam"] = "Scan Steam Library";
    m_dictionary["en"]["auto_save"] = "Automatic Backup";
    m_dictionary["en"]["settings"] = "Settings";

    // Persian
    m_dictionary["fa"]["app_title"] = "VoidOne";
    m_dictionary["fa"]["launch"] = "اجرای بازی";
    m_dictionary["fa"]["scan_steam"] = "اسکن کتابخانه استیم";
    m_dictionary["fa"]["auto_save"] = "پشتیبان‌گیری خودکار";
    m_dictionary["fa"]["settings"] = "تنظیمات";
}

QString TranslationManager::getText(const QString &key) const {
    if (m_dictionary.contains(m_currentLanguage) && m_dictionary[m_currentLanguage].contains(key)) {
        return m_dictionary[m_currentLanguage][key];
    }
    return key;
}
