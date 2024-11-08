import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: settingPage

    property Page gamePageRef

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {} //What's this doing?
        Column {
            id: column
            spacing: Theme.paddingLarge
            x: Theme.paddingLarge
            width: parent.width - 2*x
            PageHeader { title: "Options" }
            // Controls for setting minefield (board) size
            Label {
                text: "Minefield configuration: "
                color: palette.highlightColor
                wrapMode: Text.Wrap
                width: parent.width
            }
            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                IconButton {
                    id: sizeDownBtn
                    height: sizeLabel.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-remove"
                    onClicked: if (boardSize.value - 1 > boardSize.minimumValue) { boardSize.value = boardSize.value - 1; }
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
                    onClicked: if (boardSize.value + 1 < boardSize.maximumValue) { boardSize.value = boardSize.value + 1; }
                }
            }
            Slider {
                id: boardSize
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                value: gridSize.value
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
                    onClicked: if (mineCount.value - 1 > mineCount.minimumValue) { mineCount.value = mineCount.value - 1; }
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
                    onClicked: if (mineCount.value + 1 < mineCount.maximumValue) { mineCount.value = mineCount.value + 1; }
                }
            }
            Slider {
                id: mineCount
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                value: numMines.value
                minimumValue: 1
                maximumValue: gridSize.value * gridSize.value - 1
            }

            // Apply configuration changes to game
            Button {
                id: save
                text: "Apply"
                onClicked: rebuildGrid()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Options for the game controls
            Column {
                id: gameControls
                width: parent.width
                Label {
                    text: "Controls preferences: "
                    color: palette.highlightColor
                    wrapMode: Text.Wrap
                    width: parent.width
                }
                TextSwitch {
                    id: controlSwitch1
                    text: "Tap to reveal, hold to flag"
                    checked: controlMode.value
                    onClicked: changeControls()
                }
                TextSwitch {
                    id: controlSwitch2
                    text: "Tap to flag, hold to reveal"
                    checked: !controlMode.value
                    onClicked: changeControls()
                }
            }

            // Options for the game hints
            Column {
                id: gameHints
                width: parent.width
                Label {
                    text: "Hints: "
                    color: palette.highlightColor
                    wrapMode: Text.Wrap
                    width: parent.width
                }
                TextSwitch {
                    id: hintsSwitch
                    text: "Highlight cells when the correct number of flags surround it"
                    checked: mineHints.value
                    onClicked: toggleMineHints()
                }
            }

            // Information

            LinkedLabel {
                plainText: "SailMines by Sharks. More information at https://github.com/sharks-dev/SailMines"
                width: parent.width
                wrapMode: Text.WordWrap
            }



        }
    }

    function rebuildGrid() {
        gridSize.value = Math.round(boardSize.value);
        numMines.value = Math.round(mineCount.value);
        gamePageRef.initialiseBoard();
        gamePageRef.fixScrollBounds();
    }

    function editSliderBounds() {
        mineCount.maximumValue = Math.round(boardSize.value) * Math.round(boardSize.value) - 1;
        if (mineCount.value > mineCount.maximumValue) {
            mineCount.value = mineCount.maximumValue;
        }
    }

    function changeControls() {
        var temp = !controlMode.value;
        controlMode.value = temp;
        controlSwitch1.checked = temp;
        controlSwitch2.checked = !temp;
    }

    function toggleMineHints() {
        var temp = !mineHints.value;
        gamePageRef.applyHighlights();
        mineHints.value = temp;
    }

}
