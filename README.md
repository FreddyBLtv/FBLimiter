
<h1 align="center">FBLimiter</h1>
<div align="center">

**A shell script that automates the setup of battery limit profiles on the Steam Deck, providing users with greater control over their device's power consumption and battery life.**

[![Main](https://img.shields.io/badge/Maintainer-FreddyBLtv-green?style=flat-square)](https://github.com/FreddyBLtv)
![Main](https://img.shields.io/badge/OS-SteamOS-blue?style=flat-square)

</div>

<h1 align="left">
	Installation
</h1>

* Switch to Desktop Mode.
* Open a terminal.
* Clone the repository or download the script to your local machine.

```sh
git clone https://github.com/FreddyBLtv/FBLimiter_On_Steam_Deck.git
```
* Navigate into the cloned repository.

```sh
cd FBLimiter_On_Steam_Deck
```
* Make the script executable.

```sh
sudo chmod +x install.sh
```
* Run the installation script.

```sh
./install.sh
```

<h1 align="left">
	Usage
</h1>

* After running the installation script, go to your Desktop and run FBLimiter, follow the prompts, input your password, then select how many profiles you want from a range of 1-3, input the battery limit percentage from a range of 1-100 for each profile, then wait for the "FBLimiter has been installed successfully!' message before closing the terminal. Your battery profiles should be available in Steam. Switch to game mode, then navigate to non-Steam games in your library and launch the profile.

<!--  
<h1 align="left">
	Uninstall
</h1>

* Open a terminal and navigate into the cloned repository.

```sh
cd /home/deck/FBLimiter_On_Steam_Deck
```
* Make the script executable.

```sh
sudo chmod +x uninstall.sh
```
* Run the uninstall script.

```sh
./uninstall.sh
```
* Manually delete all the profile shortcuts on Steam
''
-->
