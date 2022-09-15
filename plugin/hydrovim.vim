:let g:FileType = &filetype

" Create Temporary files address
:let g:current_line_file = tempname()
:let g:from_first_until_current = tempname()
:let g:current_line_clean = tempname()
:let g:one_before_last_line = tempname()
:let g:one_before = tempname()
:let g:one_after = tempname()
:let g:results_hydrovim_py = tempname()
:let g:results_hydrovim2_py = tempname()
:let g:results_hydrovim3_py = tempname()
:let g:error = tempname()


" it's just a flag to check hydrovim popup is open or not
let g:HydrovimOpened = 0

:function HydrovimPython(mode)

    " this variable is a flag . if will be 1 hydrovim going to execute
    let g:HydrovimRunned = 0
    
    " ================= if it's in normal mode ======================    
    if (a:mode == "normal")
        " put the current line (The line should executed) inside '.current_line.py'
        :silent execute g:current_line.."w! "..(g:current_line_file)..".py"
        " Put from first line until the current line (The line should executed) inside 'from_first_until_current.py'
        :silent execute "1,"..(g:current_line-1).."w! "..(g:from_first_until_current)..".py"

        
    " ================= if it's in visual mode ======================    
    " get highlithed statement and put inside a variable
    elseif (a:mode == 'visual')
        try
            let a_save = @@
            silent execute 'normal! `<v`>"ay'
            let l:highlighted_text = @a
            echo l:highlighted_text
            " Put from first line until the current line (The line should executed) inside 'from_first_until_current.py'
            :silent execute "1,"..(g:current_line).."w! "..(g:from_first_until_current)..".py"
            
            :execute  "w !echo '".l:highlighted_text."' > "..(g:current_line_file)..".py"
        catch /.*/
            echoerr "Hydrovim Error ::::: === Just select variables ==="
        finally
            let @@ = a_save
        endtry
    endif


    " clean the current line from the comment
    :silent call system("awk -F'#' '{print $1}' "..(g:current_line_file)..".py > "..(g:current_line_clean)..".py")


    " check the current line is a indented line or a Variable, a print statement, or an unknown statemnet
    :let l:IsIndent= system("awk -e '$0 ~ /^\\s+/ {print $1}' "..(g:current_line_clean)..".py") 
    :let l:IsVariable = system("awk '{if ($0 ~ /^[^\\t]+[^=><!]=[^=><!]/) {-FS\"=\" ; $0=$0; print $1;}}' "..(g:current_line_clean)..".py | awk '{if ($0 ~ /\\(/ ) {} else {print $0}}'")
    :let l:IsPrint = system("awk -e '$0 ~ /^print/ {print $1}' "..(g:current_line_clean)..".py")


    " ================= Indent lines ======================    
    :if (l:IsIndent != "")

        :let g:NrEndFile=line('$')
        :let l:back = 0
        :let l:next = 0
        :let l:IsIndentInBack = " "
        :let l:IsIndentInNext = " "
        " Go Back line by line until find nonindent line 
        while (l:IsIndentInBack != "")
           :if (g:current_line - l:back > 1)
               :let l:back = l:back + 1
           :else
                break
           :endif
           :silent execute (g:current_line - l:back).."w! "..(g:one_before)..".py"
           :let l:IsIndentInBack = system("awk -e '$0 ~ /^\\s+/ {print $1}' "..(g:one_before)..".py") 
        endwhile

        "Go forward line by line until find nonindent line 
        while (l:IsIndentInNext != "")
           :if (g:current_line + l:next < g:NrEndFile)
               :let l:next = l:next + 1
           :else
                break
           :endif
           :silent execute (g:current_line + l:next).."w! "..(g:one_after)..".py"
           :let l:IsIndentInNext = system("awk -e '$0 ~ /^\\s+/ {print $1}' "..(g:one_after)..".py") 
        endwhile

        " it is a for|while loop or if statement ?
        :let l:IsFor = system("awk -e '$0 ~ /^for/ {print $0}' "..(g:one_before)..".py") 
        :let l:IsWhile = system("awk -e '$0 ~ /^while/ {print $0}' "..(g:one_before)..".py") 
        :let l:IsIf = system("awk -e '$0 ~ /^if/ {print $0}' "..(g:one_before)..".py") 

        if (g:current_line - l:back <= 1)
            let g:first_indent_line_NR = 1 
            let g:end_indent_line_NR = g:current_line + l:next
            :silent call system("echo '\n' > "..(g:from_first_until_current)..".py")

        elseif (g:current_line + l:next > g:NrEndFile)
            let g:first_indent_line_NR = g:current_line - l:back
            let g:end_indent_line_NR = g:NrEndFile
            :silent execute "1,"..(g:current_line - g:first_indent_line_NR).."w! "..(g:from_first_until_current)..".py"
        else 
            let g:first_indent_line_NR = g:current_line - l:back
            let g:end_indent_line_NR = g:current_line + l:next
            :silent execute "1,"..(g:current_line - g:first_indent_line_NR).."w! "..(g:from_first_until_current)..".py"
        endif 

        :if (l:IsFor != "") || (l:IsWhile != "") || (l:IsIf != "")
            let g:HydrovimRunned = 1
            :silent call system('echo "print(\"Hydrovim running code to this line.\")" >> '..(g:from_first_until_current)..".py")
            :silent execute g:first_indent_line_NR..","..(g:end_indent_line_NR).."w >> "..(g:from_first_until_current)..".py"
            ":put= l:next
        :else
             :let g:HydrovimOpened = 0
        endif


       ":let g:HydrovimRunned = 0
       ":let g:HydrovimOpened = 0
    

    "================= Variable Statement ======================    
    " if awk can find '=' in start of statement consider it as a variable
    :elseif (l:IsVariable != "") 
        
        " Check the line has '=' in it and also finished with ','
        :let l:Is_var_multiline = system("awk -e '$0 ~ /[^=><!]=[^=><!]/ && $NF ~ /,$/ {print $0}' "..(g:current_line_clean)..".py")

        :if (l:Is_var_multiline != "")

            " store variable name
            :let l:variable_name=system("awk '{if ($0 ~ /^[^\\t]+[^=><!]=[^=><!]/) {-FS\"=\" ; $0=$0; print $1;}}' "..(g:current_line_clean)..".py | awk '{if ($0 ~ /\\(/ ) {} else {print $0}}' | tr -d '[:space:]'")

            " Create a loop and forward line by line until the end of the defenition
            while (l:Is_var_multiline != "")

               " add the current line to the end of from_first_until_current.py
                silent call system("cat "..(g:current_line_clean)..".py >> "..(g:from_first_until_current)..".py")
                
                " Change the current line to the next line 
                :let g:current_line = g:current_line + 1

               " Put the current line (The line should executed) inside '.current_line.py'
                :silent execute g:current_line.."w! "..(g:current_line_file)..".py"

               " clean the current line from the comment
               :silent call system("awk -F'#' '{print $1}' "..(g:current_line_file)..".py > "..(g:current_line_clean)..".py")
               

               " Check it's still a multiline statement for next loop check
                :let l:Is_var_multiline = system("awk -e '$NF ~ /,$/ || $NF ~ /)$/ {print $0}' "..(g:current_line_clean)..".py")

               " Check it's end of multiline statement
                :let l:last_line = system("awk -e '$NF ~ /)$/ || $NF ~ /]$/ {print $0}' "..(g:current_line_clean)..".py")
                if (l:last_line != "" )
                    :silent call system("cat "..(g:current_line_clean)..".py >> "..(g:from_first_until_current)..".py")
                    break
                endif

            endwhile

            let g:HydrovimRunned = 1
            :silent call system('echo "print(\"Hydrovim running code to this line.\")" >> '..(g:from_first_until_current)..".py")
            " write print('variable_name') to the end of the .from_first_until_current.py
            :execute  "w !echo 'print(".l:variable_name.")' >> "..(g:from_first_until_current)..".py"



            :else 

                " If it's not a multiline variable (one line variable definition)
                let g:HydrovimRunned = 1

                " Add the current line to the end of '.from_first_until_current.py' file 
                :silent call system("cat "..(g:current_line_clean)..".py >> "..(g:from_first_until_current)..".py")

                " Add 'print('Hydrovim running code to this line.')' to the end of '.from_first_until_current.py' file
                :silent call system('echo "print(\"Hydrovim running code to this line.\")" >> '..(g:from_first_until_current)..".py")
                " Add 'print(l:IsVariable)' to the end of '.from_first_until_current.py' file. 
                :silent call system("current_line_hydrovim=`awk '{if ($0 ~ /^[^\\t]+[^=><!]=[^=><!]/) {-FS\"=\" ; $0=$0; print $1;}}' "..(g:current_line_clean)..".py | awk '{if ($0 ~ /\\(/ ) {} else {print $0}}' | tr -d '[:space:]'` ; echo \"print($current_line_hydrovim)\" >> "..(g:from_first_until_current)..".py")

        :endif

    " ================= Print Statement ======================    
    " if awk can find 'print' in the first characters of statement it is a print statement
    :elseif(l:IsPrint != "")
        let g:HydrovimRunned = 1


        "put 'Hydrovim running code to this line' before the command ran
        :silent call system('echo "print(\"Hydrovim running code to this line.\")" >> '..(g:from_first_until_current)..".py")

        " Add the current line to the end of '.from_first_until_current.py' file
        :silent call system("cat "..(g:current_line_clean)..".py >> "..(g:from_first_until_current)..".py")

    
    " ================= UNKNOWN Statement ======================    
    " if awk can't  find any   '=' or 'print' in the statement put inside a print(<statement>)
    :else
          " check the current line it's not a function, class, for, if ,... or anything finished with --> ':'
          :let l:Is_end_with_colon = system("awk -e '$NF ~ /:$/ {print $0}' "..(g:current_line_clean)..".py")
          
          " put one before last line  inside '.multiline_text.py' for executing multiple line defining variable 
           :silent execute (g:current_line-1).."w! "..(g:one_before_last_line)..".py"
           :let l:Lastline_of_multiline = system("awk -e '$NF ~ /,$/ {print $0}' "..(g:one_before_last_line)..".py")

           " check the multiline defining variable ends with ','
           :let l:Is_multiline = system("awk -e '$NF ~ /,$/ {print $0}' "..(g:current_line_clean)..".py")


           " Check the Statement is 'import' module
           :let l:Is_Import = system("awk -e '/^import\\s+/ {print $0}' "..(g:current_line_clean)..".py")


           " ---------- it's not a function or class or for ,... and also not a multiline statement : Code Should run
           :if (l:Is_end_with_colon == "")  && (l:Is_multiline == "") && (l:Lastline_of_multiline == "") && (l:Is_Import == "")
             :let g:HydrovimRunned = 1
             :silent call system('echo "print(\"Hydrovim running code to this line.\")" >> '..(g:from_first_until_current)..".py")
             :silent call system("current_line_hydrovim=`sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "..(g:current_line_clean)..".py`;echo \"print($current_line_hydrovim)\" >> "..(g:from_first_until_current)..".py")
           :else
             :let g:HydrovimRunned = 0
             :let g:HydrovimOpened = 0
           :endif
    :endif
