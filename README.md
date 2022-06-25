# Hydrovim
A plugin for vim(nvim) can run Python code and show the result inside your code editor.

<br>

## Prerequisite
Install [nui](https://github.com/MunifTanjim/nui.nvim) nvim plugin
```vim
Plug 'MunifTanjim/nui.nvim'
```

<br>

## Manually installation:

1. #### Clone repo in vim or nvim configuration directory.
 
*For example in neovim:*
```
cd ~/.config/nvim/
git clone https://github.com/smzm/hydrovim.git
```
<br>

2. #### Source the address to the init.vim file or vimrc file.

*For example in neovim go to init.vim and add this :*
  
``` 
source $HOME/.config/nvim/hydrovim/hydrovim.vim
```


<br>

- #### Use ```F8``` for running hydrovim .

<br>

- ###### Be Sure installed python and node before
hydrovim use ```python``` aliases for running codes.
