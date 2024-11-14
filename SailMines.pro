# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = SailMines

CONFIG += sailfishapp

SOURCES += src/SailMines.cpp

DISTFILES += qml/SailMines.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MinefieldPage.qml \
    qml/pages/SettingsPage.qml \
    rpm/SailMines.changes \
    rpm/SailMines.spec \
    translations/*.ts \
    SailMines.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172
