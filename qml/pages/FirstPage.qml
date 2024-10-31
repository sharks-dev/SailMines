import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: gamePage

    property var board: []
    property int mines: 0
    property int adjacentMineCount: 0
    property int i: 0
    property int idx: 0
    property int gridSize: 10 // Grid dimensions, e.g., 10x10
    property int numMines: 5 // Number of mines

    // This timer controls the counter at the top
    // of the screen, indicating how many seconds
    // it's taken so far for you to sweep the field.
    Timer {
        id: gameTimer
        interval: 1000
        repeat: true
        onTriggered: {
            updateTimer()
        }
    }

    // This row contains the timer, a reset button,
    // a settings button, and the remaining count of mines.
    Row {
        id: gameHeader
        spacing: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        property bool playing
        Label {
            id: timerText
            text: "0"
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFamilyHeading
        }
        IconButton {
            id: restart
            icon.source: "image://theme/icon-m-refresh"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: initialiseBoard()
        }
        IconButton {
            id: options
            icon.source: "image://theme/icon-m-setting"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: pageStack.animatorPush(Qt.resolvedUrl("SecondPage.qml"))
        }
        Label {
            id: mineCount
            text: "MineCount"
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFamilyHeading
        }
    }

    Grid {
        id: grid
        columns: gridSize
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: gridSize * gridSize
            SilicaFlickable {
                id: cell
                width: 100
                height: 120

                // Expose Button's text property through an alias
                property alias buttonText: cellButton.text
                property alias buttonEnabled: cellButton.enabled

                // there are gridSize^2 buttons generated here,
                // each representing a cell on the minefield.
                Button {
                    id: cellButton
                    text: ""
                    anchors.fill: parent

                    // The following logic determines if a button
                    // is pressed or long-pressed.
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onPressed: {
                            longPressTimer.start()  // Start the timer on press
                        }
                        onReleased: {
                            if (longPressTimer.running) {
                                longPressTimer.stop()  // Stop the timer if it's running
                                revealCell(cell, index)  // Short press action
                            }
                        }
                        onCanceled: {
                            longPressTimer.stop()  // Stop the timer if the press is canceled
                        }
                    }

                    Timer {
                        id: longPressTimer
                        interval: 500
                        repeat: false
                        onTriggered: {
                            flagCell(cell)  // Long press action
                        }
                    }
                }


            }
        }
    }

    // when the screen is loaded,
    // start the game.
    Component.onCompleted: {
        initialiseBoard();
        gameTimer.start();
    }

    function updateTimer() {
        timerText.text = timerText.text*1 + 1;
    }

    function initialiseBoard() {
        // reset the game header data
        gameTimer.start();
        mineCount.text = numMines;
        timerText.text = 0;

        // Enable every button, set its text to nothing
        for (i = 0; i < board.length; i++) {
            grid.children[i].buttonEnabled = true;
            grid.children[i].buttonText = "";
        }

        // Create an array of size gridSize * gridSize with all elements set to 0
        board = []
        for (i = 0; i < gridSize * gridSize; i++) {
            board.push(0)
        }

        // Randomly place mines (value -1 indicates a mine)
        mines = 0
        while (mines < numMines) {
            idx = Math.floor(Math.random() * board.length)
            if (board[idx] !== -1) { // Check if there is no mine
                board[idx] = -1       // Place a mine
                mines++
            }
        }

        // Calculate adjacent mines for each cell
        for (i = 0; i < board.length; i++) {
            if (board[i] !== -1) {
                board[i] = countAdjacentMines(i)
            }
        }
    }

    function countAdjacentMines(index) {
        adjacentMineCount = 0;

        var indices = getAdjacentIndices(index);

        // for each adjacent cell, if it is a mine, increment adjacentMineCount.
        for (var i = 0; i < indices.length; i++) {
            if (board[indices[i]] === -1) {
                adjacentMineCount++
            }
        }

        return adjacentMineCount;
    }

    function flagCell(cell) {
        if (cell.buttonText === "🏳") {
            cell.buttonText = "";
            mineCount.text = mineCount.text*1 + 1;
        } else if (cell.buttonText === "") {
            cell.buttonText = "🏳"
            mineCount.text = mineCount.text*1 - 1;
            if (mineCount.text === "0") {
                // we know we have the right number of flags,
                // but not sure if they're in the right places.
                var count = 0;
                for (i = 0; i < board.length; i++) {
                    if (board[i] === -1) {
                        if (grid.children[i].buttonText === "🏳") {
                            count++
                        }
                    }
                }
                if (count === numMines) {
                    // we know the flags were in the right spot.
                    gameTimer.stop();
                    Notices.show("You won!", Notice.Short, Notice.Center);
                }
            }
        }
    }

    function revealCell(cell, index) {
        // Logic to reveal cell and handle game over or winning conditions
        //console.log("Cell index:", index, "Status:", board[index]);

        if (cell.buttonText === "🏳") {
            // if the cell has been flagged,
            // we don't want to accidentally press it.
            return;
        }


        if (board[index] === 0) { // if the cell is safe and there are no adjacent mines,
            cell.buttonEnabled = false;
            var indices = getAdjacentIndices(index); // continue checking all adjacent cells until we find mines.
            for (var j = 0; j < indices.length; j++) {
                if (grid.children[indices[j]].buttonEnabled !== false) {
                revealCell(grid.children[indices[j]], indices[j]); }
            }
        } else if (board[index] !== -1) { // if the cell is safe, but there are adjacent mines,
            cell.buttonText = board[index]; // show the user how many adjacent mines there are.
            cell.buttonEnabled = false;

            // count the number of still enabled cells
            var count = 0;
            for (i = 0; i < board.length; i++) {
                if (grid.children[i].buttonEnabled !== false) {
                    count++
                }
            }

            // if the number of still enabled cells = numMines, you win! 🏳🏳
            if (count === numMines) {
                for (i = 0; i < board.length; i++) {
                    if (board[i] === -1) {
                        grid.children[i].buttonText = "🏳";
                    }
                }
                mineCount.text = "0";
                // stop timer
                gameTimer.stop();
                Notices.show("You won!", Notice.Short, Notice.Center);
            }

        } else {
            // you lose.

            // show all the mines
            for (i = 0; i < board.length; i++) {
                if (board[i] === -1) {
                    grid.children[i].buttonText = "💣";
                }
            }

            // stop timer
            gameTimer.stop();

            Notices.show("You lost!", Notice.Short, Notice.Center);
        }
    }

    function getAdjacentIndices(idx) {
        var indices = [];

        // Calculate grid position
        var row = Math.floor(idx / gridSize);
        var col = idx % gridSize;

        // Define adjacent positions (up, down, left, right, etc.)
        var adjacentIndexes = [
            idx - gridSize - 1,    // Up & Left
            idx - gridSize,        // Up
            idx - gridSize + 1,    // Up & Right
            idx + gridSize - 1,    // Down & Left
            idx + gridSize,        // Down
            idx + gridSize + 1,    // Up & Right
            idx - 1,               // Left
            idx + 1                // Right
        ];

        // Update adjacent cells' text if within bounds
        adjacentIndexes.forEach(function(adjIdx) {
            if (adjIdx >= 0 && adjIdx < gridSize * gridSize) {
                var adjRow = Math.floor(adjIdx / gridSize);
                var adjCol = adjIdx % gridSize;

                // Ensure left and right adjacency don't wrap
                if (Math.abs(row - adjRow) <= 1 && Math.abs(col - adjCol) <= 1) {
                    indices.push(adjIdx); //add adjidx to an array, return that array.
                }
            }
        });

        return indices;
    }


}
