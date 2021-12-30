let g:FileType = &filetype

":function HydrovimClean()
"      :silent! execute "normal! ms"
"      "Delete all hydrovim comment
"      :if g:FileType == "python"
"          :silent! execute "g/^#  /d" 
"      :elseif g:FileType == "javascript"
"          :silent! execute "g/^//  /d" 
"      :endif
"      "go back to the last position
"      :silent! execute "normal! `s"
"      " Clean command prompt after calling hydrovimClean function
"      echo ""
":endfunction



:function HydrovimPython()
    
    " this variable is a flag . if will be 1 hydrovim execute
    let g:HydrovimRunned = 0

    " put the current line (The line should executed) inside '.current_line.py'
    :silent execute g:current_line.."w! ~/.config/nvim/hydrovim/.current_line.py"
    " Put from first line until the current line (The line should executed) inside 'from_first_until_current.py'
    :silent execute "1,"..(g:current_line-1).."w! ~/.config/nvim/hydrovim/.from_first_until_current.py"

    " clean the current line from the comment
    :silent ! awk -f ~/.config/nvim/hydrovim/.awk_script_for_cleaning ~/.config/nvim/hydrovim/.current_line.py > ~/.config/nvim/hydrovim/.current_line_clean.py


    " check the current line is a Variable, a print statement, or an unknown statemnet
    :let l:IsVariable = system("awk -f ~/.config/nvim/hydrovim/.awk_script_for_variable_statement_split1 ~/.config/nvim/hydrovim/.current_line_clean.py | awk -f ~/.config/nvim/hydrovim/.awk_script_for_variable_statement_split2")
    :let l:IsPrint = system("awk -e '$1 ~ /^print/ {print $1}' ~/.config/nvim/hydrovim/.current_line_clean.py")


    " ================= Variable Statement ======================    
    " if awk can find '=' in statement it is a variable
    :if (l:IsVariable != "") 
        
        let g:HydrovimRunned = 1

        " Add the current line to the end of '.from_first_until_current.py' file 
        :silent ! cat ~/.config/nvim/hydrovim/.current_line_clean.py >> ~/.config/nvim/hydrovim/.from_first_until_current.py

        " Add 'print('Hydrovim running code to this line.')' to the end of '.from_first_until_current.py' file
        :silent ! echo "print('Hydrovim running code to this line.')" >> ~/.config/nvim/hydrovim/.from_first_until_current.py

        " Add 'print(l:IsVariable)' to the end of '.from_first_until_current.py' file. 
        :silent ! current_line_hydrovim=`awk -f ~/.config/nvim/hydrovim/.awk_script_for_variable_statement_split1 ~/.config/nvim/hydrovim/.current_line_clean.py | awk -f ~/.config/nvim/hydrovim/.awk_script_for_variable_statement_split2 | tr -d '[:space:]'` ; echo "print($current_line_hydrovim)" >> ~/.config/nvim/hydrovim/.from_first_until_current.py



    " ================= Print Statement ======================    
    " if awk can find 'print' in the first characters of statement it is a print statement
    :elseif(l:IsPrint != "")

        let g:HydrovimRunned = 1


        "put 'Hydrovim running code to this line' before the command ran
        :silent ! echo "print('Hydrovim running code to this line.')" >> ~/.config/nvim/hydrovim/.from_first_until_current.py

        " Add the current line to the end of '.from_first_until_current.py' file
        :silent ! cat ~/.config/nvim/hydrovim/.current_line_clean.py >> ~/.config/nvim/hydrovim/.from_first_until_current.py


    


    " ================= UNKNOWN Statement ======================    
    " if awk can't  find any   '=' or 'print' in the statement put inside a print(<statement>)
    :else
          " check the current line it's not a function, class, for, if ,... or anything finished with --> ':'
          :let l:Is_func = system("awk -e '$NF ~ /:$/ {print $0}' ~/.config/nvim/hydrovim/.current_line_clean.py")
          

          " put the one to the last inside '.multiline_text.py' for executing multiple line defining variable 
           :silent execute (g:current_line-1).."w! ~/.config/nvim/hydrovim/.one_before_last_line.py"
           :let l:Lastline_of_multiline = system("awk -e '$NF ~ /,$/ {print $0}' ~/.config/nvim/hydrovim/.one_before_last_line.py")


           " check the multiline defining variable ends with ','
           :let l:Is_multiline = system("awk -e '$NF ~ /,$/ {print $0}' ~/.config/nvim/hydrovim/.current_line_clean.py")


           " Check the Statement is 'import' module
           :let l:IsImport = system("awk -e '/^import|from\s/ {print $0}' ~/.config/nvim/hydrovim/.current_line_clean.py")


            
           " ---------- it's not a function or class or for ,... and also not a multiline statement
           :if (l:Is_func == ""  && l:Is_multiline == "" && l:Lastline_of_multiline == "" && l:IsImport == "")
             :let g:HydrovimRunned = 1
             execute "normal! o" . l:IsImport 


             :silent !  echo "print('Hydrovim running code to this line.')" >> ~/.config/nvim/hydrovim/.from_first_until_current.py
             :silent ! current_line_hydrovim=`sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' ~/.config/nvim/hydrovim/.current_line_clean.py`;echo "print($current_line_hydrovim)" >> ~/.config/nvim/hydrovim/.from_first_until_current.py


           :endif
    :endif
