import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {} //What's this doing?
        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader { title: "Options" }
            // Controls for setting minefield (board) size
            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                IconButton {
                    id: sizeDownBtn
                    height: sizeLabel.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-remove"
                    onClicked: boardSize.value = boardSize.value - 1
                }
                Label {
                    id: sizeLabel
                    text: "Board size: " + Math.round(boardSize.value) + "x" + Math.round(boardSize.value)
                    anchors.verticalCenter: parent.verticalCenter
                    color: palette.highlightColor
                    font.family: Theme.fontFamilyHeading
                }
                IconButton {
                    id: sizeUpBtn
                    height: sizeLabel.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-add"
                    onClicked: boardSize.value = boardSize.value + 1
                }
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

            // Controls for setting mine count
            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                IconButton {
                    id: minesDownBtn
                    height: minesLabel.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-remove"
                    onClicked: mineCount.value = mineCount.value - 1
                }
                Label {
                    id: minesLabel
                    text: "Mine count: " + Math.round(mineCount.value)
                    anchors.verticalCenter: parent.verticalCenter
                    color: palette.highlightColor
                    font.family: Theme.fontFamilyHeading
                }
                IconButton {
                    id: minesUpBtn
                    height: minesLabel.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-add"
                    onClicked: mineCount.value = mineCount.value + 1
                }
            }
            Slider {
                id: mineCount
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                value: numMines
                minimumValue: 1
                maximumValue: gridSize * gridSize - 1
            }

            // Apply configuration changes to game
            Button {
                id: save
                text: "Apply"
                onClicked: rebuildGrid()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Some information for the user (controls, source, etc.)
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
                plainText: "Source available, GPL3: https://github.com/sharks-dev/SailMines"
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
