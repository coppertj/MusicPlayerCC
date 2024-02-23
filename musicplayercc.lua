local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")


-- Initial Boot Setup Script
local basaltExists = fs.exists("basalt.lua")
local musicDir = "/music"
local configFilePath = "/config.txt"
local defaultConfig = {
    chunkSize = 1024*6, -- Default chunk size
}


local function downloadAndRunInstaller(url, ...)
    local args = {...}  -- Capture any additional arguments to pass to the script

    -- Use http.get to fetch the script
    local response = http.get(url)
    if not response then
        error("Failed to download the installer script")
    end

    local scriptContent = response.readAll()
    response.close()

    -- Use loadstring to load the script content. 
    -- Note: loadstring is available in Lua 5.1, but in newer versions, load may be used.
    local script, errorMessage = loadstring(scriptContent)
    if not script then
        error("Failed to load the installer script: " .. errorMessage)
    end

    -- Execute the loaded script, passing any additional arguments
    script(table.unpack(args))
end


-- Function to check and install Basalt
local function installBasalt()
    if not basaltExists then
        print("Basalt not found. Attempting to download...")
        downloadAndRunInstaller("https://basalt.madefor.cc/install.lua", "release", "latest.lua")
        print("Basalt installed successfully.")
    else
        print("Basalt is already installed.")
    end
end

-- Function to create the music directory if it doesn't exist
local function createMusicDirectory()
    if not fs.exists(musicDir) then
        fs.makeDir(musicDir)
        print("Music directory created.")
    else
        print("Music directory already exists.")
    end
end

-- Function to create or update the configuration file
local function createOrUpdateConfig()
    local configData = textutils.serialize(defaultConfig)
    local configFile = fs.open(configFilePath, "w")
    configFile.write(configData)
    configFile.close()
    print("Configuration file created/updated.")
end

-- Main function to run the initial setup
local function runInitialSetup()
    installBasalt()
    createMusicDirectory()
    createOrUpdateConfig()
	if basaltExists == false then
	term.clear()
    print("Initial setup completed.")
	print("Program is terminating to allow user upload of music.")
	print("Use the /music/ folder created for music storage.")
	print("Sub folders are supported to allow for user organization")
	print("Thank you for using this program and enjoy!")
	print()
	print("-coppertj")
	os.sleep(5)
	error()
end
end

-- Execute the initial setup
runInitialSetup()







-- Ensure these are initialized at the start of your script
local basalt = require("basalt")
local isPaused = false
local lastChunkData = nil 
local currentPosition = 1
local playbackStarted = false
local trackStartTime = 0
local backPressedOnce = false
local basalt = require("basalt")
local breakit = false
local main = basalt.createFrame()

local screenWidth, screenHeight = main:getSize()
local numBars = 16  -- Number of bars in the visualizer
local barWidth = 1  -- Width of each bar (1 character)
local visualizerHeight = 10  -- Max height of the visualizer
local visualizerStartX = math.floor((screenWidth - (numBars * barWidth)) / 2)
local visualizerStartY = screenHeight - visualizerHeight - 5  -- Position above the bottom buttons

local buttonWidth = screenWidth / 4
local buttonHeight = 3 -- Height of buttons
local spacing = (screenWidth - (buttonWidth * 3)) / 4
local startY = screenHeight - buttonHeight - 1 -- Y position for buttons
local returnToMenu = false
-- Define rootFolder where your music files are located
local rootFolder = "/music/"
local shuffleEnabled = false
-- Function to read the contents of a folder and return the filenames as a table
function readFolderContents(folderPath)
    local fileNames = {}
    for _, file in ipairs(fs.list(folderPath)) do
        table.insert(fileNames, file)
    end
    return fileNames
end

-- Shuffle State Label
local shuffleStateLabel = main:addLabel()
    :setText("Shuffle: Off")
    :setPosition(12, 2) -- Adjust to position next to the shuffle button
    :setSize(15, 1)

local function updateShuffleStateLabel()
    if shuffleEnabled then
        shuffleStateLabel:setText("Shuffle: On")
    else
        shuffleStateLabel:setText("Shuffle: Off")
    end
    -- Refresh the frame to show the updated label text if necessary
end

local function onShufflePressed()
speaker.playSound("ui.button.click", 0.5)
    shuffleEnabled = not shuffleEnabled
	updateShuffleStateLabel()
end


-- Assuming you have variables for spacing and startY like before
-- Adjust these values as needed to position your shuffle button
local shuffleButtonX = 10  -- Adjust based on your layout, for example, placing it at the top left
local shuffleButtonY = 20  -- Adjust based on your layout, perhaps just below the top edge