:endfunction



:function HydrovimExec()
" ================================= IF any executable statement find and runned
    :if (g:HydrovimRunned == 1)

      "run code in temp_hydrovim.py and put the results in results_hydrovim file
      :let results = system('python ~/.config/nvim/hydrovim/.from_first_until_current.py > ~/.config/nvim/hydrovim/.results_hydrovim_py 2> ~/.config/nvim/hydrovim/.error') 
      :let l:is_error = system("awk '{print $0}' ~/.config/nvim/hydrovim/.error")
      :if (l:is_error == "")
        "pick the answer
        :silent !sed -n '/Hydrovim running code to this line./,$p' ~/.config/nvim/hydrovim/.results_hydrovim_py > ~/.config/nvim/hydrovim/.results_hydrovim2_py
        :silent !sed  '/Hydrovim running code to this line./d' ~/.config/nvim/hydrovim/.results_hydrovim2_py > ~/.config/nvim/hydrovim/.results_hydrovim3_py
        
        " If you want to see the result in editor as comment uncomment this line and comment lua code configuration for nui
        " :read !awk '{print "\#    "$0}' ~/.config/nvim/hydrovim/.results_hydrovim3_py

        :let g:hydrovimresult = system("cat ~/.config/nvim/hydrovim/.results_hydrovim3_py")

      :else 
        " :read !awk '{print "\#    "$0}' ~/.config/nvim/hydrovim/.error
        :let g:hydrovimresult = system("cat ~/.config/nvim/hydrovim/.error")
      :endif

" Lua Configuration for nui 
lua << EOF
        local Popup = require("nui.popup")
        local event = require("nui.utils.autocmd").event

        local popup = Popup({
          enter = true,
          focusable = false,
          border = {
            text = {
              top = " Hydrovim ",
              bottom = " q to exit ",
              bottom_align = "right"
            },
            style = "rounded",
            highlight = "FloatBorder",
            padding = {
              1, 2
            },
          },
        position = {
            row = "30%",
            col = "100%",
          },
          size = {
            width = "50%",
            height = "50%",
          },
          buf_options = {
            modifiable = true,
            readonly = false,
          },
        })

        -- mount/open the component
        popup:mount()

        -- unmount component when cursor leaves buffer
        popup:on(event.BufLeave, function()
          popup:unmount()
        end)

        local result = vim.g.hydrovimresult

        lines = {}
        for s in result:gmatch("[^\r\n]+") do
          table.insert(lines, s)
        end

        -- set content
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines )


        vim.cmd[[nnoremap <silent> q :call Exit_unmap_q()<CR>]]
EOF

    :endif
:endfunction





:function HydrovimRun()
    " :call HydrovimClean()

    "get the current line
    :let g:current_line = line(".") 

    :if g:FileType == "python"
        :call HydrovimPython()
        :call HydrovimExec()

  :endif

    " Clean command prompt after calling hydrovimRun function
    echo ""
:endfunction



" mapping q after pop up window show for exit
function Exit_unmap_q()
  :q 
  unmap <silent> q
endfunction






" nnoremap <silent> <F7> :call HydrovimClean() <cr><cr>
" nnoremap <F8> :call HydrovimRun()<cr><cr>   
nnoremap <silent> <F8> :call HydrovimRun()<cr><cr>   
inoremap <silent> <F8> <esc>:call HydrovimRun()<cr><cr>