:endfunction



:function HydrovimExec()
" ================================= IF any executable statement find and runned
    :if (g:HydrovimRunned == 1)
      
      "run code in temp_hydrovim.py and put the results in results_hydrovim file
      :let results = system("python "..(g:from_first_until_current)..".py > "..(g:results_hydrovim_py).." 2> "..(g:error)) 
      :let g:is_error = system("awk '{print $0}' "..(g:error))
      :if (g:is_error == "")
        "pick the answer
        :silent call system("sed -n '/Hydrovim running code to this line./,$p' "..(g:results_hydrovim_py).." > "..(g:results_hydrovim2_py))

        :silent call system("sed  '/Hydrovim running code to this line./d' "..(g:results_hydrovim2_py).." > "..(g:results_hydrovim3_py))
        
        :let g:hydrovimresult = system("cat "..(g:results_hydrovim3_py))
    :else 
        :let g:hydrovimresult = system("cat "..(g:error))
    :endif


lua << EOF
    local params = vim.lsp.util.make_position_params()
    local Popup = require("nui.popup")
    local event = require("nui.utils.autocmd").event

    local is_error = vim.g.is_error

    if  is_error == "" then 
        vim.cmd[[highlight hydroBorder guifg=#00b061]]
        vim.cmd[[highlight hydroBack guifg=#b4dbca]]
    else 
        vim.cmd[[highlight hydroBorder guifg=#b30e6e]]
        vim.cmd[[highlight hydroBack guifg=#d6b2c7]]
    end



    local popup = Popup({
        enter = true,
        focusable = true,
        border = {
        text = {
       --      top = " Hydrovim ",
        --     bottom = " q to exit ",
        --     bottom_align = "right"
          },
        style = "rounded",
        highlight = "hydroBorder",
          padding = {
            top = 1,
            left = 5,
          },
        },
    relative = {
        type = 'buf',
        position = {
          row = params.position.line,
          col = 0
          -- col = params.position.character,
            }
        },
    position = {
    row = 0,
    col = 2
    },
    size = {
          width = "50%",
          height = "25%",
        },
        buf_options = {
          modifiable = true,
          readonly = false,
        },
      win_options = {
        winblend = 10,
        winhighlight = "Normal:hydroBack,FloatBorder:FloatBorder", 
      }
      })

      -- mount/open the component
      popup:mount()

    -- unmount component when cursor leaves buffer
      popup:on(event.BufLeave, function()
        popup:unmount()
      end)

      popup:mount()


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



:function HydrovimRun(mode)
    :if (g:HydrovimOpened == 0)

        "get the current line
        :let g:current_line = line(".") 

        :if g:FileType == "python"
            let g:HydrovimOpened = 1
            :call HydrovimPython(a:mode)
            :call HydrovimExec()
        :endif

        " Clean command prompt after calling hydrovimRun function
        echo ""
    " if hydrovim popup is open just close it. (toggle functionality)
    :else 
        q
        let g:HydrovimOpened = 0
    :endif
:endfunction



" mapping q after pop up window show for exit
function Exit_unmap_q()
  :q 
  unmap <silent> q
  let g:HydrovimOpened = 0
endfunction


nnoremap <silent> <F8> :call HydrovimRun('normal')<cr> 
inoremap <silent> <F8> <esc>:call HydrovimRun('normal')<cr>
vnoremap <silent> <F8> :call HydrovimRun('visual')<cr>
