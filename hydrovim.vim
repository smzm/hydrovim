:function HydrovimClean()
  :silent! execute "normal! ms"

  "Delete all hydrovim comment
  :silent! execute "g/^# /d" 

  "go back to the last position
  :silent! execute "normal! `s"
:endfunction


:function HydrovimRun()
  :call HydrovimClean()

  "get the current line
  :let current_line = line(".") 

  "put breakout() line before the command ran
  :execute "normal!"..current_line.."ggOprint('HydrovimStep')\<esc>"
  
  "create temp_hydrovim.py and put all the text were before line ran
  :silent execute "1,"..(current_line+1).."w! ~/.config/nvim/hydrovim/.temp_hydrovim.py" 
  
  "delete breakout from main code 
  :execute "normal! dd"

  "run code in temp_hydrovim and put the results in results_hydrovim file
  :let results = system('python3 ~/.config/nvim/hydrovim/.temp_hydrovim.py > ~/.config/nvim/hydrovim/.results_hydrovim 2>&1') 

  ":read !awk '$1 == '(Pdb)' {i=1;$1='  '} i{printf '# \t%s\n', $0}' ~/hydrovim/results_hydrovim
  "run awk command to pick the answer
  ":read !awk -f ~/.hydrovim/.awk_script ~/.hydrovim/.results_hydrovim

  :silent !sed -n '/HydrovimStep/,$p' ~/.config/nvim/hydrovim/.results_hydrovim > ~/.config/nvim/hydrovim/.results_hydrovim2
  :silent !sed  '/HydrovimStep/d' ~/.config/nvim/hydrovim/.results_hydrovim2 > ~/.config/nvim/hydrovim/.results_hydrovim3
  :read !awk '{print "\#    "$0}' ~/.config/nvim/hydrovim/.results_hydrovim3

:endfunction

nnoremap <F7> :call HydrovimClean()<cr>
nnoremap <F8> :call HydrovimRun()<cr>
inoremap <F8> <esc>:call HydrovimRun()<cr>
