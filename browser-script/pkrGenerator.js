// ==UserScript==
// @name         pkrGenerator
// @namespace    http://tampermonkey.net/
// @version      0.3
// @description  Converts elder-tubby's parkour generator data to bonk.io maps. Contains a modified version of Clarifi's pkrUtils. Records and outputs player position. Requires 'BonkLIB' mod.
// @author       eldertubby + Salama + Clarifi
// @license      MIT
// @match        https://bonkisback.io/gameframe-release.html
// @match        https://bonk.io/gameframe-release.html
// @run-at       document-end
// @grant        none
// @updateURL    https://raw.githubusercontent.com/elder-tubby/parkour-gen-browser-script/refs/heads/main/mini-script.js
// @downloadURL  https://raw.githubusercontent.com/elder-tubby/parkour-gen-browser-script/refs/heads/main/mini-script.js
// ==/UserScript==

window.posRecorder = {}; // Namespace for encapsulating the UI functions and variables

// Use 'strict' mode for safer code by managing silent errors
'use strict';

posRecorder.windowConfigs = {
    windowName: "pkrGenerator",
    windowId: "parkour_generator_window",
    modVersion: "0.3",
    bonkLIBVersion: "1.1.3",
    bonkVersion: "49",
};
window.parkourGenerator = {
    keepPositions: false,
};

posRecorder.currentData = {};
posRecorder.scale = 1;
posRecorder.currentPlayerID = 0;
posRecorder.positionData = [];
posRecorder.isRecording = false;
posRecorder.recordingIntervalId = null;
posRecorder.inputState = null;

// Utility functions
const Utils = {

    showNotification(message, duration = 3000) {
        const note = document.createElement('div');
        note.textContent = message;
        Object.assign(note.style, {
            position: 'fixed',
            top: '20px',
            left: '50%',
            transform: 'translateX(-50%)',
            backgroundColor: '#222',
            color: '#fff',
            padding: '10px 20px',
            borderRadius: '6px',
            boxShadow: '0 2px 6px rgba(0,0,0,0.4)',
            fontSize: '14px',
            zIndex: 9999,
            opacity: 0,
            transition: 'opacity 0.3s ease-in-out'
        });

        document.body.appendChild(note);
        requestAnimationFrame(() => {
            note.style.opacity = 1;
        });

        setTimeout(() => {
            note.style.opacity = 0;
            note.addEventListener('transitionend', () => {
                note.remove();
            }, { once: true });
        }, duration);
    }

};

// Event listener function to change the player selected in the player selector
posRecorder.select_player = () => {
    let player_selector = document.getElementById("posRecorder_player_selector");
    let player_id = player_selector.options[player_selector.selectedIndex].value;
    posRecorder.currentPlayerID = player_id;
    //console.log("current Player ID: " + player_id);
};

// Create a new option in the player selector
posRecorder.create_option = (userID) => {
    //console.log("userID:" + userID);
    let playerName = bonkAPI.getPlayerNameByID(userID);
    let player_selector = document.getElementById("posRecorder_player_selector");
    let newOption = document.createElement("option");
    newOption.innerText = playerName;
    newOption.value = userID;
    newOption.id = "selector_option_" + userID;
    player_selector.appendChild(newOption);
    //console.log("selector_option_" + userID + " added to player_selector");
};

// Remove an option from the player selector
posRecorder.remove_option = (userID) => {
    let player_selector = document.getElementById("posRecorder_player_selector");
    let option = document.getElementById("selector_option_" + userID);
    player_selector.removeChild(option);
};

// Reset the player selector to the default state
posRecorder.reset_selector = () => {
    // Remove all options except the default one
    let player_selector = document.getElementById("posRecorder_player_selector");
    Array.from(player_selector.options).forEach((option) => {
        if (option.id !== "posRecorder_selector_option_user") {
            player_selector.removeChild(option);
        }
        // Reset the current player ID
        posRecorder.currentPlayerID = bonkAPI.getMyID();
        // Set the selector to the first option as default
        player_selector.selectedIndex = bonkAPI.getMyID();
    });
};

// Update the player list in the player selector
posRecorder.update_players = () => {
    // Get the list of players and the current player ID
    let playerList = bonkAPI.getPlayerList();
    let myID = bonkAPI.getMyID();
    // Reset the player selector
    posRecorder.reset_selector();
    // Add all player to the player selector
    playerList.forEach((player, id) => {
        if (player && id !== myID) {
            posRecorder.create_option(id);
        }
    });
};

