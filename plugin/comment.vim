vim9script noclear

if exists('g:loaded_comment')
    finish
endif

g:loaded_comment = true

import autoload "../autoload/comment/comment.vim"

var CommentOperator = comment.CommentOperator
var CommentRange = comment.CommentRange
var CommentToggle = comment.CommentToggle
var CommentForce = comment.CommentForce
var CommentClear = comment.CommentClear

extend(g:, {
    comment_start_of_line: true,
}, 'keep')


if !hasmapto('<Plug>(CommentToggle)')
    nnoremap <unique> <Plug>(CommentToggle) <ScriptCmd>set operatorfunc=function(CommentOperator(CommentToggle))<CR>g@
endif

if !hasmapto('<Plug>(CommentForce)')
    nnoremap <unique> <Plug>(CommentForce) <ScriptCmd>set operatorfunc=function(CommentOperator(CommentForce))<CR>g@
endif

if !hasmapto('<Plug>(CommentClear)')
    nnoremap <unique> <Plug>(CommentClear) <ScriptCmd>set operatorfunc=function(CommentOperator(CommentClear))<CR>g@
endif

if !exists(':Comment')
    command -range -bar Comment CommentRange(CommentToggle)(<line1>, <line2>)
endif

if !exists(':CommentForce')
    command -range -bar CommentForce CommentRange(CommentForce)(<line1>, <line2>)
endif

if !exists(':CommentClear')
    command -range -bar CommentClear CommentRange(CommentClear)(<line1>, <line2>)
endif

nnoremap gc <Plug>(CommentToggle)
nnoremap gCc <Plug>(CommentClear)
nnoremap gCC <Plug>(CommentForce)
nnoremap gcc <Plug>(CommentToggle)_

vnoremap <silent> gc :Comment<CR>
vnoremap <silent> gCc :CommentClear<CR>
vnoremap <silent> gCC :CommentForce<CR>
