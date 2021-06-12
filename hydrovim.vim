let g:FileType = &filetype

:function HydrovimClean()
      :silent! execute "normal! ms"
      "Delete all hydrovim comment
      :if g:FileType == "python"
          :silent! execute "g/^# /d" 
      :elseif g:FileType == "javascript"
          :silent! execute "g/^// /d" 
      :endif
      "go back to the last position
      :silent! execute "normal! `s"
      " Clean command prompt after calling hydrovimClean function
      echo ""
:endfunction



:function HydrovimPython()

    :silent execute g:current_line.."w! ~/.config/nvim/hydrovim/.current_line.py"
    :let IsVariable = system("awk -e '/[a-zA-Z 0-9]=[a-zA-Z 0-9]/ {print $1}' ~/.config/nvim/hydrovim/.current_line.py")

    :if (l:IsVariable != "")
        :execute "normal! 0vt yoprint()\<esc>hp"
        
        "put 'Hydrovim running code to this line' after print(variable)
        :execute "normal!"..g:current_line.."ggoprint('Hydrovim running code to this line.')\<esc>"
        "create temp_hydrovim.py and put all the text were before line ran
         :silent execute "1,"..(g:current_line+2).."w! ~/.config/nvim/hydrovim/.temp_hydrovim.py" 
        "delete breakout from main code 
        :execute "normal! dd"
        :execute "normal! dd"
        :execute "normal! k"
    :else
        "put 'Hydrovim running code to this line' before the command ran
        :execute "normal!"..g:current_line.."ggOprint('Hydrovim running code to this line.')\<esc>"
        "create temp_hydrovim.py and put all the text were before line ran
        :silent execute "1,"..(g:current_line+1).."w! ~/.config/nvim/hydrovim/.temp_hydrovim.py" 
        "delete breakout from main code 
        :execute "normal! dd"
    :endif

    "run code in temp_hydrovim.py and put the results in results_hydrovim file
    :let results = system('python ~/.config/nvim/hydrovim/.temp_hydrovim.py > ~/.config/nvim/hydrovim/.results_hydrovim_py 2>&1') 
    ":read !awk '$1 == '(Pdb)' {i=1;$1='  '} i{printf '# \t%s\n', $0}' ~/hydrovim/results_hydrovim
    "run awk command to pick the answer
    ":read !awk -f ~/.hydrovim/.awk_script ~/.hydrovim/.results_hydrovim
    :silent !sed -n '/Hydrovim running code to this line./,$p' ~/.config/nvim/hydrovim/.results_hydrovim_py > ~/.config/nvim/hydrovim/.results_hydrovim2_py
    :silent !sed  '/Hydrovim running code to this line./d' ~/.config/nvim/hydrovim/.results_hydrovim2_py > ~/.config/nvim/hydrovim/.results_hydrovim3_py
    :read !awk '{print "\#    "$0}' ~/.config/nvim/hydrovim/.results_hydrovim3_py
:endfunction



:function HydrovimJavascript()
  "put HydrovimStep line before the command ran
  :execute "normal!"..g:current_line.."ggOconsole.log('Hydrovim running code to this line.')\<esc>"
  "create temp_hydrovim.js and put all the text were before line ran
  :silent execute "1,"..(g:current_line+1).."w! ~/.config/nvim/hydrovim/.temp_hydrovim.js" 
  "delete breakout from main code 
  :execute "normal! dd"
  "run code in temp_hydrovim.py and put the results in results_hydrovim file
  :let results = system('node ~/.config/nvim/hydrovim/.temp_hydrovim.js > ~/.config/nvim/hydrovim/.results_hydrovim_js 2>&1') 
  :silent !sed -n '/Hydrovim running code to this line./,$p' ~/.config/nvim/hydrovim/.results_hydrovim_js > ~/.config/nvim/hydrovim/.results_hydrovim2_js
  :silent !sed  '/Hydrovim running code to this line./d' ~/.config/nvim/hydrovim/.results_hydrovim2_js > ~/.config/nvim/hydrovim/.results_hydrovim3_js
  :read !awk '{print "//    "$0}' ~/.config/nvim/hydrovim/.results_hydrovim3_js
:endfunction



:function HydrovimRun()
    :call HydrovimClean()

    "get the current line
    :let g:current_line = line(".") 

    :if g:FileType == "python"
        :call HydrovimPython()
    :elseif g:FileType == "javascript"
        :call HydrovimJavascript()
    :endif

    " Clean command prompt after calling hydrovimRun function
    echo ""
  :endfunction


nnoremap <silent> <F7> :call HydrovimClean() <cr><cr>
nnoremap <silent> <F8> :call HydrovimRun()<cr><cr>
inoremap <silent> <F8> <esc>:call HydrovimRun()<cr><cr>

