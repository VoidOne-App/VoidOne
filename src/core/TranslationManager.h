#ifndef TRANSLATIONMANAGER_H
#define TRANSLATIONMANAGER_H

#include <QObject>
#include <QString>
#include <QMap>

class TranslationManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY languageChanged)

public:
    explicit TranslationManager(QObject *parent = nullptr);

    QString currentLanguage() const { return m_currentLanguage; }
    void setCurrentLanguage(const QString &lang);

    Q_INVOKABLE QString getText(const QString &key) const;

signals:
    void languageChanged();

private:
    QString m_currentLanguage = "en";
    QMap<QString, QMap<QString, QString>> m_dictionary;
    void initDictionary();
};

#endif // TRANSLATIONMANAGER_H
