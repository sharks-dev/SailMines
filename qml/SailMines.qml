import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "pages"

ApplicationWindow {
    Item {
        ConfigurationValue {
            id: gridSize
            key: "/apps/sailmines/settings/gridsize"
            defaultValue: 15
        }
        ConfigurationValue {
            id: numMines
            key: "/apps/sailmines/settings/numMines"
            defaultValue: 25
        }
        ConfigurationValue {
            id: controlMode
            key: "/apps/sailmines/settings/controlMode"
            defaultValue: true
        }
        ConfigurationValue {
            id: mineHints
            key: "/apps/sailmines/settings/mineHints"
            defaultValue: false
        }
    }

    initialPage: Component { MinefieldPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}

