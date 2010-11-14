"{{{1 protector
if exists('s:loaded_plugin')
    finish
endif
let s:loaded_plugin=1
"{{{1 Os :: os
let os#OS="unknown"
for s:os in ["unix", "win16", "win32", "win64", "win32unix", "win95",
            \"mac", "macunix"]
    if has(s:os)
        let os#OS=s:os
        break
    endif
endfor
unlet s:os
lockvar os#OS
"{{{2 os :: pathSeparator
let os#pathSeparator=fnamemodify(expand('<sfile>:h'), ':p')[-1:]
lockvar os#pathSeparator
"{{{1 Exec :: ([{command}, {arguments}][, {cwd}]) -> retstatus
function os#Exec(cmd, ...)
    if type(a:cmd)!=type([])
                \|| empty(filter(a:cmd, 'type(v:val)=='.type("")))
                \|| (!empty(a:000)
                \    && (type(a:000[0])!=type("")
                \        || !isdirectory(a:000[0])))
        return -1
    endif
    return s:Exec(a:cmd, get(a:000, 0, 0))
endfunction
if has("python") || has("python/dyn")
    try
        python import subprocess
        python import vim
        function s:Exec(cmd, cwd)
            python import subprocess
            python import vim
            if type(a:cwd)==type(0)
                python vim.command("return "+str(subprocess.Popen(vim.eval("a:cmd"), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE).wait()))
            else
                python vim.command("return "+str(subprocess.Popen(vim.eval("a:cmd"), cwd=vim.eval("a:cwd"), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE).wait()))
            endif
        endfunction
    endtry
elseif has("python3") || has("python3/dyn")
    try
        py3 import subprocess
        py3 import vim
        function s:Exec(cmd, cwd)
            py3 import subprocess
            py3 import vim
            if type(a:cwd)==type(0)
                py3 vim.command("return "+str(subprocess.Popen(vim.eval("a:cmd"), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE).wait()))
            else
                py3 vim.command("return "+str(subprocess.Popen(vim.eval("a:cmd"), cwd=vim.eval("a:cwd"), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE).wait()))
            endif
        endfunction
    endtry
endif
if !exists("*s:Exec")
    if os#OS=~#'^win' && os#OS!~#'unix'
        function s:Exec(cmd, cwd)
            let cmd=a:cmd[0]
            call escape(cmd, '\ ')
            let savedeventignore=&eventignore
            if type(a:cwd)!=type(0)
                set eventignore=all
                new
                execute "lcd ".fnameescape(a:cwd)
            endif
            call system(cmd.' '.join(map(a:cmd[1:], 'shellescape(v:val, 1)')))
            if type(a:cwd)!=type(0)
                bwipeout
                let &eventignore=savedeventignore
            endif
            redraw
            return v:shell_error
        endfunction
    else
        function s:Exec(cmd, cwd)
            let savedeventignore=&eventignore
            if type(a:cwd)!=type(0)
                set eventignore=all
                new
                execute "lcd ".fnameescape(a:cwd)
            endif
            call system(join(map(a:cmd, 'shellescape(v:val, 1)')))
            if type(a:cwd)!=type(0)
                bwipeout
                let &eventignore=savedeventignore
            endif
            redraw
            return v:shell_error
        endfunction
    endif
endif

" vim: ft=vim:fenc=utf-8:tw=80:ts=4:expandtab
