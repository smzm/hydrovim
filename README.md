# Hydrovim
A plugin can run Python and Javascript code and put the result inside your code editor(vim or nvim) as comments.

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

3. Add 

```diff
+ syntax on
```
to the top of your `init.vim` file. (or vimrc file)

<br>

- #### Use ```F8``` for running hydrovim and ```F7``` for cleaning the result.

<br>

- ###### Be Sure installed python and node before
hydrovim use ```python``` and ```node``` aliases for running codes.
