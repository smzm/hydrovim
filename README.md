# Hydrovim
a plugin can run Python and Javascript code and put the result inside your code in vim (neovim)

## Manually installation:
Clone repo in vim or nvim configuration directory.ex: 
```
cd ~/.config/nvim/
git clone https://github.com/smzm/hydrovim.git
```

source the address to the init.vim file or vimrc

for ex. nvim inside init.vim file add this line code:
``` 
source $HOME/.config/nvim/hydrovim/hydrovim.vim
```

* use F8 for run your code and F7 for cleaning the result

#### Be Sure installed python and node before.
hydrovim use ```python``` and ```node``` alias for run codes.
