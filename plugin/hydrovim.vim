let g:FileType = &filetype


:function HydrovimPython()
    
    " this variable is a flag . if will be 1 hydrovim execute
    let g:HydrovimRunned = 0

    " put the current line (The line should executed) inside '.current_line.py'
    :silent execute g:current_line.."w! ~/local/share/nvim/plugged/hydrovim/plugin/.current_line.py"
    " Put from first line until the current line (The line should executed) inside 'from_first_until_current.py'
    :silent execute "1,"..(g:current_line-1).."w! ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py"

    " clean the current line from the comment
    :silent ! awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_cleaning ~/local/share/nvim/plugged/hydrovim/plugin/.current_line.py > ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py


    " check the current line is a Variable, a print statement, or an unknown statemnet
    :let l:IsVariable = system("awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_variable_statement_split1 ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py | awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_variable_statement_split2")
    :let l:IsPrint = system("awk -e '$1 ~ /^print/ {print $1}' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py")


    " ================= Variable Statement ======================    
    " if awk can find '=' in statement it is a variable
    :if (l:IsVariable != "") 
        

        " Check the line has '=' in it and alse end with ','
        :let l:Is_var_multiline = system("awk -e '$0 ~ /[^=><!]=[^=><!]/ && $NF ~ /,$/ {print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py")

        :if (l:Is_var_multiline != "")

            " store variable name
            :let l:variable_name=system("awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_variable_statement_split1 ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py | awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_variable_statement_split2 | tr -d '[:space:]'")

            " Create a loop and forward line by line until the end of the defenition
            while (l:Is_var_multiline != "")

               " add the current line to the end of from_first_until_current.py
                :silent ! cat ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py
                
                " Change the current line to the next line 
                :let g:current_line = g:current_line + 1

               " Put the current line (The line should executed) inside '.current_line.py'
                :silent execute g:current_line.."w! ~/local/share/nvim/plugged/hydrovim/plugin/.current_line.py"

               " clean the current line from the comment
                :silent ! awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_cleaning ~/local/share/nvim/plugged/hydrovim/plugin/.current_line.py > ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py

               " Check it's still a multiline statement for next loop check
                :let l:Is_var_multiline = system("awk -e '$NF ~ /,$/ || $NF ~ /)$/ {print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py")

               " Check it's end of multiline statement
                :let l:last_line = system("awk -e '$NF ~ /)$/ {print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py")
                if (l:last_line != "" )
                    :silent ! cat ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py
                    break
                endif

            endwhile

            let g:HydrovimRunned = 1
            :silent ! echo "print('Hydrovim running code to this line.')" >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py
            " write print('variable_name') to the end of the .from_first_until_current.py
            :execute  "w !echo 'print(".l:variable_name.")' >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py"



            :else 
            " If it's not a multiline variable (one line variable definition)
            let g:HydrovimRunned = 1

            " Add the current line to the end of '.from_first_until_current.py' file 
            :silent ! cat ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py

            " Add 'print('Hydrovim running code to this line.')' to the end of '.from_first_until_current.py' file
            :silent ! echo "print('Hydrovim running code to this line.')" >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py

            " Add 'print(l:IsVariable)' to the end of '.from_first_until_current.py' file. 
            :silent ! current_line_hydrovim=`awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_variable_statement_split1 ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py | awk -f ~/local/share/nvim/plugged/hydrovim/plugin/.awk_script_for_variable_statement_split2 | tr -d '[:space:]'` ; echo "print($current_line_hydrovim)" >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py

        :endif

    " ================= Print Statement ======================    
    " if awk can find 'print' in the first characters of statement it is a print statement
    :elseif(l:IsPrint != "")

        let g:HydrovimRunned = 1


        "put 'Hydrovim running code to this line' before the command ran
        :silent ! echo "print('Hydrovim running code to this line.')" >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py

        " Add the current line to the end of '.from_first_until_current.py' file
        :silent ! cat ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py


    


    " ================= UNKNOWN Statement ======================    
    " if awk can't  find any   '=' or 'print' in the statement put inside a print(<statement>)
    :else
          " check the current line it's not a function, class, for, if ,... or anything finished with --> ':'
          :let l:Is_func = system("awk -e '$NF ~ /:$/ {print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py")
          

          " put one before last line  inside '.multiline_text.py' for executing multiple line defining variable 
           :silent execute (g:current_line-1).."w! ~/local/share/nvim/plugged/hydrovim/plugin/.one_before_last_line.py"
           :let l:Lastline_of_multiline = system("awk -e '$NF ~ /,$/ {print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.one_before_last_line.py")


           " check the multiline defining variable ends with ','
           :let l:Is_multiline = system("awk -e '$NF ~ /,$/ {print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py")


           " Check the Statement is 'import' module
           :let l:IsImport = system("awk -e '/^import\s*|from\s*/ {print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py")


           " ---------- it's not a function or class or for ,... and also not a multiline statement
           :if (l:Is_func == ""  && l:Is_multiline == "" && l:Lastline_of_multiline == "" && l:IsImport == "")
             :let g:HydrovimRunned = 1
             " execute "normal! o" . l:IsImport 


             :silent !  echo "print('Hydrovim running code to this line.')" >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py
             :silent ! current_line_hydrovim=`sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' ~/local/share/nvim/plugged/hydrovim/plugin/.current_line_clean.py`;echo "print($current_line_hydrovim)" >> ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py


           :endif
    :endif
:endfunction



:function HydrovimExec()
" ================================= IF any executable statement find and runned
    :if (g:HydrovimRunned == 1)

      "run code in temp_hydrovim.py and put the results in results_hydrovim file
      :let results = system('python ~/local/share/nvim/plugged/hydrovim/plugin/.from_first_until_current.py > ~/local/share/nvim/plugged/hydrovim/plugin/.results_hydrovim_py 2> ~/local/share/nvim/plugged/hydrovim/plugin/.error') 
      :let l:is_error = system("awk '{print $0}' ~/local/share/nvim/plugged/hydrovim/plugin/.error")
      :if (l:is_error == "")
        "pick the answer
        :silent !sed -n '/Hydrovim running code to this line./,$p' ~/local/share/nvim/plugged/hydrovim/plugin/.results_hydrovim_py > ~/local/share/nvim/plugged/hydrovim/plugin/.results_hydrovim2_py
        :silent !sed  '/Hydrovim running code to this line./d' ~/local/share/nvim/plugged/hydrovim/plugin/.results_hydrovim2_py > ~/local/share/nvim/plugged/hydrovim/plugin/.results_hydrovim3_py
        
        " If you want to see the result in editor as comment uncomment this line and comment lua code configuration for nui
        " :read !awk '{print "\#    "$0}' ~/local/share/nvim/plugged/hydrovim/plugin/.results_hydrovim3_py

        :let g:hydrovimresult = system("cat ~/local/share/nvim/plugged/hydrovim/plugin/.results_hydrovim3_py")

      :else 
        :let g:hydrovimresult = system("cat ~/local/share/nvim/plugged/hydrovim/plugin/.error")
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



nnoremap <silent> <F8> :call HydrovimRun()<cr><cr>   
inoremap <silent> <F8> <esc>:call HydrovimRun()<cr><cr>
