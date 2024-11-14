import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

CoverBackground {
    Column {
        anchors.centerIn: parent
        Image {
            id: iconImage
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../../../icons/hicolor/172x172/apps/SailMines.png"
        }
        Label {
            id: label
            text: "SailMines"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            text: qsTr("Field: ") + gridSize.value + "x" + gridSize.value + " 🏳"
            color: palette.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            text: qsTr("Mines: ") + numMines.value + " 💣"
            color: palette.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
