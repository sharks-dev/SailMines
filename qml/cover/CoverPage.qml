import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

CoverBackground {
    Column {
        anchors.centerIn: parent
        Label {
            id: label
            text: "SailMines"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            text: "Field: " + gridSize.value + "x" + gridSize.value + " 🏳"
            color: palette.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            text: "Mines: " + numMines.value + " 💣"
            color: palette.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
