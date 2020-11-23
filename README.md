# youtube-pu
Batch script to download, patch with github pull requests, compile and update youtube-dl from source.
## Dependecies
- [jq](https://stedolan.github.io/jq/download/)
- [curl](https://curl.se/download.html)
	- You already have it if you use Windows 10 version 1803 or newer.
- [git](https://git-scm.com/downloads)
- [python](https://www.python.org/downloads/)
	- The most recent available version will be used; not all versions are necessarily compatible with youtube-dl, I use python 3.9. Make sure you install the py launcher.
- [pyinstaller](https://www.pyinstaller.org/)
	- pyinstaller.exe must be in the default *Python\Scripts\\* folder ("Python" is the python installation folder). If you don't know what this is about, you are probably fine.
#### Optional:
- [cmdow](https://ritchielawrence.github.io/cmdow/)
	- Used to maximize the window, you can disable it in the configuration.
## Installation
Simply download the zip from the latest release and extract its contents somewhere. If the destination folder is contained in PATH you will be able to call youtube-pu as a command everywhere. **Make sure to edit the configuration file before using the script.**
## Usage
Simply write `youtube-pu` on the command line. The behavior of the command will be similar to `youtube-dl -U`, with the difference that the updated executable will be patched with the pull requests selected in the configuration file and compiled with the chosen python version.

In particular, the script will do several actions in the following order:
1. Check the local youtube-dl version and the latest release version.
	- If the local version corresponds with the version of the latest release, youtube-pu will display a message and exit.
	- If the local version is different or if youtube-dl is not present on the system, youtube-pu will ask you if you want to update/install.
2. Clone the source with git (the latest version tag, not the main branch).
3. Merge your copy of the source with the requested pull requests.
4. Compile youtube-dl.exe with pyinstaller.
5. Replace the current youtube-dl executable with the just compiled one.
6. Delete temporary files and exit.