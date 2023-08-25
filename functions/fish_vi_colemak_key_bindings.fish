function fish_vi_colemak_key_bindings --description "Install the default key bindings."
    if contains -- -h $argv
        or contains -- --help $argv
        echo "Sorry but this function doesn't support -h or --help"
        return 1
    end
    
    # Erase all bindings if not explicitly requested otherwise to
    # allow for hybrid bindings.
    # This needs to be checked here because if we are called again
    # via the variable handler the argument will be gone.
    set -l rebind true
    if test "$argv[1]" = --no-erase
        set rebind false
        set -e argv[1]
    else
        bind --erase --all --preset # clear earlier bindings, if any
    end

    # Allow just calling this function to correctly set the bindings.
    # Because it's a rather discoverable name, users will execute it
    # and without this would then have subtly broken bindings.
    if test "$fish_key_bindings" != fish_vi_colemak_key_bindings
        and test "$rebind" = true
        # Allow the user to set the variable universally.
        set -q fish_key_bindings
        # This triggers the handler, which calls us again and ensures the user_key_bindings
        # are executed.
        set fish_key_bindings fish_vi_colemak_key_bindings
        return
    end

    set -l init_mode insert
    # These are only the special vi-style keys
    # not end/home, we share those.
    set -l eol_keys \$ g\$
    set -l bol_keys \^ 0 g\^

    if contains -- $argv[1] insert default visual
        set init_mode $argv[1]
    else if set -q argv[1]
        # We should still go on so the bindings still get set.
        echo "Unknown argument $argv" >&2
    end

    # Inherit shared key bindings.
    # Do this first so vi-bindings win over default.
    for mode in insert default visual
        __fishmak_shared_key_bindings -s -M $mode
    end

    bind -s --preset -M insert \r execute
    bind -s --preset -M insert \n execute

    bind -s --preset -M insert "" self-insert
     
    # Space and other command terminators expand abbrs _and_ inserts itself.
    bind -s --preset -M insert " " self-insert expand-abbr
    bind -s --preset -M insert ";" self-insert expand-abbr
    bind -s --preset -M insert "|" self-insert expand-abbr
    bind -s --preset -M insert "&" self-insert expand-abbr
    bind -s --preset -M insert "^" self-insert expand-abbr
    bind -s --preset -M insert ">" self-insert expand-abbr
    bind -s --preset -M insert "<" self-insert expand-abbr
    # Closing a command substitution expands abbreviations
    bind -s --preset -M insert ")" self-insert expand-abbr
    # Ctrl-space inserts space without expanding abbrs
    bind -s --preset -M insert -k nul 'commandline -i " "'

    # Add a way to switch from insert to normal (command) mode.
    # Note if we are paging, we want to stay in insert mode
    # See #2871
    bind -s --preset -M insert \e "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char repaint-mode; end"

    # Default (command) mode
    bind -s --preset -m insert \cc cancel-commandline repaint-mode
    bind -s --preset -M default m backward-char
    bind -s --preset -M default i forward-char
    bind -s --preset -m insert \n execute
    bind -s --preset -m insert \r execute
    bind -s --preset -m insert y insert-line-under repaint-mode
    bind -s --preset -m insert Y insert-line-over repaint-mode
    bind -s --preset -m insert u repaint-mode
    bind -s --preset -m insert U beginning-of-line repaint-mode
    bind -s --preset -m insert a forward-single-char repaint-mode
    bind -s --preset -m insert A end-of-line repaint-mode
    bind -s --preset -m visual v begin-selection repaintmode

    #bind -s -m insert o "commandline -a \n" down-line repaint-mode
    #bind -s -m insert O beginning-of-line "commandline -i \n" up-line repaint-mode # doesn't work

    bind -s --preset gg beginning-of-buffer
    bind -s --preset G end-of-buffer

    for key in $eol_keys
        bind -s --preset $key end-of-line
    end
    for key in $bol_keys
        bind -s --preset $key beginning-of-line
    end

    bind -s --preset l undo
    bind -s --preset \cp redo

    bind -s --preset [ history-token-search-backward
    bind -s --preset ] history-token-search-forward

    bind -s --preset e up-or-search
    bind -s --preset n down-or-search
    bind -s --preset z backward-word
    bind -s --preset Z backward-bigword
    bind -s --preset gf backward-word
    bind -s --preset gF backward-bigword
    bind -s --preset w forward-word forward-single-char
    bind -s --preset W forward-bigword forward-single-char
    bind -s --preset f forward-single-char forward-word backward-char
    bind -s --preset F forward-bigword backward-char

    # Vi/Vim doesn't support these keys in insert mode but that seems silly so we do so anyway.
    bind -s --preset -M insert -k home beginning-of-line
    bind -s --preset -M default -k home beginning-of-line
    bind -s --preset -M insert -k end end-of-line
    bind -s --preset -M default -k end end-of-line

    # Vi moves the cursor back if, after deleting, it is at EOL.
    # To emulate that, move forward, then backward, which will be a NOP
    # if there is something to move forward to.
    bind -s --preset -M default c delete-char forward-single-char backward-char
    bind -s --preset -M default C backward-delete-char
    bind -s --preset -M insert -k sc delete-char forward-single-char backward-char
    bind -s --preset -M default -k sc delete-char forward-single-char backward-char

    # Backspace deletes a char in insert mode, but not in normal/default mode.
    bind -s --preset -M insert -k backspace backward-delete-char
    bind -s --preset -M default -k backspace backward-char
    bind -s --preset -M insert \cm backward-delete-char
    bind -s --preset -M default \cm backward-char
    bind -s --preset -M insert \x7f backward-delete-char
    bind -s --preset -M default \x7f backward-char
    bind -s --preset -M insert -k sdc backward-delete-char # shifted delete
    bind -s --preset -M default -k sdc backward-delete-char # shifted delete

    bind -s --preset ss kill-whole-line
    bind -s --preset S kill-line
    bind -s --preset s\$ kill-line
    bind -s --preset s\^ backward-kill-line
    bind -s --preset s0 backward-kill-line
    bind -s --preset sw kill-word
    bind -s --preset sW kill-bigword
    bind -s --preset suw forward-single-char forward-single-char backward-word kill-word
    bind -s --preset suW forward-single-char forward-single-char backward-bigword kill-bigword
    bind -s --preset saw forward-single-char forward-single-char backward-word kill-word
    bind -s --preset saW forward-single-char forward-single-char backward-bigword kill-bigword
    bind -s --preset sf kill-word
    bind -s --preset sF kill-bigword
    bind -s --preset sv backward-kill-word
    bind -s --preset sV backward-kill-bigword
    bind -s --preset sgf backward-kill-word
    bind -s --preset sgF backward-kill-bigword
    bind -s --preset st begin-selection forward-jump kill-selection end-selection
    bind -s --preset sb begin-selection forward-jump backward-char kill-selection end-selection
    bind -s --preset sT begin-selection backward-jump kill-selection end-selection
    bind -s --preset sB begin-selection backward-jump forward-single-char kill-selection end-selection
    bind -s --preset sm backward-char delete-char
    bind -s --preset si delete-char
    bind -s --preset su backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection
    bind -s --preset sa backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection
    bind -s --preset 's;' begin-selection repeat-jump kill-selection end-selection
    bind -s --preset 's,' begin-selection repeat-jump-reverse kill-selection end-selection

    bind -s --preset -m insert r delete-char repaint-mode
    bind -s --preset -m insert r kill-whole-line repaint-mode
    bind -s --preset -m insert dd kill-whole-line repaint-mode
    bind -s --preset -m insert D kill-line repaint-mode
    bind -s --preset -m insert d\$ kill-line repaint-mode
    bind -s --preset -m insert d\^ backward-kill-line repaint-mode
    bind -s --preset -m insert d0 backward-kill-line repaint-mode
    bind -s --preset -m insert dw kill-word repaint-mode
    bind -s --preset -m insert dW kill-bigword repaint-mode
    bind -s --preset -m insert duw forward-single-char forward-single-char backward-word kill-word repaint-mode
    bind -s --preset -m insert duW forward-single-char forward-single-char backward-bigword kill-bigword repaint-mode
    bind -s --preset -m insert daw forward-single-char forward-single-char backward-word kill-word repaint-mode
    bind -s --preset -m insert daW forward-single-char forward-single-char backward-bigword kill-bigword repaint-mode
    bind -s --preset -m insert df kill-word repaint-mode
    bind -s --preset -m insert dF kill-bigword repaint-mode
    bind -s --preset -m insert dv backward-kill-word repaint-mode
    bind -s --preset -m insert dV backward-kill-bigword repaint-mode
    bind -s --preset -m insert dgf backward-kill-word repaint-mode
    bind -s --preset -m insert dgF backward-kill-bigword repaint-mode
    bind -s --preset -m insert dt begin-selection forward-jump kill-selection end-selection repaint-mode
    bind -s --preset -m insert db begin-selection forward-jump backward-char kill-selection end-selection repaint-mode
    bind -s --preset -m insert dT begin-selection backward-jump kill-selection end-selection repaint-mode
    bind -s --preset -m insert dB begin-selection backward-jump forward-single-char kill-selection end-selection repaint-mode
    bind -s --preset -m insert dm backward-char begin-selection kill-selection end-selection repaint-mode
    bind -s --preset -m insert di begin-selection kill-selection end-selection repaint-mode
    bind -s --preset -m insert du backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode
    bind -s --preset -m insert da backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode

    bind -s --preset '~' togglecase-char forward-single-char
    bind -s --preset gl downcase-word
    bind -s --preset gL upcase-word

    bind -s --preset N end-of-line delete-char
    bind -s --preset E 'man (commandline -t) 2>/dev/null; or echo -n \a'

    bind -s --preset jj kill-whole-line yank
    bind -s --preset J kill-whole-line yank
    bind -s --preset j\$ kill-line yank
    bind -s --preset j\^ backward-kill-line yank
    bind -s --preset j0 backward-kill-line yank
    bind -s --preset jw kill-word yank
    bind -s --preset jW kill-bigword yank
    bind -s --preset juw forward-single-char forward-single-char backward-word kill-word yank
    bind -s --preset juW forward-single-char forward-single-char backward-bigword kill-bigword yank
    bind -s --preset jaw forward-single-char forward-single-char backward-word kill-word yank
    bind -s --preset jaW forward-single-char forward-single-char backward-bigword kill-bigword yank
    bind -s --preset jf kill-word yank
    bind -s --preset jF kill-bigword yank
    bind -s --preset jv backward-kill-word yank
    bind -s --preset jV backward-kill-bigword yank
    bind -s --preset jgf backward-kill-word yank
    bind -s --preset jgF backward-kill-bigword yank
    bind -s --preset jt begin-selection forward-jump kill-selection yank end-selection
    bind -s --preset jb begin-selection forward-jump-till kill-selection yank end-selection
    bind -s --preset jT begin-selection backward-jump kill-selection yank end-selection
    bind -s --preset jB begin-selection backward-jump-till kill-selection yank end-selection
    bind -s --preset jm backward-char begin-selection kill-selection yank end-selection
    bind -s --preset ji begin-selection kill-selection yank end-selection
    bind -s --preset ju backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection yank end-selection
    bind -s --preset ja backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection yank end-selection

    bind -s --preset t forward-jump
    bind -s --preset T backward-jump
    bind -s --preset b forward-jump-till
    bind -s --preset B backward-jump-till
    bind -s --preset ';' repeat-jump
    bind -s --preset , repeat-jump-reverse

    # in emacs yank means paste
    # in vim p means paste *after* current character, so go forward a char before pasting
    # also in vim, P means paste *at* current position (like at '|' with cursor = line),
    # \ so there's no need to go back a char, just paste it without moving
    bind -s --preset o forward-char yank
    bind -s --preset O yank
    bind -s --preset go yank-pop

    # same vim 'pasting' note as upper
    bind -s --preset '"*p' forward-char "commandline -i ( xsel -p; echo )[1]"
    bind -s --preset '"*P' "commandline -i ( xsel -p; echo )[1]"

    #
    # Lowercase r, enters replace_one mode
    #
    bind -s --preset -m replace_one p repaint-mode
    bind -s --preset -M replace_one -m default '' delete-char self-insert backward-char repaint-mode
    bind -s --preset -M replace_one -m default \r 'commandline -f delete-char; commandline -i \n; commandline -f backward-char; commandline -f repaint-mode'
    bind -s --preset -M replace_one -m default \e cancel repaint-mode

    #
    # Uppercase R, enters replace mode
    #
    bind -s --preset -m replace P repaint-mode
    bind -s --preset -M replace '' delete-char self-insert
    bind -s --preset -M replace -m insert \r execute repaint-mode
    bind -s --preset -M replace -m default \e cancel repaint-mode
    # in vim (and maybe in vi), <BS> deletes the changes
    # but this binding just move cursor backward, not delete the changes
    bind -s --preset -M replace -k backspace backward-char

    #
    # visual mode
    #
    bind -s --preset -M visual m backward-char
    bind -s --preset -M visual i forward-char

    bind -s --preset -M visual e up-line
    bind -s --preset -M visual n down-line

    bind -s --preset -M visual z backward-word
    bind -s --preset -M visual Z backward-bigword
    bind -s --preset -M visual gf backward-word
    bind -s --preset -M visual gF backward-bigword
    bind -s --preset -M visual w forward-word
    bind -s --preset -M visual W forward-bigword
    bind -s --preset -M visual f forward-word
    bind -s --preset -M visual F forward-bigword
    bind -s --preset -M visual y swap-selection-start-stop repaint-mode

    bind -s --preset -M visual t forward-jump
    bind -s --preset -M visual b forward-jump-till
    bind -s --preset -M visual T backward-jump
    bind -s --preset -M visual B backward-jump-till

    for key in $eol_keys
        bind -s --preset -M visual $key end-of-line
    end
    for key in $bol_keys
        bind -s --preset -M visual $key beginning-of-line
    end

    bind -s --preset -M visual -m insert d kill-selection end-selection repaint-mode
    bind -s --preset -M visual -m insert r kill-selection end-selection repaint-mode
    bind -s --preset -M visual -m default s kill-selection end-selection repaint-mode
    bind -s --preset -M visual -m default c kill-selection end-selection repaint-mode
    bind -s --preset -M visual -m default C kill-whole-line end-selection repaint-mode
    bind -s --preset -M visual -m default j kill-selection yank end-selection repaint-mode
    bind -s --preset -M visual -m default '"*j' "fish_clipboard_copy; commandline -f end-selection repaint-mode"
    bind -s --preset -M visual -m default '~' togglecase-selection end-selection repaint-mode

    bind -s --preset -M visual -m default \cc end-selection repaint-mode
    bind -s --preset -M visual -m default \e end-selection repaint-mode

    # Make it easy to turn an unexecuted command into a comment in the shell history. Also, remove
    # the commenting chars so the command can be further edited then executed.
    bind -s --preset -M default \# __fish_toggle_comment_commandline
    bind -s --preset -M visual \# __fish_toggle_comment_commandline
    bind -s --preset -M replace \# __fish_toggle_comment_commandline

    # Set the cursor shape
    # After executing once, this will have defined functions listening for the variable.
    # Therefore it needs to be before setting fish_bind_mode.
    fish_vi_cursor

    set fish_bind_mode $init_mode

    bind -s --preset \cA -M insert beginning-of-line
    bind -s --preset \cA beginning-of-line
    bind -s --preset \cF -M insert end-of-line
    bind -s --preset \cF end-of-line
    bind -s --preset \cT -M insert accept-autosuggestion
    bind -s --preset \cT accept-autosuggestion
    bind -s --preset \cP -M insert _fzf-multi-command-history-widget
    bind -s --preset \cP _fzf-multi-command-history-widget
    bind -s --preset \ck -M insert down-or-search
    bind -s --preset \ck down-or-search
    bind -s --preset \ce -M insert up-or-search
    bind -s --preset \ce up-or-search
    bind -s --preset \cn -M insert down-or-search
    bind -s --preset \cn down-or-search

    # For some reason someone unbinds our enter key up to this point
    # Make sure we can execute commands here
    bind -s --preset -M insert \r execute
    bind -s --preset -M insert \n execute
