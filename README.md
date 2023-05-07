<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="100" />

# Hydrovim
A **Neovim** plugin that runs ***Python*** code and displays the result in your code editor.


![hydrovim](https://user-images.githubusercontent.com/39596095/185785721-00bbf151-697a-4ffa-9692-5589463be80c.png)

##  🎞️ Demo 
https://user-images.githubusercontent.com/39596095/185796284-4904327b-ae0d-4dfc-ba40-7448eba9009e.mp4



<br>
<br>

##  ✅ Installation

- ### Prerequisite
Install [nui](https://github.com/MunifTanjim/nui.nvim) nvim plugin :
```vim
Plug 'MunifTanjim/nui.nvim'
```

##### 🔖 Also be Sure `python` and `awk` is installed.
> hydrovim use ```python``` command and `awk` for running codes.

<br>

### Installing `hydrovim` :
For installing with vim plug : 
```vim
Plug 'smzm/hydrovim'
```

<br>

## ❗️Issue : 
This plugin tested only with Vim and Neovim which configured with `.vim` files. Some people can't use Hydrovim when configured Neovim with `Lua`.


<br>
<br>

## ✅ Usage : 
- Put the cursor on the desire line of code and press `F8` for running hydrovim from ***first line*** of your code to the ***current line*** and show the result of the current line in the Hydrovim pop-up.
- You can highlight code in visual mode and run hydrovim with `F8`.
- Use `q` or `F8` key again for close hydrovim pop-up.


<br>

## 👾 Troubleshooting : 
If with pressing `F8` hydrovim popup doesn't appear, First Check prerequisites in your terminal : 
1. `awk` command should be available.
2. `python` command should be available. (`python` is the command use in hydrovim not `python3`)
3. [`MunifTanjim/nui.nvim`](https://github.com/MunifTanjim/nui.nvim) should installed in your neovim.

👉 Put `syntax on` in top of your neovim configuration file. (before hydrovim installation)

