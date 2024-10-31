import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}
        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader { title: "Options" }
            Label {
                text: "Board size: " + Math.round(boardSize.value) + "x" + Math.round(boardSize.value)
                anchors.horizontalCenter: parent.horizontalCenter
                color: palette.highlightColor
                font.family: Theme.fontFamilyHeading
            }
            Slider {
                id: boardSize
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                value: 10
                minimumValue: 10
                maximumValue: 100
                onValueChanged: editSliderBounds();
            }
            Label {
                text: "Mine count: " + Math.round(mineCount.value)
                anchors.horizontalCenter: parent.horizontalCenter
                color: palette.highlightColor
                font.family: Theme.fontFamilyHeading
            }
            Slider {
                id: mineCount
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                value: 5
                minimumValue: 1
                maximumValue: 99
            }

            Button {
                id: save
                text: "Apply"
                onClicked: rebuildGrid()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            LinkedLabel {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                plainText: "Written by Ash Sharkey. Source available, GPL3: https://github.com/Doofitator/SailMines"
            }


        }
    }

    function rebuildGrid() {
        // TODO: This doesn't work.
        // [W] unknown:65 - file:///usr/share/SailMines/qml/pages/SecondPage.qml:65: ReferenceError: gamePage is not defined
        gamePage.gridSize = Math.round(boardSize.value);
        gamePage.numMines = Math.round(mineCount.value);
        gamePage.initialiseBoard();
    }

    function editSliderBounds() {
        var ratio = mineCount.value/mineCount.maximumValue;
        mineCount.maximumValue = Math.round(boardSize.value) * Math.round(boardSize.value) - 1;
        mineCount.value = ratio * mineCount.maximumValue;
    }

}
