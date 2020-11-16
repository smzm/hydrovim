:function Digging()
  
  :execute "normal! ms"
  
  "Delete all hydrovim comment
  :execute "g/^# /d" 
  
  "go back to the last position
   :execute "normal! `s"
  
  "get the current line
  :let current_line = line(".") 

  "put breakout() line before the command ran
  :execute "normal!"..current_line.."ggObreakpoint()\<esc>" 
  
  "create temp_hydrovim.py and put all the text were before line ran
  :execute "1,"..(current_line+1).."w! ~/.hydrovim/.temp_hydrovim.py" 
  
  "delete breakout from main code 
  :execute "normal! dd"

  "run code in temp_hydrovim and put the results in results_hydrovim file
  :let results = system('python ~/.hydrovim/.temp_hydrovim.py > ~/.hydrovim/.results_hydrovim 2>&1','continue') 

  ":read !awk '$1 == '(Pdb)' {i=1;$1='  '} i{printf '# \t%s\n', $0}' ~/hydrovim/results_hydrovim
  "run awk command to pick the answer
  :read !awk -f ~/.hydrovim/.awk_script ~/.hydrovim/.results_hydrovim

  ""delete Pdb text from beginning of results
  :execute "normal \<esc>". current_line. "ggjf(6x" 

 :endfunction

 map <F4> :call Digging()<cr>
