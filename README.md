# vim-autodoc

Automatically generate doxygen documentation for C++ function declarations.

# Usage

To document a function:
   * Place the cursor anywhere on the line on which the function is defined
   * Invoke the `InsertAutoDoc()` function, probably via a mapping

The documentation stubs will be inserted above the current line, using the indentation level of that line, consisting of the following:
   * A blank line on which to insert a description of the function's purpose
   * For each parameter:
      * An `@param[in]` directive
      * The parameter name
      * Enough whitespace to left-align the descriptions of all parameters
   * For non-void functions, a `@return` directive

For example, given the following function declaration:
```cpp
DLL_EXPORT RepositoryStatus PrepareForElementOperation(Request& req, ElementCR el, DbOpcode, PrepareAction action, ElementCP original=nullptr);
```
The documentation stubs will be generated as follows:
```cpp
//! 
//! @param[in]      req                    
//! @param[in]      el                     
//! @param[in]      MISSING PARAMETER NAME 
//! @param[in]      action                 
//! @param[in]      original               
//! @return 
DLL_EXPORT RepositoryStatus PrepareForElementOperation(Request& req, ElementCR el, DbOpcode, PrepareAction action, ElementCP original=nullptr);
```
Note that doxygen requires each parameter to be named; the plugin will insert `MISSING PARAMETER NAME` for any unnamed parameter.

After invoking `InsertAutoDoc()`, just fill in a description for each line.

The plugin handles the following cases:
   * Omits `@return` directive for void functions
   * Default argument values
   * Ignores macros like export specifications
   * Inconsistent whitespace
   * Varargs a la `void function(int x, ...)`
It does not handle the following cases:
   * Multi-line function declarations
   * Constructors (try temporarily adding `void` in front of the constructor to make it generate the correct stubs)
   * Parameters of function pointer type where the type is specified inline rather than using a typedef (always ugly...)

## Sample mapping

The following mapping in your .vimrc will generate documentation stubs for the function declaration on the current line, center horizontally, and enter insert mode for editing the function description.
```vi
" Paste documentation skeleton for function on current line above current
" line, center horizontally, and begin inserting function description
nnoremap <leader>dm :call InsertAutoDoc()<cr>zzA
```