end

function __fishmak_shared_key_bindings -d "Bindings shared between emacs and vi mode"
    # These are some bindings that are supposed to be shared between vi mode and default mode.
    # They are supposed to be unrelated to text-editing (or movement).
    # This takes $argv so the vi-bindings can pass the mode they are valid in.

    if contains -- -h $argv
        or contains -- --help $argv
        echo "Sorry but this function doesn't support -h or --help"
        return 1
    end

    bind --preset --preset $argv \cy yank
    or return # protect against invalid $argv
    bind --preset --preset $argv \ey yank-pop

    # Left/Right arrow
    bind --preset --preset $argv -k right forward-char
    bind --preset --preset $argv -k left backward-char
    bind --preset --preset $argv \e\[C forward-char
    bind --preset --preset $argv \e\[D backward-char
    # Some terminals output these when they're in in keypad mode.
    bind --preset --preset $argv \eOC forward-char
    bind --preset --preset $argv \eOD backward-char

    # Ctrl-left/right - these also work in vim.
    bind --preset --preset $argv \e\[1\;5C forward-word
    bind --preset --preset $argv \e\[1\;5D backward-word

    bind --preset --preset $argv -k ppage beginning-of-history
    bind --preset --preset $argv -k npage end-of-history

    # Interaction with the system clipboard.
    bind --preset --preset $argv \cx fish_clipboard_copy
    bind --preset --preset $argv \cv fish_clipboard_paste

    bind --preset --preset $argv \e cancel
    bind --preset --preset $argv \t complete
    bind --preset --preset $argv \cs pager-toggle-search
    # shift-tab does a tab complete followed by a search.
    bind --preset --preset $argv --key btab complete-and-search

    bind --preset --preset $argv \e\n "commandline -f expand-abbr; commandline -i \n"
    bind --preset --preset $argv \e\r "commandline -f expand-abbr; commandline -i \n"

    bind --preset --preset $argv -k down down-or-search
    bind --preset --preset $argv -k up up-or-search
    bind --preset --preset $argv \e\[A up-or-search
    bind --preset --preset $argv \e\[B down-or-search
    bind --preset --preset $argv \eOA up-or-search
    bind --preset --preset $argv \eOB down-or-search

    bind --preset --preset $argv -k sright forward-bigword
    bind --preset --preset $argv -k sleft backward-bigword

    # Alt-left/Alt-right
    bind --preset --preset $argv \e\eOC nextd-or-forward-word
    bind --preset --preset $argv \e\eOD prevd-or-backward-word
    bind --preset --preset $argv \e\e\[C nextd-or-forward-word
    bind --preset --preset $argv \e\e\[D prevd-or-backward-word
    bind --preset --preset $argv \eO3C nextd-or-forward-word
    bind --preset --preset $argv \eO3D prevd-or-backward-word
    bind --preset --preset $argv \e\[3C nextd-or-forward-word
    bind --preset --preset $argv \e\[3D prevd-or-backward-word
    bind --preset --preset $argv \e\[1\;3C nextd-or-forward-word
    bind --preset --preset $argv \e\[1\;3D prevd-or-backward-word
    bind --preset --preset $argv \e\[1\;9C nextd-or-forward-word #iTerm2
    bind --preset --preset $argv \e\[1\;9D prevd-or-backward-word #iTerm2

    # Alt-up/Alt-down
    bind --preset --preset $argv \e\eOA history-token-search-backward
    bind --preset --preset $argv \e\eOB history-token-search-forward
    bind --preset --preset $argv \e\e\[A history-token-search-backward
    bind --preset --preset $argv \e\e\[B history-token-search-forward
    bind --preset --preset $argv \eO3A history-token-search-backward
    bind --preset --preset $argv \eO3B history-token-search-forward
    bind --preset --preset $argv \e\[3A history-token-search-backward
    bind --preset --preset $argv \e\[3B history-token-search-forward
    bind --preset --preset $argv \e\[1\;3A history-token-search-backward
    bind --preset --preset $argv \e\[1\;3B history-token-search-forward
    bind --preset --preset $argv \e\[1\;9A history-token-search-backward # iTerm2
    bind --preset --preset $argv \e\[1\;9B history-token-search-forward # iTerm2
    # Bash compatibility
    # https://github.com/fish-shell/fish-shell/issues/89
    bind --preset --preset $argv \e. history-token-search-backward

    bind --preset --preset $argv \el __fish_list_current_token
    bind --preset --preset $argv \eo __fish_preview_current_file
    bind --preset --preset $argv \ew __fish_whatis_current_token
    # ncurses > 6.0 sends a "delete scrollback" sequence along with clear.
    # This string replace removes it.
    bind --preset --preset $argv \cl 'echo -n (clear | string replace \e\[3J ""); commandline -f repaint'
    bind --preset --preset $argv \cc cancel-commandline
    bind --preset --preset $argv \cu backward-kill-line
    bind --preset --preset $argv \cw backward-kill-path-component
    bind --preset --preset $argv \e\[F end-of-line
    bind --preset --preset $argv \e\[H beginning-of-line

    bind --preset --preset $argv \ed 'set -l cmd (commandline); if test -z "$cmd"; echo; dirh; commandline -f repaint; else; commandline -f kill-word; end'
    bind --preset --preset $argv \cd delete-or-exit

    bind --preset --preset $argv \es "fish_commandline_prepend sudo"

    # Allow reading manpages by pressing F1 (many GUI applications) or Alt+h (like in zsh).
    bind --preset --preset $argv -k f1 __fish_man_page
    bind --preset --preset $argv \eh __fish_man_page

    # This will make sure the output of the current command is paged using the default pager when
    # you press Meta-p.
    # If none is set, less will be used.
    bind --preset --preset $argv \ep __fish_paginate

    # Make it easy to turn an unexecuted command into a comment in the shell history. Also,
    # remove the commenting chars so the command can be further edited then executed.
    bind --preset --preset $argv \e\# __fish_toggle_comment_commandline

    # The [meta-e] and [meta-v] keystrokes invoke an external editor on the command buffer.
    bind --preset --preset $argv \ee edit_command_buffer
    bind --preset --preset $argv \ev edit_command_buffer

    # Tmux' focus events.
    # Exclude paste mode because that should get _everything_ literally.
    for mode in (bind --list-modes | string match -v paste)
        # We only need the in-focus event currently (to redraw the vi-cursor).
        bind --preset -M $mode \e\[I 'emit fish_focus_in'
        bind --preset -M $mode \e\[O false
        bind --preset -M $mode \e\[\?1004h false
    end

    # Support for "bracketed paste"
    # The way it works is that we acknowledge our support by printing
    # \e\[?2004h
    # then the terminal will "bracket" every paste in
    # \e\[200~ and \e\[201~
    # Every character in between those two will be part of the paste and should not cause a binding to execute (like \n executing commands).
    #
    # We enable it after every command and disable it before (in __fish_config_interactive.fish)
    #
    # Support for this seems to be ubiquitous - emacs enables it unconditionally (!) since 25.1
    # (though it only supports it since then, it seems to be the last term to gain support).
    #
    # NOTE: This is more of a "security" measure than a proper feature.
    # The better way to paste remains the `fish_clipboard_paste` function (bound to \cv by default).
    # We don't disable highlighting here, so it will be redone after every character (which can be slow),
    # and it doesn't handle "paste-stop" sequences in the paste (which the terminal needs to strip).
    #
    # See http://thejh.net/misc/website-terminal-copy-paste.

    # Bind the starting sequence in every bind mode, even user-defined ones.
    # Exclude paste mode or there'll be an additional binding after switching between emacs and vi
    for mode in (bind --list-modes | string match -v paste)
        bind --preset -M $mode -m paste \e\[200~ __fishmak_start_bracketed_paste
    end
    # This sequence ends paste-mode and returns to the previous mode we have saved before.
    bind --preset --preset -M paste \e\[201~ __fishmak_stop_bracketed_paste
    # In paste-mode, everything self-inserts except for the sequence to get out of it
    bind --preset --preset -M paste "" self-insert
    # Without this, a \r will overwrite the other text, rendering it invisible - which makes the exercise kinda pointless.
    bind --preset --preset -M paste \r "commandline -i \n"

    # We usually just pass the text through as-is to facilitate pasting code,
    # but when the current token contains an unbalanced single-quote (`'`),
    # we escape all single-quotes and backslashes, effectively turning the paste
    # into one literal token, to facilitate pasting non-code (e.g. markdown or git commitishes)
    bind --preset --preset -M paste "'" "__fishmak_commandline_insert_escaped \' \$__fish_paste_quoted"
    bind --preset --preset -M paste \\ "__fishmak_commandline_insert_escaped \\\ \$__fish_paste_quoted"
    # Only insert spaces if we're either quoted or not at the beginning of the commandline
    # - this strips leading spaces if they would trigger histignore.
    bind --preset --preset -M paste " " self-insert-notfirst
end

function __fishmak_commandline_insert_escaped --description 'Insert the first arg escaped if a second arg is given'
    if set -q argv[2]
        commandline -i \\$argv[1]
    else
        commandline -i $argv[1]
    end
end

function __fishmak_start_bracketed_paste
    # Save the last bind mode so we can restore it.
    set -g __fish_last_bind_mode $fish_bind_mode
    # If the token is currently single-quoted,
    # we escape single-quotes (and backslashes).
    string match -q 'single*' (__fish_tokenizer_state -- (commandline -ct | string collect))
    and set -g __fish_paste_quoted 1
end

function __fishmak_stop_bracketed_paste
    # Restore the last bind mode.
    set fish_bind_mode $__fish_last_bind_mode
    set -e __fish_paste_quoted
end