bonkAPI.addEventListener('gameStart', (e) => {
    try {
        posRecorder.scale = e.mapData.physics.ppm;
    } catch (er) {
        console.log(er)
    }
});

// Event listener for when a user joins the game
bonkAPI.addEventListener("userJoin", (e) => {
    //console.log("User join event received", e);
    //console.log("User ID", e.userID);
    // Add the player to the player selector
    posRecorder.create_option(e.userID);
});

// Event listener for when a user leaves the game
bonkAPI.addEventListener("userLeave", (e) => {
    //console.log("User Leave event received", e);
    //console.log("User ID", e.userID);
    // Remove the player from the player selector
    let playerName = bonkAPI.getPlayerNameByID(e.userID);
    let player_selector = document.getElementById("posRecorder_player_selector");
    // If the player is the current player, set the current player to 0 and reset the selector
    if (player_selector.options[player_selector.selectedIndex].value === playerName) {
        posRecorder.currentPlayerID = bonkAPI.getMyID();
        // Set the selector to the first option as default
        player_selector.selectedIndex = 0;
    }

    posRecorder.remove_option(e.userID);
});

// Event listener for when user(mod user) creates a room
bonkAPI.addEventListener("createRoom", (e) => {
    //console.log("create Room event received", e);
    //console.log("User ID", e);
    // Set the player name in the player selector to the current user
    let option = document.getElementById("posRecorder_selector_option_user");
    let playerName = bonkAPI.getPlayerNameByID(e.userID);
    option.innerText = playerName;
    option.value = e.userID;
    posRecorder.currentPlayerID = e.userID;
    // Reset the player selector to the default state
    posRecorder.reset_selector();
});

// Event listener for when user(mod user) joins a room
bonkAPI.addEventListener("joinRoom", (e) => {
    //console.log("on Join event received", e);
    //console.log("User ID", e.userID);
    // Set the player name in the player selector to the current user
    let option = document.getElementById("posRecorder_selector_option_user");
    let playerName = bonkAPI.getPlayerNameByID(bonkAPI.getMyID());
    option.innerText = playerName;
    option.value = bonkAPI.getMyID();
    posRecorder.currentPlayerID = bonkAPI.getMyID();
    // Update the player list in the player selector
    posRecorder.update_players();
});

const startRecording = (e) => {

    try {

        posRecorder.recordingIntervalId = setInterval(() => {

            // posRecorder.inputState = e.inputState;
            posRecorder.currentData = posRecorder.inputState.discs[posRecorder.currentPlayerID];

            let currentX = window.posRecorder.currentData.x * posRecorder.scale - 365;
            let currentY = window.posRecorder.currentData.y * posRecorder.scale - 250;

            if (currentX !== undefined && currentY !== undefined) {
                // Round the positions to 2 decimal points
                currentX = currentX.toFixed(2);
                currentY = currentY.toFixed(2);

                posRecorder.positionData.push({
                    x: parseFloat(currentX),
                    y: parseFloat(currentY)
                });
                // console.log("In interval");
                // console.log("posData inside interval: ", posRecorder.positionData);
            }
        }, 10); // 100ms

    } catch (err) {
        console.error("Error during position recording:", err);

    }
};

bonkAPI.addEventListener("stepEvent", (e) => {
    if (posRecorder.isRecording) {
        posRecorder.inputState = e.inputState;

        if (!posRecorder.recordingIntervalId) {
            startRecording(e);
        } else {
            console.log("Recording is already in progress...");
        }

    }
});

posRecorder.xVel = null;
posRecorder.yVel = null;
posRecorder.isListeningToVelocity = false;
bonkAPI.addEventListener("stepEvent", (e) => {
    // Check if posRecorder and its necessary properties exist

    if (posRecorder.isListeningToVelocity) {

        posRecorder.inputState = e.inputState;
        posRecorder.currentData = posRecorder.inputState.discs[bonkAPI.getMyID()];


        // Null check for posRecorder.currentData and posRecorder.scale
        if (posRecorder.currentData && typeof posRecorder.currentData.xv !== 'undefined' && typeof posRecorder.currentData.yv !== 'undefined' && typeof posRecorder.scale !== 'undefined') {
            // Safely assign the velocity values after null checks
            posRecorder.xVel = posRecorder.currentData.xv * posRecorder.scale;
            posRecorder.yVel = posRecorder.currentData.yv * posRecorder.scale;

            // console.log(`xVel: ${posRecorder.xVel}, yVel: ${posRecorder.yVel}`);

        } else {
            console.warn('posRecorder.currentData or posRecorder.scale is null or undefined');
        }
    }

});




