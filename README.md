MusicPlayerCC

MusicPlayerCC is an open-source music player designed for ComputerCraft, leveraging the Lua programming language to bring a versatile and user-friendly audio experience to Minecraft. This project is currently in a proof of concept stage, demonstrating core functionalities such as file browsing, audio playback, and dynamic user interface elements. I believe in the potential of MusicPlayerCC to evolve significantly through community involvement and contributions.

Features:

    Audio playback from in-game computers (targeted computer is the noisy portable computer)
    File system browsing within the game
    Shuffle and repeat functionalities
    User-configurable settings for performance optimization
    Extensible design for future features and improvements

Prerequisites:

    Minecraft with the ComputerCraft mod installed
    Internet access within the game to download the MusicPlayerCC files
    Computercraft server config setup correctly for HTML support and file upload support.
    Music files in the DFPWM format (I recommend https://music.madefor.cc/ for converting)

Installation:

    Start by opening your in-game computer terminal.
    Use the following command to install MusicPlayerCC: wget https://path-to-musicplayercc/install.lua <file name>
    For the file name I recommend startup if it's a standalone device like a Advanced Noisy Pocket Computer. To utilize the Basalt API it does have to atleast be a advanced computer.
    Run the Program and it will auto install the Basalt API aswell as create the music folder and a config file (that is currently useless as this is a proof of concept release)

How to Use

After running the program for the first time for its initial setup you are going to want to navigate to the music folder using "cd music". Once you are in the music folder directory that is the program's root directory that it will search for music. 

It does support sub folders so you can organize music based on Albums, Artists, etc., as long as it's contained within the music folder.

The sound files it supports are the DFPWM format this can be converted from most standard audio formats using a site such as https://music.madefor.cc/

To upload sound files computercraft supports drag and dropping into the minecraft window from your actual computer as long as you have the computer terminal active ingame. The important part is just making sure you are inside the music folder when you do this.

Once you have the files uploaded you just go back to the root folder and run the program, the GUI file explorer inside the program will handle the rest for you. Just select the file you want to play first and the rest should be self explanatory. To return to the file explorer press the = button on the top left of the player.


I warmly welcome contributions from the community. Whether you're fixing bugs, adding new features, improving the documentation, or sharing ideas, your help is invaluable as I am just one person.

Future Features:

-Open Noteblock Studio support

-Actual sound visualizer

-Metadata creation for track order per folder/subfolder

-Global shuffle that will play the entire music folder and subfolders

-Options menu for buffer size (improves audio quality/performance at the cost of accurate pause/skip/repeat button detection)

-HTML streaming from webserver

-More refined file explorer GUI


Known Bugs:

-When computer is under intense load music will get louder and louder as it lags. This could be linked to server performance or unoptimized code, could also be linked to the buffer size. (This is only a proof of concept this initial version).



This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details. This ensures that the project remains free and open-source, allowing anyone to modify and distribute their versions as long as they don't profit from it commercially.
Acknowledgments

    Thanks to the ComputerCraft community for their invaluable resources and support aswell as the Basalt team for their amazing API!
    Special thanks to all contributors and future contributors who help improve MusicPlayerCC.

Contact

For questions, suggestions, or collaborations, please open an issue in the GitHub repository or contact me directly on discord (username coppertj)
