" JSONL / NDJSON syntax
" Each line is an independent JSON value.

if exists("b:current_syntax")
  finish
endif

syntax case match

" Strings
syntax region jsonlString
      \ start=+"+
      \ skip=+\\\|\\\\+
      \ end=+"+

" Numbers
syntax match jsonlNumber
      \ /\v-?(0|[1-9]\d*)(\.\d+)?([eE][+-]?\d+)?/

" Booleans
syntax keyword jsonlBoolean true false

" Null
syntax keyword jsonlNull null

" Property names
syntax match jsonlProperty /"\%([^"\\]\|\\.\)*"\ze\s*:/

" Punctuation
syntax match jsonlDelimiter /[,;:]/
syntax match jsonlBracket /[{}\[\]]/

" Escape sequences
syntax match jsonlEscape /\\\%(["\\\/bfnrt]\|u\x\{4}\)/ contained containedin=jsonlString

" Highlight links
highlight default link jsonlString String
highlight default link jsonlNumber Number
highlight default link jsonlBoolean Boolean
highlight default link jsonlNull Constant
highlight default link jsonlProperty Identifier
highlight default link jsonlDelimiter Delimiter
highlight default link jsonlBracket Delimiter
highlight default link jsonlEscape SpecialChar

let b:current_syntax = "jsonl"
