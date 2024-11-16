// ==UserScript==
// @name         Parkour Generator (Auto)
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Custom parkour map generator
// @author       eldertubby + Salama
// @match        *://bonk.io/*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

// To prevent duplicate UI:
// if (window.self !== window.top) {
//     return;
// }

    if (document.getElementById('mainUIPanel')) {
        console.log("UI already exists, skipping creation.");
        return;
    }

    console.log("UI created");

  let buttonsInactive = true; // Set to true to start with buttons inactive

    const mapsData = [];
    let currentMapIndex = -1;
    let timerInterval = null;
    let timerSeconds = 0;

    window.parkourGenerator = {
        keepPositions: false
    }

   function createMainUI() {
    const container = document.createElement("div");
    container.id = "mainUIPanel";
    container.style.position = "fixed";
    container.style.top = "50px";
    container.style.left = "50px";
    container.style.width = "180px";
    container.style.backgroundColor = "#cfd8cd";
    container.style.border = "2px solid #ccc";
    container.style.borderRadius = "3px";
    container.style.padding = "0px";
    container.style.boxShadow = "0 4px 8px rgba(0,0,0,0.2)";
    container.style.zIndex = 1000;
    container.style.overflow = "hidden"; // Start with overflow hidden
    container.style.fontFamily = 'futurept_b1';
    container.style.transition = "width 0.3s, height 0.3s";
             // container.style.resize = "both";
// Smooth collapse/expand

    makeElementDraggable(container);

    // Create a heading element
    const heading = document.createElement("div");
    heading.innerText = "Parkour Generator";
    heading.style.backgroundColor = "#009688"; // Greenish color
    heading.style.color = "white";
     heading.style.fontSize = "17px"

    heading.style.padding = "5px";
     heading.style.paddingLeft = "25px";
    heading.style.borderRadius = "3px 3px 0 0"; // Rounded corners at the top
    heading.style.textAlign = "left";
    heading.style.width = "calc(100% + 30px)"; // Span the full width of the container (including padding)
    heading.style.marginLeft = "0px"; // Adjust to account for padding

    heading.style.boxShadow = "0 2px 6px rgba(0,0,0,0.2)"; // Optional shadow for depth
    container.appendChild(heading); // Append heading to the container

    // Create a wrapper for the UI elements
    const contentWrapper = document.createElement("div");
    contentWrapper.id = "contentWrapper";
    contentWrapper.style.display = "block"; // Default to visible
    container.appendChild(contentWrapper);

    // Add your other UI elements here as needed
    createMapAndTimerUI(contentWrapper); // Use contentWrapper for your map and timer UI

    // Create the collapse/expand button
    const toggleButton = document.createElement("button");
    toggleButton.innerHTML = "-"; // Start with a "-" icon
    toggleButton.style.position = "absolute"; // Keep it fixed to the container
    toggleButton.style.right = "3px"; // Move to the right outside the container
    toggleButton.style.top = "3.5px"; // Align near the top
    toggleButton.style.width = "25px";
    toggleButton.style.height = "25px";
    toggleButton.style.borderRadius = "3px"; // Circular button
    toggleButton.style.backgroundColor = "#80544c"; // Brownish color
    toggleButton.style.color = "white"; // Text color
    toggleButton.style.border = "none";
    toggleButton.style.cursor = "pointer";
    toggleButton.style.fontSize = "15px";
    toggleButton.style.lineHeight = "30px"; // Center the text vertically
    // toggleButton.style.boxShadow = "0 2px 6px rgba(0,0,0,0.2)"; // Add some shadow for depth

    let isCollapsed = false; // Track if collapsed or expanded

    toggleButton.addEventListener("click", () => {
        if (!isCollapsed) {
            // Collapse the container
            contentWrapper.style.display = 'none';
            container.style.height = "40px"; // Shrink to just show the toggle button
            container.style.overflow = "hidden"; // Hide scrollbars when collapsed
            toggleButton.innerHTML = "+"; // Change to "+" when collapsed
            // toggleButton.style.top = "5px"; // Adjust button's position when collapsed
        } else {
            // Expand the container
            contentWrapper.style.display = 'block';
            container.style.height = ""; // Auto height based on content
            // container.style.overflow = "auto"; // Allow scrolling when expanded
            toggleButton.innerHTML = "-"; // Change to "-" when expanded
            // toggleButton.style.top = "5px"; // Adjust button's position when expanded
        }
        isCollapsed = !isCollapsed;
    });

    container.appendChild(toggleButton); // Append toggle button to the container

    document.body.appendChild(container);
    return container;
}


    function makeElementDraggable(element) {
        let posX = 0, posY = 0, mouseX = 0, mouseY = 0, isResizing = false;

        element.addEventListener("mousedown", function(e) {

            if (isNearResizeArea(e, element)) {
                isResizing = true;
                return;
            }
            isResizing = false;
            e.preventDefault();
            mouseX = e.clientX;
            mouseY = e.clientY;
            document.onmouseup = closeDragElement;
            document.onmousemove = elementDrag;
        });

        function elementDrag(e) {
            if (isResizing) return;

            e.preventDefault();
            posX = mouseX - e.clientX;
            posY = mouseY - e.clientY;
            mouseX = e.clientX;
            mouseY = e.clientY;
            element.style.top = (element.offsetTop - posY) + "px";
            element.style.left = (element.offsetLeft - posX) + "px";
        }

        function closeDragElement() {
            document.onmouseup = null;
            document.onmousemove = null;
        }


        function isNearResizeArea(e, element) {
            const rect = element.getBoundingClientRect();
            const offset = 20;
            return (
                e.clientX > rect.right - offset &&
                e.clientY > rect.bottom - offset
            );
        }
    }

    function createStyledButton(text, onClick) {
        const button = document.createElement("button");
        button.innerHTML = text;
        button.style.fontFamily = 'futurept_b1';
    button.style.backgroundColor = buttonsInactive ? "grey" : "#80544c"; // Change to grey if inactive
        button.style.color = "white";
        button.style.fontSize = "14px"
        button.style.border = "none";
        button.style.padding = "5px";
        button.style.margin = "5px";
    button.style.cursor = buttonsInactive ? "not-allowed" : "pointer"; // Change cursor
      button.style.borderRadius = "3px";
button.addEventListener("click", (e) => {
        if (buttonsInactive) {
            e.preventDefault(); // Prevent default action
            return; // Exit if buttons are inactive
        }
        onClick(); // Call the provided onClick function if active
    });        return button;
    }

    function createNotificationElement() {
        const notification = document.createElement("div");
        notification.style.position = "fixed";
        notification.style.fontFamily = 'futurept_b1';
        notification.style.top = "10px";
        notification.style.left = "50%";
        notification.style.transform = "translateX(-50%)";
        notification.style.backgroundColor = "#009688";
        notification.style.color = "white";
        notification.style.padding = "10px";
        notification.style.borderRadius = "3px";
        notification.style.zIndex = 1000;
        notification.style.display = "none";
        document.body.appendChild(notification);
        return notification;
    }

    const notificationElement = createNotificationElement();

    function showNotification(message, duration = 3000) {
        notificationElement.textContent = message;
        notificationElement.style.display = "block";
        setTimeout(() => {
            notificationElement.style.display = "none";
        }, duration);
    }

    function createMapAndTimerUI(container) {

         container.style.display = "flex";
    container.style.flexDirection = "column"; // Stack buttons vertically
    container.style.alignItems = "center"; // Center items horizontally
    container.style.padding = "5px"; // Optional padding for better spacing

        const pasteButton = createStyledButton("Paste Map Data", async function() {
            try {
                const text = await navigator.clipboard.readText();
                if (text.trim()) {
                    mapsData.push({ name: `Map ${mapsData.length + 1}`, lines: text });
                    showNotification("Map added successfully!");
                } else {
                    showNotification("Clipboard is empty. Copy map data first.");
                }
            } catch (err) {
                console.error("Failed to read clipboard contents: ", err);
                showNotification("Failed to read clipboard.");
            }
        });
pasteButton.style.width = "130px";
        const randomMapButton = createStyledButton("Create Random Map", function() {
            selectRandomMap();
        });
randomMapButton.style.width = "130px";
        const timerDisplay = document.createElement("div");
        timerDisplay.id = "timerDisplay";
        timerDisplay.style.fontSize = "20px";
        timerDisplay.style.fontFamily = 'futurept_b1';
        timerDisplay.style.marginBottom = "10px";
        timerDisplay.style.padding = "8px";

        timerDisplay.innerHTML = "00:00";

          const timerButtonContainer = document.createElement("div");
    timerButtonContainer.style.display = "flex"; // Use flexbox for the timer buttons
    timerButtonContainer.style.flexDirection = "row"; // Set the direction to row
    timerButtonContainer.style.marginBottom = "5px"; // Optional margin for spacing
      timerButtonContainer.style.gap = "10px"; // Set gap between buttons


    const incrementButton = createStyledButton("+10 Sec", incrementTimer);
    const decrementButton = createStyledButton("-10 Sec", decrementTimer);

    // Append the buttons to the timer button container
    timerButtonContainer.appendChild(incrementButton);
    timerButtonContainer.appendChild(decrementButton);
     const controlButtonContainer = document.createElement("div");
    controlButtonContainer.style.display = "flex"; // Use flexbox for the control buttons
    controlButtonContainer.style.flexDirection = "row"; // Set the direction to row
    controlButtonContainer.style.marginBottom = "5px"; // Optional margin for spacing


    const startButton = createStyledButton("Start", startTimer);
    const stopButton = createStyledButton("Stop", stopTimer);
    const resetButton = createStyledButton("Reset", resetTimer);

    // Append the control buttons to the control button container
    controlButtonContainer.appendChild(startButton);
    controlButtonContainer.appendChild(stopButton);
    controlButtonContainer.appendChild(resetButton);

        container.appendChild(pasteButton);
        container.appendChild(randomMapButton);
        container.appendChild(timerDisplay);    container.appendChild(timerButtonContainer); // Add the button container
    container.appendChild(controlButtonContainer); // Add the control button container
buttonsInactive = false; // Activate buttons after a successful action

      const pasteAndStartButton = createStyledButton("Paste Data And Start", async function() {
    try {
        const text = await navigator.clipboard.readText();
        if (text.trim()) {
            showNotification("Map generated successfully! Starting the map...");
            createAndSetMap(text);
          if (document.getElementById("newbonklobby").style.display === "none") {
            window.parkourGenerator.keepPositions = false;
        }
          window.bonkHost.startGame();// Automatically start after pasting
        } else {
            showNotification("Clipboard is empty. Copy map data first.");
        }
    } catch (err) {
        console.error("Failed to read clipboard contents: ", err);
        showNotification("Failed to read clipboard.");
    }
});
pasteAndStartButton.style.width = "130px";
container.appendChild(pasteAndStartButton);

    }

    function incrementTimer() {
        timerSeconds += 10;
        updateTimerDisplay();
    }

    function decrementTimer() {
        if (timerSeconds >= 10) {
            timerSeconds -= 10;
            updateTimerDisplay();
        }
    }

    function startTimer() {
        if (timerInterval) return;
        timerInterval = setInterval(() => {
            if (timerSeconds > 0) {
                timerSeconds--;
                updateTimerDisplay();
            } else {
                stopTimer();
                showNotification("Timer finished!");
                selectRandomMap();
            }
        }, 1000);
    }

    function stopTimer() {
        clearInterval(timerInterval);
        timerInterval = null;
    }

    function resetTimer() {
        stopTimer();
        timerSeconds = 0;
        updateTimerDisplay();
    }

    function updateTimerDisplay() {
        const minutes = Math.floor(timerSeconds / 60);
        const seconds = timerSeconds % 60;
        document.getElementById("timerDisplay").innerHTML =
            String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0');
    }

    function selectRandomMap() {
        if (mapsData.length === 0) {
            showNotification("No maps available. Add map data first.");
            return;
        }

        let randomIndex;
        do {
            randomIndex = Math.floor(Math.random() * mapsData.length);
        } while (randomIndex === currentMapIndex && mapsData.length !== 1);

        currentMapIndex = randomIndex;
        const lineData = mapsData[randomIndex].lines;
        createAndSetMap(lineData);
        if (document.getElementById("newbonklobby").style.display === "none") {
            window.parkourGenerator.keepPositions = true;
        }
        window.bonkHost.startGame();
    }

   function createAndSetMap(red) {
        try {
            const w = parent.frames[0];
            let gs = w.bonkHost.toolFunctions.getGameSettings();
            let map = w.bonkHost.bigClass.mergeIntoNewMap(w.bonkHost.bigClass.getBlankMap());
            // Parse the JSON input
        let inputData = JSON.parse(red);

        // Extract spawn values
        const spawnX = inputData.spawn.spawnX;
        const spawnY = inputData.spawn.spawnY;

          const mapSize = inputData.mapSize !== undefined ? inputData.mapSize : 9;

        map.m.a = w.bonkHost.players[w.bonkHost.toolFunctions.networkEngine.getLSID()].userName;
        map.m.n = "Generated Parkour";

             // Set up shapes from the input data
        map.physics.shapes = inputData.lines.map((r) => {
            let shape = w.bonkHost.bigClass.getNewBoxShape();
            shape.w = r.width;
            shape.h = r.height;
            shape.c = [r.x, r.y];
                shape.a = r.angle / (180 / Math.PI);
            shape.color = r.color;
            shape.d = true; // Assuming 'd' is always true for shapes
            return shape;
        });

        // Add bodies in batches of 100
        for (let i = 0; i < Math.ceil(map.physics.shapes.length / 100); i++) {
            let body = w.bonkHost.bigClass.getNewBody();
            body.p = [-935, -350];
                body.fx = Array.apply(null, Array(Math.min(100, map.physics.shapes.length - i * 100))).map((_, j) => { return i * 100 + j; });
            map.physics.bodies.unshift(body);
        }

       // Create fixtures based on the input data
        map.physics.fixtures = inputData.lines.map((r, i) => {
            let fixture = w.bonkHost.bigClass.getNewFixture();
            fixture.sh = i;
            fixture.d = r.isDeath;
            fixture.re = r.bounciness;
            fixture.fr = r.friction;
            fixture.np = r.noPhysics;
            fixture.ng = r.noGrapple; // Updated to match new JSON structure
            fixture.f = r.color;

           // Set the name based on line attributes
        map.physics.bro = map.physics.bodies.map((_, i) => i);
    if (r.isCapzone) {
      fixture.n = r.id + ". CZ";
    } else if (r.isNoJump) {
      fixture.n = r.id + ". NoJump";
    } else if (r.noPhysics) {
      fixture.n = r.id + ". NoPhysics";
    } else {
      fixture.n = r.id + ". Shape";
    }


            return fixture;
        });

        map.physics.bro = map.physics.bodies.map((_, i) => i);

          // Add cap zones based on conditions
inputData.lines.forEach((line) => {

  if (line.isCapzone) {
    // Create a new cap zone object
    const newCapZone = {
      n: line.id + ". Cap Zone",
      ty: 1,
      l: 0.01,
      i: line.id
    };

    // Access the existing capZones array and add the new cap zone
    map.capZones.push(newCapZone);
  }

  if (line.isNoJump) {
    // Create a new cap zone object for NoJump
    const newCapZoneNoJump = {
      n: line.id + ". No=Jump",
      ty: 2,
      l: 10,
      i: line.id
    };

    // Access the existing capZones array and add the new cap zone
    map.capZones.push(newCapZoneNoJump);
  }
});


        if (spawnY <= 10000 && spawnX <= 10000) {
    // Set up the spawn based on parsed data
    map.spawns = [{
        b: true,
        f: true,
        gr: false,
        n: "Spawn",
        priority: 5,
        r: true,
        x: spawnX,
        xv: 0,
        y: spawnY,
        ye: false,
        yv: 0
    }];
}

        map.s.nc = true;
        map.s.re = true;
        map.physics.ppm = mapSize;

        gs.map = map;
        w.bonkHost.menuFunctions.setGameSettings(gs);
        w.bonkHost.menuFunctions.updateGameSettings();

        showNotification("Map created successfully!");
    } catch (e) {
        console.error("An error occurred while creating the map:", e);
        // showNotification("Failed to create the map. Check the console for errors.");
    }
}

    createMainUI();

    let injector = (str) => {
        let newStr = str;

        ///////////////////
        // From host mod //
        ///////////////////

        const BIGVAR = newStr.match(/[A-Za-z0-9$_]+\[[0-9]{6}\]/)[0].split('[')[0];
        let stateCreationString = newStr.match(/[A-Za-z]\[...(\[[0-9]{1,4}\]){2}\]\(\[\{/)[0];
        let stateCreationStringIndex = stateCreationString.match(/[0-9]{1,4}/g);
        stateCreationStringIndex = stateCreationStringIndex[stateCreationStringIndex.length - 1];
        let stateCreation = newStr.match(`[A-Za-z0-9\$_]{3}\[[0-9]{1,3}\]=[A-Za-z0-9\$_]{3}\\[[0-9]{1,4}\\]\\[[A-Za-z0-9\$_]{3}\\[[0-9]{1,4}\\]\\[${stateCreationStringIndex}\\]\\].+?(?=;);`)[0];
        stateCreationString = stateCreation.split(']')[0] + "]";

        const SET_STATE = `
            if (
                ${BIGVAR}.bonkHost.state &&
                !window.bonkHost.keepState &&
                window.parkourGenerator.keepPositions &&
                window.bonkHost.toolFunctions.getGameSettings().ga === "b"
                ) {
                ${stateCreationString}.discs = [];
                for(let i = 0; i < ${BIGVAR}.bonkHost.state.discs.length; i++) {
                    if(${BIGVAR}.bonkHost.state.discs[i] != undefined) {
                        ${stateCreationString}.discs[i] = ${BIGVAR}.bonkHost.state.discs[i];
                        if(window.bonkHost.toolFunctions.getGameSettings().mo=='sp') {
                            ${stateCreationString}.discs[i].a1a -= Math.min(2*30, 2*30 - ${BIGVAR}.bonkHost.state.ftu)*3;
                        }
                    }
                }
                for(let i = 0; i < ${BIGVAR}.bonkHost.state.discDeaths.length; i++) {
                    if(${BIGVAR}.bonkHost.state.discDeaths[i] != undefined) {
                        ${stateCreationString}.discDeaths[i] = ${BIGVAR}.bonkHost.state.discDeaths[i];
                    }
                }
                ${stateCreationString}.seed=${BIGVAR}.bonkHost.state.seed;
                ${stateCreationString}.rc=${BIGVAR}.bonkHost.state.rc + 1;
                ${stateCreationString}.rl=0;
                ${stateCreationString}.ftu=60;
                ${stateCreationString}.shk=${BIGVAR}.bonkHost.state.shk;
                window.parkourGenerator.keepPositions = false;
            };
            `;

        const stateSetRegex = newStr.match(/\* 999\),[A-Za-z0-9\$_]{3}\[[0-9]{1,3}\],null,[A-Za-z0-9\$_]{3}\[[0-9]{1,3}\],true\);/)[0];
        newStr = newStr.replace(stateSetRegex, stateSetRegex + SET_STATE);
        return newStr;
    }

    if(!window.bonkCodeInjectors) window.bonkCodeInjectors = [];
    window.bonkCodeInjectors.push(bonkCode => {
        try {
            return injector(bonkCode);
        } catch (error) {
            alert("Code injection for parkour generator failed");
            throw error;
        }
    });

    console.log("Parkour Generator injector loaded");

})();
