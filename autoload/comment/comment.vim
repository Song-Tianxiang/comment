vim9script

def LeftRightWithWhiteSpace(): list<string>
    var commentstring = &commentstring
    commentstring = substitute(commentstring, '\S\zs%s', ' %s', '')
    commentstring = substitute(commentstring, '%s\ze\S', '%s ', '')

    var [left, right] = split(commentstring, '%s', 1)
    return [left, right]
enddef

def LeftRightAdjustWhiteSpace(lnum: number): list<string>
    var [left, right] = LeftRightWithWhiteSpace()
    var line_striped_white_space = StripTwoEndWhiteSpace(lnum)

    if left[-1] == ' ' &&
	    stridx(line_striped_white_space, left) == -1 &&
	    stridx(line_striped_white_space, left[: -2]) == 0
	left = left[: -2]
    endif

    if right[0] == ' ' &&
	    $' {line_striped_white_space}'[(-strlen(right)) - 1 :] != right &&
	    line_striped_white_space[-strlen(right) :] == right[1 :]
	right = right[1 :]
    endif

    return [left, right]
enddef

def StripTwoEndWhiteSpace(lnum: number): string
    return matchstr(getline(lnum), '\S.*\s\@<!')
enddef

export def CommentRange(CommentFn: func(number)): func(number, number)
    return (line1: number, line2: number) => {
	var [lnum1, lnum2] = [line1, line2]

	for lnum in range(lnum1, lnum2)
	    var line = getline(lnum)

	    if line == ''
		continue
	    endif

	    CommentFn(lnum)
	endfor
    }
enddef

export def CommentOperator(CommentFn: func(number)): func(string)
    return (type: string) => {
	var [lnum1, lnum2] = [line("'["), line("']")]

	for lnum in range(lnum1, lnum2)
	    var line = getline(lnum)

	    if line == ''
		continue
	    endif

	    CommentFn(lnum)
	endfor
    }
enddef

export def CommentClear(lnum: number)
    if IsCommentedLine(lnum)
	UnCommentLine(lnum)
    endif
enddef

export def CommentForce(lnum: number)
    CommentLine(lnum)
enddef

export def CommentToggle(lnum: number)
    if IsCommentedLine(lnum)
	UnCommentLine(lnum)
    else
	CommentLine(lnum)
    endif
enddef

def IsCommentedLine(lnum: number): bool
    var strip_white_space_line = StripTwoEndWhiteSpace(lnum)
    var [left, right] = LeftRightAdjustWhiteSpace(lnum)

    var left_equal = stridx(strip_white_space_line, left) == 0

    var right_equal =
	strridx(strip_white_space_line, right) ==
	(strlen(strip_white_space_line) - strlen(right))

    return left_equal && right_equal
enddef

def IsUnCommentedLine(lnum: number): bool
    return !IsCommentedLine(lnum)
enddef

def CommentLine(lnum: number)
    setline(lnum, CommentedLine(lnum))
enddef

def UnCommentLine(lnum: number)
    setline(lnum, UnCommentedLine(lnum))
enddef

def CommentedLine(lnum: number): string
    var line = getline(lnum)
    var [left, right] = LeftRightWithWhiteSpace()

    if g:comment_start_of_line
	return left .. line .. right
    else
	return substitute(line, '\S.*\s\@<!', '\=left .. submatch(0) .. right', '')
    endif
enddef    

def UnCommentedLine(lnum: number): string
    var line = getline(lnum)
    var [left, right] = LeftRightAdjustWhiteSpace(lnum)
    return substitute(line, '\S.*\s\@<!', '\=submatch(0)[strlen(left) : -strlen(right) - 1]', '')
enddef