// Function to stop recording positions
const stopRecording = () => {
    // console.log("posData in stopRec: ", posRecorder.positionData);

    posRecorder.isRecording = false;
    copyPositionData();
    clearInterval(posRecorder.recordingIntervalId);
    posRecorder.recordingIntervalId = null;

    console.log("Recording stopped.");
};

function removeDuplicates(positionData) {
    return positionData.filter((value, index, self) =>
                               index === self.findIndex((t) => (
        t.x === value.x && t.y === value.y)));
}

// Function to copy position data to clipboard
const copyPositionData = () => {
    posRecorder.positionData = removeDuplicates(posRecorder.positionData);
    if (posRecorder.positionData && posRecorder.positionData.length > 0) {
        // Convert position data to JSON string
        const positionDataJson = JSON.stringify(posRecorder.positionData, null, 2);

        const textarea = document.createElement("textarea");
        textarea.value = positionDataJson;
        document.body.appendChild(textarea);

        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);

        console.log("Position data copied to clipboard!");

    } else {
        console.log("No position data to copy.");
        // alert("No position data to copy!");
    }
};

const addPkrDiv = () => {
    // Create the key table
    let pkrDiv = document.createElement("div");
    pkrDiv.innerHTML = `
    <div class="bonkhud-settings-row">
            <div id="pasteButtonContainer"></div>
            <div class="bonkhud-settings-label" style="margin-left: 5px;">(ALT + 1)</div>
        </div>
        <div class="bonkhud-settings-row">
            <select id="posRecorder_player_selector">
                <option id="posRecorder_selector_option_user">......</option>
            </select>
        </div>
        <div class="bonkhud-settings-row">
            <div id="recordButtonContainer"></div>
            <div class="bonkhud-settings-label" style="margin-left: 5px;">(ALT + 3)</div>
        </div>
        <div class="bonkhud-settings-row">
            <div id="copyMapButtonContainer"></div>
        </div>

    `;

    // Create the window before trying to append the button
    let pkrIndex = bonkHUD.createWindow(
        posRecorder.windowConfigs.windowName,
        pkrDiv,
        posRecorder.windowConfigs);

    bonkHUD.loadUISetting(pkrIndex);

    // Now that pkrDiv is in the DOM, find the container and append the buttons
    let recordButton = bonkHUD.generateButton("Start Recording");
    recordButton.style.marginBottom = "5px";
    recordButton.style.height = "25px";
    recordButton.id = "startRecordingButton";

    let recordButtonContainer = document.getElementById("recordButtonContainer");
    recordButtonContainer.appendChild(recordButton);

    let pasteButton = bonkHUD.generateButton("Paste Data and Start");
    pasteButton.style.marginBottom = "5px";
    pasteButton.style.height = "25px";
    pasteButton.id = "pasteDataStartButton";

    let pasteButtonContainer = document.getElementById("pasteButtonContainer");
    pasteButtonContainer.appendChild(pasteButton);

    let copyMapButton = bonkHUD.generateButton("Copy Map Data");
    copyMapButton.style.marginBottom = "5px";
    copyMapButton.style.height = "25px";
    copyMapButton.id = "copyMapButton";

    let copyMapButtonContainer = document.getElementById("copyMapButtonContainer");
    copyMapButtonContainer.appendChild(copyMapButton);
    copyMapButton.addEventListener("click", convertGameDataToJSON);

    // Function to toggle recording
    const toggleRecording = () => {
        if (!posRecorder.isRecording && bonkAPI.isInGame()) {
            posRecorder.isRecording = true;
            posRecorder.positionData = [];
            console.log("Recording started...");
            recordButton.textContent = "Stop and copy";
            recordButton.style.backgroundColor = "#4d0004";
        } else if (posRecorder.isRecording) {
            stopRecording();
            recordButton.textContent = "Start Recording";
            recordButton.style.backgroundColor = "#0B161C";
        }
    };

    recordButton.addEventListener("click", toggleRecording);

    document.addEventListener("keydown", (event) => {
        if (event.altKey && event.code === "Digit3") {
            toggleRecording();
        }
    });

    document.addEventListener("keydown", (event) => {
        if (event.altKey && event.code === "Digit1") {
            pasteAndStart();
        }
    });

    

    // Function to handle pasting data and starting the game
    const pasteAndStart = async() => {
        try {
            const text = await navigator.clipboard.readText();
            if (text.trim()) {
                await createAndSetMap(text);
                if (document.getElementById("newbonklobby").style.display === "none") {
                    window.parkourGenerator.keepPositions = false;
                }
                window.bonkHost.startGame();
            } else {
                Utils.showNotification("Clipboard is empty. Copy map data first.");
            }
        } catch (err) {
            console.error("Failed to read clipboard contents: ", err);
            Utils.showNotification("Failed to read clipboard.");
        }
    };

    pasteButton.addEventListener("click", pasteAndStart);
};

