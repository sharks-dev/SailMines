import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Column {
        anchors.centerIn: parent
        Label {
            id: label
            text: "SailMines"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            text: "Field: " + gridSize + "x" + gridSize + " 🏳"
            color: palette.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            text: "Mines: " + numMines + " 💣"
            color: palette.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
