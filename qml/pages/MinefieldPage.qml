import QtQuick 2.0
import QtFeedback 5.0
import Sailfish.Silica 1.0

Page {
    id: gamePage

    property var board: []
    property int mines: 0
    property int adjacentMineCount: 0
    property int i: 0
    property int idx: 0

    // controls the flag vibration
    ThemeEffect {
        id: keypadBuzz
        effect: ThemeEffect.PressWeak
    }

    // controls the game lost vibration
    ThemeEffect {
        // FIXME: I wanted to use a HapticsEffect here, with a long duration.
        //        Unfortunately, either it doesn't work on my device or it doesn't
        //        work in SFOS in general. Even the ComponentsGallery app is broken
        //        in this respect for me.
        id: longBuzz
        effect: ThemeEffect.PressStrong
    }

    // This timer controls the counter at the bottom
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

    Flickable {
        id: scrollableArea
        anchors.fill: parent
        anchors.bottomMargin: gameFooter.height
        // Buffer of '750' means you don't have to reach right to the edge
        // of the screen.
        contentWidth: grid.width + 750      // Sets the horizontal scroll limit
        contentHeight: grid.height + 750    // Sets the vertical scroll limit
        clip: true                          // Clips content to keep it within viewable area
        scale: 1.0

        Grid {
            id: grid
            columns: gridSize.value
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: gridSize.value * gridSize.value
                SilicaFlickable {
                    id: cell
                    width: 100
                    height: 120

                    // Expose Button's text property through an alias
                    property alias buttonText: cellButton.text
                    property alias buttonEnabled: cellButton.enabled
                    property alias buttonColour: cellButton.color

                    // there are gridSize.value^2 buttons generated here,
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
                                    buttonPress(!controlMode.value, cell, index); // Short press action
                                }
                            }
                            onCanceled: {
                                longPressTimer.stop()  // Stop the timer if the press is canceled
                            }
                        }

                        Timer {
                            id: longPressTimer
                            interval: 125
                            repeat: false
                            onTriggered: {
                                if (cell.buttonEnabled === true) {
                                    keypadBuzz.play();
                                    buttonPress(controlMode.value, cell, index); // Long press action
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    Column { // why is this a column?
        id: gameFooter
        width: parent.width
        anchors.bottom: parent.bottom
        z: 1
        Row {
            // This row contains the timer, a reset button,
            // a settings button, and the remaining count of mines.
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            SecondaryButton {
                id: zoomOutBtn
                width: height
                icon.source: "image://theme/icon-m-remove"
                onClicked: updateScale(false)
            }
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
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SettingsPage.qml"), { gamePageRef: gamePage })
            }
            Label {
                id: mineCount
                text: "NaN"
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.fontFamilyHeading
            }
            SecondaryButton {
                id: zoomInBtn
                width: height
                icon.source: "image://theme/icon-m-add"
                onClicked: updateScale(true)
            }
        }
    }

    // when the screen is loaded,
    // start the game.
    Component.onCompleted: {
        initialiseBoard();
        gameTimer.start();
        console.log(grid.width);
    }

    function updateTimer() {
        timerText.text = timerText.text*1 + 1;
    }

    function initialiseBoard() {
        // reset the game header data
        gameTimer.start();
        mineCount.text = numMines.value;
        timerText.text = 0;

        // Enable every button, set its text to nothing, set its colour to primary.
        for (i = 0; i < board.length; i++) {
            grid.children[i].buttonEnabled = true;
            grid.children[i].buttonText = "";
            grid.children[i].buttonColour = palette.primaryColor;
        }

        // Create an array of size gridSize.value * gridSize.value with all elements set to 0
        board = []
        for (i = 0; i < gridSize.value * gridSize.value; i++) {
            board.push(0)
        }

        // Randomly place mines (value -1 indicates a mine)
        mines = 0
        while (mines < numMines.value) {
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

    function buttonPress(longpress, cell, index) {
        if ((cell.buttonText !== "") && (cell.buttonText !== "🏳")) { // if it is a 'number' cell
            // if the button has been given a value already,
            // clicking on it should reveal its adjacent cells.
            var indices = getAdjacentIndices(index); // continue checking all adjacent cells until we find mines.
            for (var j = 0; j < indices.length; j++) {
                if (grid.children[indices[j]].buttonEnabled !== false) {
                revealCell(grid.children[indices[j]], indices[j]); }
            }
        } else {
            if (longpress) {
                flagCell(cell, index);
            } else {
                revealCell(cell, index);
            }
        }

        if (mineHints.value) { // if the settings are configured such,
            var adjacentCells = getAdjacentIndices(index);
            for (var j = 0; j < adjacentCells.length; j++) { // for each adjacent cell to the one pressed
                highlightCell(adjacentCells[j]);
            }
        }
    }

    function applyHighlights() {
        for (i = 0; i < board.length; i++) {
            if (!mineHints.value) {
                highlightCell(i);
            } else {
                grid.children[i].buttonColour = palette.primaryColor;
            }
        }
    }

    function highlightCell(index) {
        if ((grid.children[index].buttonText !== "") && (grid.children[index].buttonText !== "🏳")) { // if it is a 'number' cell (TODO: will it work on blank cells??)
            var adjacentMines = countAdjacentMines(index);
            var potentialFlags = getAdjacentIndices(index);
            var flagCount = 0;

            for (var k = 0; k < potentialFlags.length; k++) { // for each cell adjacent to that adjacent cell
                if (grid.children[potentialFlags[k]].buttonText === "🏳") { // if it is flagged
                    flagCount += 1; // make a note of that
                }
            }

            if (flagCount === adjacentMines) { // check the number of flags matches the requirement
                grid.children[index].buttonColour = palette.secondaryColor; // let the user see that
            } else {
                grid.children[index].buttonColour = palette.primaryColor;
            }
        }
    }

    function flagCell(cell, index) {
        if (cell.buttonText === "🏳") {
            // unflag cell
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
                if (count === numMines.value) {
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
            if (count === numMines.value) {
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
                    if (grid.children[i].buttonText !== "🏳") {
                    grid.children[i].buttonText = "💣"; }
                }
            }

            // stop timer
            gameTimer.stop();

            longBuzz.play();
            Notices.show("You lost!", Notice.Short, Notice.Center);
        }
    }

    function getAdjacentIndices(idx) {
        var indices = [];

        // Calculate grid position
        var row = Math.floor(idx / gridSize.value);
        var col = idx % gridSize.value;

        // Define adjacent positions (up, down, left, right, etc.)
        var adjacentIndexes = [
            idx - gridSize.value - 1,    // Up & Left
            idx - gridSize.value,        // Up
            idx - gridSize.value + 1,    // Up & Right
            idx + gridSize.value - 1,    // Down & Left
            idx + gridSize.value,        // Down
            idx + gridSize.value + 1,    // Up & Right
            idx - 1,               // Left
            idx + 1                // Right
        ];

        // Update adjacent cells' text if within bounds
        adjacentIndexes.forEach(function(adjIdx) {
            if (adjIdx >= 0 && adjIdx < gridSize.value * gridSize.value) {
                var adjRow = Math.floor(adjIdx / gridSize.value);
                var adjCol = adjIdx % gridSize.value;

                // Ensure left and right adjacency don't wrap
                if (Math.abs(row - adjRow) <= 1 && Math.abs(col - adjCol) <= 1) {
                    indices.push(adjIdx); //add adjidx to an array, return that array.
                }
            }
        });

        return indices;
    }

    function updateScale(zoomIn) {
        if (zoomIn) {
            if (grid.scale < 2.0) {
                grid.scale = grid.scale + 0.1;
                zoomOutBtn.enabled = true;
                if (grid.scale >= 2.0) {
                    zoomInBtn.enabled = false;
                }
            }
        } else{
            if (grid.scale > 0.5) {
                grid.scale = grid.scale - 0.1;
                zoomInBtn.enabled = true;
                if (grid.scale <= 0.5) {
                    zoomOutBtn.enabled = false
                }
            }
        }

        fixScrollBounds();
    }

    function fixScrollBounds() {
        // Update Flickable content size to allow panning when zoomed
        scrollableArea.contentWidth = (grid.width) * grid.scale + 750
        scrollableArea.contentHeight = (grid.height) * grid.scale + 750
    }



}
