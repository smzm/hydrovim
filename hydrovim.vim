let g:FileType = &filetype

:function HydrovimClean()
      :silent! execute "normal! ms"
      "Delete all hydrovim comment
      :if g:FileType == "python"
          :silent! execute "g/^#  /d" 
      :elseif g:FileType == "javascript"
          :silent! execute "g/^//  /d" 
      :endif
      "go back to the last position
      :silent! execute "normal! `s"
      " Clean command prompt after calling hydrovimClean function
      echo ""
:endfunction



:function HydrovimPython()
    
    " this variable is a flag . if will be 1 hydrovim execute
    let l:HydrovimRunned = 0

    " put the current line inside '.current_line_text.py'
    :silent execute g:current_line.."w! ~/.config/nvim/hydrovim/.current_line_text.py"

    " check the current line is a Variable, a print statement, or an unknown statemnet
    :let l:IsVariable = system("awk -f ~/.config/nvim/hydrovim/.awk_script_for_variable_statement_split1 ~/.config/nvim/hydrovim/.current_line_text.py | awk -f ~/.config/nvim/hydrovim/.awk_script_for_variable_statement_split2")
    :let l:IsPrint = system("awk -e '$1 ~ /^print/ {print $1}' ~/.config/nvim/hydrovim/.current_line_text.py")


    " ================= Variable Statement ======================    
    " if awk can find '=' in statement it is a variable && the .current_line_text.py is not empty (means the current line is not blank)
    :if (l:IsVariable != "") 
    "&& getfsize("./.config/nvim/hydrovim/.current_line_text.py") > 0)
        

        let l:HydrovimRunned = 1
        :execute "normal! ^veyoprint()\<esc>hp"
        
        "put 'Hydrovim running code to this line' after print(variable)
        :execute "normal!"..g:current_line.."ggoprint('Hydrovim running code to this line.')\<esc>"
        "create temp_hydrovim.py and put all the text were before line ran
        :silent execute "1,"..(g:current_line+2).."w! ~/.config/nvim/hydrovim/.temp_hydrovim.py" 

        "delete breakout from main code 
        :execute "normal!"..g:current_line.."ggj"
        :execute "normal! dd"
        :execute "normal!"..g:current_line.."ggj"
        :execute "normal! dd"
        :execute "normal!"..g:current_line.."gg"


    " ================= Print Statement ======================    
    " if awk can find 'print' in the first characters of statement it is a print statement
    :elseif(l:IsPrint != "")

        let l:HydrovimRunned = 1
        "put 'Hydrovim running code to this line' before the command ran
        :execute "normal!"..g:current_line.."ggOprint('Hydrovim running code to this line.')\<esc>"
        "create temp_hydrovim.py and put all the text were before line ran
        :silent execute "1,"..(g:current_line+1).."w! ~/.config/nvim/hydrovim/.temp_hydrovim.py" 
        "delete breakout from main code 
        :execute "normal! dd"



    " ================= UNKNOWN Statement ======================    
    " if awk can't  find any   '=' or 'print' in the statement put inside a print(<statement>)
    :else
       
      " check the current line it's not a function, class, for, if ,... or anything finished with --> ':'
      :let l:Is_func = system("awk -e '$NF ~ /:$/ {print $0}' ~/.config/nvim/hydrovim/.current_line_text.py")
      

      " put the one to the last inside '.multiline_text.py' for executing multiple line defining variable 
       :silent execute (g:current_line-1).."w! ~/.config/nvim/hydrovim/.one_before_last_line.py"
       :let l:Lastline_of_multiline = system("awk -e '$NF ~ /,$/ {print $0}' ~/.config/nvim/hydrovim/.one_before_last_line.py")


       " check the multiline defining variable
       :let l:Is_multiline = system("awk -e '$NF ~ /,$/ {print $0}' ~/.config/nvim/hydrovim/.current_line_text.py")

       
       " ---------- it's not a function or class or for ,... and also not a multiline statement
       :if (l:Is_func == ""  && l:Is_multiline == "" && l:Lastline_of_multiline == "") 
         :execute "normal! VyI#\<esc>pIprint(\<esc>A)" 
         :let l:HydrovimRunned = 1

         "put 'Hydrovim running code to this line' before the command ran
         :execute "normal!"..g:current_line.."ggOprint('Hydrovim running code to this line.')\<esc>"

         :silent execute "1,"..(g:current_line+2).."w! ~/.config/nvim/hydrovim/.temp_hydrovim.py" 

         "delete addition texts from main code 
         :execute "normal!"..g:current_line.."ggddjdd"..g:current_line.."ggI\<Del>\<esc>"

       :endif
    :endif




" ================================= IF any executable statement find and runned
    :if (l:HydrovimRunned == 1)

      "run code in temp_hydrovim.py and put the results in results_hydrovim file
      :let results = system('python ~/.config/nvim/hydrovim/.temp_hydrovim.py > ~/.config/nvim/hydrovim/.results_hydrovim_py 2> ~/.config/nvim/hydrovim/.error') 
      :let l:is_error = system("awk '{print $0}' ~/.config/nvim/hydrovim/.error")
      :if (l:is_error == "")
        "pick the answer
        :silent !sed -n '/Hydrovim running code to this line./,$p' ~/.config/nvim/hydrovim/.results_hydrovim_py > ~/.config/nvim/hydrovim/.results_hydrovim2_py
        :silent !sed  '/Hydrovim running code to this line./d' ~/.config/nvim/hydrovim/.results_hydrovim2_py > ~/.config/nvim/hydrovim/.results_hydrovim3_py
        
        " If you want to see the result in editor as comment uncomment this line and comment lua code configuration for nui
        " :read !awk '{print "\#    "$0}' ~/.config/nvim/hydrovim/.results_hydrovim3_py

        :let g:hydrovimresult = system("cat ~/.config/nvim/hydrovim/.results_hydrovim3_py")

      :else 
        :read !awk '{print "\#    "$0}' ~/.config/nvim/hydrovim/.error
      :endif
    :endif

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


    :elseif g:FileType == "javascript"
        :call HydrovimJavascript()
    :endif

    " Clean command prompt after calling hydrovimRun function
    echo ""
  :endfunction



function Exit_unmap_q()
  :q 
  unmap <silent> q
endfunction






nnoremap <silent> <F7> :call HydrovimClean() <cr><cr>
" nnoremap <silent> <F8> :call HydrovimRun()<cr><cr>   
nnoremap <F8> :call HydrovimRun()<cr><cr>   
inoremap <silent> <F8> <esc>:call HydrovimRun()<cr><cr>
