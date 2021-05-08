# Hydrovim
A plugin can run Python and Javascript code and put the result inside your code as comments.

<br>

## Manually installation:
- #### Clone repo in vim or nvim configuration directory.
 
*For example in neovim:*
```
cd ~/.config/nvim/
git clone https://github.com/smzm/hydrovim.git
```
<br>

- #### Source the address to the init.vim file or vimrc file.

*For example in neovim go to init.vim and add this :*
  
``` 
source $HOME/.config/nvim/hydrovim/hydrovim.vim
```

<br>

- #### Use ```F8``` for running hydrovim and ```F7``` for cleaning the result.

<br>

- ###### Be Sure installed python and node before
hydrovim use ```python``` and ```node``` alias for running codes.