async function fetchRandomMapAndAuthorNames() {
    const url = `https://raw.githubusercontent.com/elder-tubby/parkour-gen-browser-script/refs/heads/main/map-data/mapAndAuthorNames.json?t=${Math.random() * 1000000}`;

    try {
        const response = await fetch(url);
        const mapAndAuthorNames = await response.json();

        // Get a random key from the map
        const keys = Object.keys(mapAndAuthorNames);
        const randomKey = keys[Math.floor(Math.random() * keys.length)];

        return {
            key: randomKey,
            value: mapAndAuthorNames[randomKey]
        };
    } catch (error) {
        console.error('Error fetching the JSON file:', error);
        return null; // Return null if an error occurs
    }
}

async function createAndSetMap(inputText) {
    try {
        const randomMapAndAuthor = await fetchRandomMapAndAuthorNames();

        const w = parent.frames[0];
        let gs = w.bonkHost.toolFunctions.getGameSettings();
        let map = w.bonkHost.bigClass.mergeIntoNewMap(
            w.bonkHost.bigClass.getBlankMap());
        // Parse the JSON input
        let inputData;
        try {
            if (typeof inputText === 'string') {
                inputData = JSON.parse(inputText);
            } else {
                inputData = inputText; // If it's already an object, just use it
            }
        } catch (error) {
            console.error('Error parsing JSON:', error);
        }
        // Extract spawn values
        const spawnX = inputData.spawn.spawnX;
        const spawnY = inputData.spawn.spawnY;

        const mapSize = getProcessedMapSize(inputData);

        map.m.a =
            w.bonkHost.players[
            w.bonkHost.toolFunctions.networkEngine.getLSID()
        ].userName;
        map.m.n = 'Generated Parkour';

        if (randomMapAndAuthor) {
            map.m.n = randomMapAndAuthor.key; // Assign the random key to map.m.n
            map.m.a = randomMapAndAuthor.value; // Assign the random value to map.m.a
        }

        // Set up shapes from the input data
        map.physics.shapes = inputData.lines.map(r => {
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
            body.fx = Array.apply(
                null,
                Array(Math.min(100, map.physics.shapes.length - i * 100))).map((_, j) => {
                return i * 100 + j;
            });
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
                fixture.n = r.id + '. CZ';
            } else if (r.isNoJump) {
                fixture.n = r.id + '. NoJump';
            } else if (r.noPhysics) {
                fixture.n = r.id + '. NoPhysics';
            } else {
                fixture.n = r.id + '. Shape';
            }

            return fixture;
        });

        map.physics.bro = map.physics.bodies.map((_, i) => i);

        // Add cap zones based on conditions
        inputData.lines.forEach(line => {
            if (line.isCapzone) {
                // Create a new cap zone object
                const newCapZone = {
                    n: line.id + '. Cap Zone',
                    ty: 1,
                    l: 0.01,
                    i: line.id,
                };

                // Access the existing capZones array and add the new cap zone
                map.capZones.push(newCapZone);
            }

            if (line.isNoJump) {
                // Create a new cap zone object for NoJump
                const newCapZoneNoJump = {
                    n: line.id + '. No=Jump',
                    ty: 2,
                    l: 10,
                    i: line.id,
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
                n: 'Spawn',
                priority: 5,
                r: true,
                x: spawnX,
                xv: 0,
                y: spawnY,
                ye: false,
                yv: 0,
            },
                         ];
        }

        map.s.nc = true;
        map.s.re = true;
        map.physics.ppm = mapSize;

        gs.map = map;
        w.bonkHost.menuFunctions.setGameSettings(gs);
        w.bonkHost.menuFunctions.updateGameSettings();

        Utils.showNotification('Map created successfully!');
    } catch (e) {
        console.error('An error occurred while creating the map:', e);
        // showNotification("Failed to create the map. Check the console for errors.");
    }
}

('use strict');

