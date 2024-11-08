import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations


    property int gridSize: 15 // Grid dimensions, e.g., 10x10
    property int numMines: 25 // Number of mines

    property bool controlMode: true // tap to reveal vs. tap to flag
    property bool mineHints: false // do we give "hints" when the right number of flags are there?

}