-- Initialize fileList using the readFolderContents function



-- File Explorer
local mainFrame = basalt.createFrame("firstBaseFrame"):show()
local fileList = mainFrame:addList()
    :setPosition(2, 2)
    :setSize(20, 15) -- Adjust size as needed

local function updateFileList(path)
    fileList:clear() -- Clear the list for new directory contents
    local files = fs.list(path) -- Use the passed 'path' parameter
    for _, file in ipairs(files) do
        fileList:addItem(file) -- Add each file or directory to the list
    end
end

fileList:onSelect(function(self, event, item)
    if item and item.text then
        local selectedFileName = item.text
        local selectedItemPath = fs.combine(rootFolder, selectedFileName)

        if fs.isDir(selectedItemPath) then
            -- Navigate into the directory
            rootFolder = selectedItemPath .. "/" -- Update the rootFolder to the new path
            updateFileList(rootFolder) -- Update the list to show contents of the selected directory
        else
            -- Handle file selection
            basalt.setActiveFrame(main) -- Switch to the playback frame
                        parallel.waitForAny(
                function() mainLoop(selectedItemPath) end, -- Play the selected file
                waitForUserInput -- Continue listening for user input
            )
        end
    end
end)




-- Add any additional UI elements like a back button here




local function togglePauseState()
speaker.playSound("ui.button.click", 0.5)
    isPaused = not isPaused

end

local function onPlaybackPressed()
speaker.playSound("ui.button.click", 0.5)
            local currentTime = os.clock()
            if backPressedOnce and (currentTime - trackStartTime) <= 3 then
                -- If back button is pressed twice within 3 seconds, go to the previous song
                currentPosition = math.max(1, currentPosition - 1)
                backPressedOnce = false  -- Reset the flag
            else
                -- If pressed once or after 3 seconds, restart the current song or go to the previous song
                if (currentTime - trackStartTime) > 3 then
                    -- Consider as a request to go back if beyond the threshold
                    currentPosition = math.max(1, currentPosition - 1)
                end
                backPressedOnce = true  -- Set the flag for the first press
                trackStartTime = currentTime  -- Update start time to prevent immediate trigger
            end
			breakit = true
              -- Exit to restart the current song or go to the previous song
end