function transformMapSize(mapSize) {
    const mapSizeMapping = {
        1: 30,
        2: 24,
        3: 20,
        4: 17,
        5: 15,
        6: 13,
        7: 12,
        8: 10,
        9: 9,
        10: 8,
        11: 7,
        12: 6,
        13: 5
    };

    return mapSizeMapping[Math.floor(mapSize)] || 9; // Default to 9 if no match
}

function getProcessedMapSize(inputData) {
    if (!inputData.version) {
        // No version present, return mapSize as is
        return inputData.mapSize !== undefined ? inputData.mapSize : 9;
    }

    // If version exists, transform the mapSize
    return transformMapSize(inputData.mapSize);
}

function convertGameDataToJSON() {
    // Get the game settings’ map from the bonkHost.
    const w = parent.frames[0];
    const gameMap = w.bonkHost.toolFunctions.getGameSettings().map;
    const shapes = gameMap.physics.shapes;
    const fixtures = gameMap.physics.fixtures;
    const capZones = gameMap.capZones || [];
    const lines = [];

    const xOffsetForPkrGenrator = 935;
    const yOffsetForPkrGenrator = 350;

    // Create a map of capZones for quick lookup
    const capZoneMap = new Map();
    capZones.forEach(zone => {
        if (zone.ty === 1) {
            capZoneMap.set(zone.i, 'capzone');
        } else if (zone.ty === 2) {
            capZoneMap.set(zone.i, 'nojump');
        }
    });

    // Create a map to find the body a fixture belongs to
    const bodyMap = new Map();
    gameMap.physics.bodies.forEach(body => {
        body.fx.forEach(fixtureIndex => {
            bodyMap.set(fixtureIndex, body.p); // Store the body's position for each fixture
        });
    });

    // Create a map to find the body a fixture belongs to and store its bounciness
    const bodyBouncinessMap = new Map();
    gameMap.physics.bodies.forEach(body => {
        body.fx.forEach(fixtureIndex => {
            bodyBouncinessMap.set(fixtureIndex, body.s.re);
        });
    });

    // Loop through each fixture (assumed to match the shapes index-by-index)
    for (let i = 0; i < fixtures.length; i++) {

        // Get the body's position or default to [0, 0] if not found
        const bodyPos = bodyMap.get(i) || [0, 0];

        const fixture = fixtures[i];
        const shape = shapes[i];

        // Only consider rectangle shapes
        if (shape.type !== 'bx')
            continue;

        const id = i; // Assign unique ID iteratively


        // Adjust x and y based on body's position
        const x = shape.c[0] + bodyPos[0] + xOffsetForPkrGenrator;
        const y = shape.c[1] + bodyPos[1] + yOffsetForPkrGenrator;

        // Use the fixture name to determine special types.
        const isCapzone = capZoneMap.get(i) === 'capzone';

        // Convert the angle from radians back to degrees.
        const angle = shape.a * (180 / Math.PI);

        // Decide friction; if none, default to 0.
        const friction = fixture.fr ?? 0;

        // Determine if the platform is “bouncy”. When bounciness was null, it meant the platform is bouncy.

        // Get the body's bounciness or default to 0 if not found
        const bodyBounciness = bodyBouncinessMap.get(i) ?? 0;

        // Determine isBouncy based on body and fixture bounciness
        if (bodyBounciness > -0.95) {
            if (fixture.re === null || fixture.re === undefined) {
                isBouncy = true;
            } else {
                isBouncy = fixture.re > -0.95;
            }
        } else {
            if (fixture.re === null || fixture.re === undefined) {
                isBouncy = false;
            } else {
                isBouncy = fixture.re > -0.95;
            }
        }

        if (isCapzone) {
            isBouncy = false;
        }

        const isDeath = !!fixture.d;

        if (isDeath) {
            isBouncy = false;
        }

        const bounciness = isBouncy ? null : -1;

        // We infer isBgLine from the noPhysics flag.
        const noPhysics = fixture.np;
        const isBgLine = !!noPhysics;

        const isNoJump = capZoneMap.get(i) === 'nojump';
        // Other attributes that always default to false:
        const isOnlyForProgram = false;
        const isFloor = true;
        // Optionally, isFrame can be set; we set it to false as we lost that info.
        const isFrame = false;

        // Create the JSON object for this line.
        const line = {
            id: id,
            color: fixture.f, // same as fixture.f, but using shape is fine.
            bounciness: bounciness,
            isBouncy: isBouncy,
            isOnlyForProgram: isOnlyForProgram,
            friction: friction,
            isDeath: isDeath, // fixture.d was set from r.isDeath.
            isBgLine: isBgLine,
            noPhysics: noPhysics,
            // noGrapple: fixture.ng, // from r.noGrapple.
            noGrapple: true,
            isCapzone: isCapzone,
            x: x,
            y: y,
            width: shape.w,
            height: shape.h,
            angle: angle,
            isNoJump: isNoJump,
            isFrame: isFrame,
            isFloor: isFloor
        };

        lines.push(line);
    }

    // For spawn and mapSize we may take existing values if present or use dummy ones.
    const spawn = (gameMap.spawns && gameMap.spawns.length > 0)
    ? {
        spawnX: gameMap.spawns[0].x,
        spawnY: gameMap.spawns[0].y
    }
    : {
        spawnX: 0,
        spawnY: 0
    };

    const mapSize = transformMapSizeFromGameData(gameMap.physics.ppm) || 6; // Use the transformed map size


    // Build the final JSON output.
    const outputJSON = {
        spawn: spawn,
        mapSize: mapSize,
        lines: lines,
        version: 1
    };
    const jsonString = JSON.stringify(outputJSON, null, 2);

    // Create a temporary text area element to facilitate clipboard copying
    const textArea = document.createElement('textarea');
    textArea.value = jsonString;
    document.body.appendChild(textArea);

    // Select the text and copy it
    textArea.select();
    textArea.setSelectionRange(0, textArea.value.length); // For mobile devices
    document.execCommand('copy');

    // Clean up by removing the textarea from the DOM
    document.body.removeChild(textArea);

    // Log success
    console.log('JSON copied to clipboard successfully!');

    return outputJSON;
}

