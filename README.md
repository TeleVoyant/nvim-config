# Personal Development Environment

This is my neovim's PDE configurations, courtesy of [ThePrimeagen](https://www.youtube.com/@ThePrimeagen) who is definitely not working for Netflix.

#### Do Note that:
- This is "personal" dev environment.
- This is absolutely Not for beginners! Start [here](https://www.youtube.com/watch?v=w7i4amO_zaE&t=2s), but again, you do you :)
- This configuration works on my neovim v0.10.0-dev, with LuaJIT 2.1.0-beta3; your milleage may vary...

## Installation

#### For linux
- Open Terminal (Assuming you have git installed) and type the following:

```bash
git -C ~/.config clone git@github.com/TeleVoyant/nvim-config nvim
```
Do note that: if ```~/.cofig/nvim``` contains configurations (i.e. not empty), backup nvim as different folder name (eg: nvim.old) before running above comand.

- Then, on the Terminal, type the following:

```bash
cd ~/.config/nvim && nvim .
```
- Inside neovim, press [q] couple of times until you are on empty buffer (bottom line displays: ```1:1 Top```)

- Then hit ```<space>pf``` as fast as you can, this will launch neovim's netrw explorer.

- Now, navigate to ```lua``` (then [Enter]) > ```daniels``` (then [Enter]) > ```packer.lua``` (then [Enter])

- Inside packer.lua, type ```:so``` and hit [Enter]

- Then, type ```:PackerSync``` and hit [Enter] again.

Now sit back, relax; as packer fetches and installs plugins for you.

- When done, press [q] to quit packer pop-up, then type ```:q``` and hit [Enter] to quit neovim; then relaunch it again.


## License

[GNU General Public Licence version 3](https://choosealicense.com/licenses/gpl-3.0/)