local playedTracks = {}
local fileLister = readFolderContents(rootFolder)
function shuffleTrack()
    -- Reset shuffle if all tracks have been played
    if tablelength(playedTracks) >= #fileLister then
        playedTracks = {}  -- Clear played tracks for reshuffle
        -- Optional: Return to the menu or start shuffle again
    end

    local nextTrack
    repeat
        nextTrack = math.random(1, #fileLister)
    until not playedTracks[nextTrack]

    playedTracks[nextTrack] = true
    currentPosition = nextTrack  -- Update current position for shuffle track
    return true
end


local function onSkipPressed()
speaker.playSound("ui.button.click", 0.5)

        -- If shuffle is not enabled, simply move to the next track in order
        
        if currentPosition > #fileLister then
            currentPosition = 1 -- Optionally loop back to the start or stop playback
        end

	breakit = true
end

local bars = {}

for i = 1, numBars do
    local xPosition = visualizerStartX + (i - 1) * barWidth
    bars[i] = main:addLabel()
        :setPosition(xPosition, visualizerStartY)
        :setSize(barWidth, visualizerHeight)
        :setText("|")
end

local labelYPosition = visualizerStartY + 7  -- Position the label above the visualizer, adjust as needed
local trackLabel = main:addLabel()
    :setPosition(1, labelYPosition)
    :setSize(screenWidth, 5)
    :setText("")


local function onMainMenuButtonPressed()
speaker.playSound("ui.button.click", 0.5)
	breakit = true
	returnToMenu = true
	rootFolder = "/music/"
	updateFileList(rootFolder)
        basalt.setActiveFrame(mainFrame)
        mainFrame:show()
        main:hide()
		basalt.update()
		-- Initialize the list with contents from the starting directory

end

function waitForUserInput()
	breakit = false
	returnToMenu = false
			basalt.setActiveFrame(main)
			main:show()
			mainFrame:hide()
			basalt.update()
    while true do
	if returnToMenu == true then 
	        basalt.setActiveFrame(mainFrame)
        main:show()
        mainFrame:hide()
		basalt.update()
		-- Initialize the list with contents from the starting directory
	break 
	end
	-- Creating buttons
-- Create the main menu button at the top left corner of the screen
local mainMenuButton = main:addButton()
    :setText("=")
    :setPosition(1, 1)  -- Top left corner
    :setSize(3, 1)  -- Adjust size as needed
    :onClick(onMainMenuButtonPressed)






-- Create the shuffle button with a smaller size
local shuffleButton = main:addButton()
    :setText("Shuffle")
    :setPosition(shuffleButtonX, shuffleButtonY)
    :setSize(7, 1)  -- Smaller width and standard height for a single character
    :onClick(onShufflePressed)
	
	
-- Playback Button
local playbackButton = main:addButton()
    :setText("<")
    :setPosition(spacing * 2, startY)
    :setSize(buttonWidth, buttonHeight)
    :onClick(onPlaybackPressed)

-- Pause Button
local pauseButton = main:addButton()
    :setText("||")
    :setPosition(spacing * 3 + buttonWidth, startY)
    :setSize(buttonWidth, buttonHeight)
    :onClick(togglePauseState)

-- Skip Button
local skipButton = main:addButton()
    :setText(">")
    :setPosition(spacing * 4 + buttonWidth * 2, startY)
    :setSize(buttonWidth, buttonHeight)
    :onClick(onSkipPressed)
for i = 1, numBars do
    local height
    if isPaused then
        height = 1  -- Set height to 0 to clear the bars if paused
    else
        height = math.random(1, visualizerHeight)  -- Otherwise, set a random height
    end
    local barText = string.rep("|", height) .. string.rep(" ", visualizerHeight - height)
    bars[i]:setText(barText)
end

            local ev = table.pack(os.pullEventRaw())
            basalt.update(table.unpack(ev))
end

end


local function updateShuffleStateLabel()
    if shuffleEnabled then
        shuffleStateLabel:setText("Shuffle: On")
    else
        shuffleStateLabel:setText("Shuffle: Off")
    end
    -- Refresh the frame to show the updated label text if necessary
end




-- Updated function to play a DFPWM file, incorporating pause logic
function playSound(filePath)
breakit = false
trackStartTime = os.clock()
    local file = fs.open(filePath, "rb")
    if not file then
        return
    end

    local decoder = dfpwm.make_decoder()
    local chunkData, buffer
    local fileName = filePath:match("^.+/(.+)$") or filePath  -- Pattern extracts the name after the last slash
    trackLabel:setText(fileName)  -- Update the label text with the current file name
    
    while true do
	if breakit == true then break end
        if isPaused then
            os.sleep(0.5)  -- Simple pause handling
        else
            chunkData = file.read(1024*16)
            if not chunkData then break end  -- End of file
            buffer = decoder(chunkData)

            while not speaker.playAudio(buffer) do
                if isPaused then
                    lastChunkData = chunkData  -- Save the chunk data if paused mid-playback
                    break
                end
                os.pullEvent("speaker_audio_empty")
            end
        end

end
    file.close()
end

-- Main playback loop
-- Initialize playedTracks outside the main loop to track played files across shuffle iterations
local playedTracks = {}

-- Main playback loop
function mainLoop(initialTrackPath)
    fileLister = readFolderContents(rootFolder)

    if initialTrackPath then
        -- Directly play the provided track
        playSound(initialTrackPath)
        -- Find and set currentPosition for the next track
        for index, fileName in ipairs(fileLister) do
            local filePath = fs.combine(rootFolder, fileName)
            if filePath == initialTrackPath then
                currentPosition = index + 1
                break
            end
        end
    end

    -- Check if shuffle is enabled and reset playedTracks if necessary
    if shuffleEnabled and #playedTracks == #fileLister then
        playedTracks = {} -- Reset after all tracks have been played
    end

    while currentPosition <= #fileLister do
        if returnToMenu then break end

        local fileName = fileLister[currentPosition]
        local filePath = fs.combine(rootFolder, fileName) -- Correctly combine paths

        if shuffleEnabled then
            local nextTrack
            repeat
                nextTrack = math.random(1, #fileLister)
            until not playedTracks[nextTrack] or #playedTracks == #fileLister

            playedTracks[nextTrack] = true
            currentPosition = nextTrack
            filePath = fs.combine(rootFolder, fileLister[currentPosition]) -- Update filePath for shuffle
            playSound(filePath)
        else
            playSound(filePath)
            currentPosition = currentPosition + 1
        end

        if currentPosition > #fileLister and not shuffleEnabled then
            	breakit = true
	returnToMenu = true
        basalt.setActiveFrame(mainFrame)
        mainFrame:show()
        main:hide()
		basalt.update()
		-- Initialize the list with contents from the starting directory
updateFileList("/music/")

            break
        end
    end
end


updateFileList(rootFolder)
basalt.autoUpdate()
