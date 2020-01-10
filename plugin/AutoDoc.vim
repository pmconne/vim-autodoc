" AutoDoc.vim - Quickly delete buffers
"
" Created June 2013 Paul Connelly
"
" Extracts paramaters and return types from function declaration and inserts
" boilerplate documentation above the function.
"
" Usage:
" :call InsertAutoDoc() with a function declaration on the current line.

" Ways this can break:
"	-Specified function pointer type inline (sans typedef)
"	-Omitted a parameter name (we try to catch some common cases of this)
"	-Doesn't handle constructors and destructors correctly
"	-Doesn't handle multi-line function declarations
function! ExtractParamNamesFromCurrentLine()
    execute 'normal! ^f("ayi('
    let argsText = @a

    let paramNames = []
    for paramText in split (argsText, ",")
        " ignore default parameter values
        let splitOnEquals = split(paramText, "=")
        let paramText = splitOnEquals[0]

        let paramTokens = split (paramText)
        let paramName = ""

        " handle varargs
        if (1 < len (paramTokens) || (1 == len(paramTokens) && "..." == paramTokens[0]))
            let paramName = paramTokens[-1]
        endif

        " handle leading * or &
        " (could just strip all non-alpha/underscore from beginning of word
        " instead)
        while (len(paramName) && (paramName[0] == "*" || paramName[0] == "&"))
            let paramName = paramName[1:]
        endwhile

        let namelen = len(paramName)
        if (0 == namelen || paramName[namelen-1] == "*" || paramName[namelen-1] == "&")
            let paramName = "MISSING PARAMETER NAME"
        endif

        call add (paramNames, paramName)
    endfor

    return paramNames
endfunction

function! GenerateFunctionDoc (paramNames, hasReturnType, prefix)
    " Leave space for description
    let doc = a:prefix . "//! \n"

    " Figure out the longest parameter name
    let maxParamWidth = 0
    for paramName in a:paramNames
        if (maxParamWidth < len(paramName))
            let maxParamWidth = len(paramName)
        endif
    endfor

    let maxParamWidth += 1

    " Document each parameter
    for paramName in a:paramNames
        " ###TODO: in/out param tags? In some cases we'd only be guessing
        let trailingSpaces = repeat (" ", maxParamWidth - len(paramName))
        let paramDoc = a:prefix . '//! @param[in]      ' . paramName . trailingSpaces . "\n"
        let doc .= paramDoc
    endfor

    " Document return type
    if a:hasReturnType
        let doc .= a:prefix . "//! @return \n"
    endif

    return doc
endfunction

function! InsertAutoDoc()
    let saved_areg = @a

    " grab indentation from current line
    execute "normal! ^v0\"ay"
    let indent = len(@a) && " " == @a[0] ? @a : ""

    " Figure out if we have a return type
    execute 'normal! ^t(bb"aye'
    let isVoidFunction = (@a ==# "void")

    " Grab param names
    let paramNames = ExtractParamNamesFromCurrentLine()
    let @a = GenerateFunctionDoc(paramNames, !isVoidFunction, indent)

    " insert above
    execute "normal! \"aP"
    let @a = saved_areg
endfunction