function transformMapSizeFromGameData(mapSize) {
    const mapSizeMapping = {
        1: 30,
        2: 24,
        3: 20,
        4: 17,
        5: 15,
        6: 13,
        7: 12,
        8: 10,
        9: 9,
        10: 8,
        11: 7,
        12: 6,
        13: 5
    };

    // Reverse the mapping: 1 -> 30 becomes 30 -> 1
    const reversedMap = Object.fromEntries(
        Object.entries(mapSizeMapping).map(([key, value]) => [value, parseInt(key)]));

    // Look up the new map size from the reversed map
    return reversedMap[mapSize] || 9; // Default to 9 if no match
}

let injector = str => {
    let newStr = str;

    ///////////////////
    // From host mod //
    ///////////////////

    const BIGVAR = newStr.match(/[A-Za-z0-9$_]+\[[0-9]{6}\]/)[0].split('[')[0];
    let stateCreationString = newStr.match(
        /[A-Za-z]\[...(\[[0-9]{1,4}\]){2}\]\(\[\{/)[0];
    let stateCreationStringIndex = stateCreationString.match(/[0-9]{1,4}/g);
    stateCreationStringIndex =
        stateCreationStringIndex[stateCreationStringIndex.length - 1];
    let stateCreation = newStr.match(
`[A-Za-z0-9\$_]{3}\[[0-9]{1,3}\]=[A-Za-z0-9\$_]{3}\\[[0-9]{1,4}\\]\\[[A-Za-z0-9\$_]{3}\\[[0-9]{1,4}\\]\\[${stateCreationStringIndex}\\]\\].+?(?=;);`)[0];
    stateCreationString = stateCreation.split(']')[0] + ']';

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

    const stateSetRegex = newStr.match(
        /\* 999\),[A-Za-z0-9\$_]{3}\[[0-9]{1,3}\],null,[A-Za-z0-9\$_]{3}\[[0-9]{1,3}\],true\);/)[0];
    newStr = newStr.replace(stateSetRegex, stateSetRegex + SET_STATE);
    return newStr;
};

if (!window.bonkCodeInjectors)
    window.bonkCodeInjectors = [];
window.bonkCodeInjectors.push(bonkCode => {
    try {
        return injector(bonkCode);
    } catch (error) {
        alert('Code injection for parkour generator failed');
        throw error;
    }
});

// Initialization logic to set up the UI once the document is ready
const init = () => {
    addPkrDiv();
    let playerSelector = document.getElementById("posRecorder_player_selector");
    if (playerSelector) {
        playerSelector.addEventListener("change", posRecorder.select_player);
    } else {
        console.error("posRecorder_player_selector element not found!");
    }
};

if (document.readyState === "complete" || document.readyState === "interactive") {
    init();
} else {
    document.addEventListener("DOMContentLoaded", init);
}
