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
                value: gridSize
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
                value: numMines
                minimumValue: 1
                maximumValue: gridSize * gridSize - 1
            }

            Button {
                id: save
                text: "Apply"
                onClicked: rebuildGrid()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                x: Theme.paddingLarge
                width: parent.width - 2*x
                spacing: Theme.paddingLarge
                Repeater {
                    model: [
                        "Press a grid square to reveal it. Hold a square to flag it."
                    ]
                    Label {
                        text: modelData
                        color: palette.highlightColor
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                }
            }

            LinkedLabel {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                plainText: "Source available, GPL3: https://github.com/Doofitator/SailMines"
            }



        }
    }

    function rebuildGrid() {
        // TODO: This doesn't work.
        // [W] unknown:65 - file:///usr/share/SailMines/qml/pages/SecondPage.qml:65: ReferenceError: gamePage is not defined
        gridSize = Math.round(boardSize.value);
        numMines = Math.round(mineCount.value);
        //gamePage.initialiseBoard();
    }

    function editSliderBounds() {
        mineCount.maximumValue = Math.round(boardSize.value) * Math.round(boardSize.value) - 1;
        if (mineCount.value > mineCount.maximumValue) {
            mineCount.value = mineCount.maximumValue;
        }
    }

}
