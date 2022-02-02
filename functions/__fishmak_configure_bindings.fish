function __fishmak_configure_bindings --description "Install the default key bindings."

    bind --erase --all # clear earlier bindings, if any

    set -l init_mode insert
    # These are only the special vi-style keys
    # not end/home, we share those.
    set -l eol_keys \$ g\$
    set -l bol_keys \^ 0 g\^

    # Inherit shared key bindings.
    # Do this first so vi-bindings win over default.
    for mode in insert default visual
        __fish_shared_key_bindings -s -M $mode
    end

    bind -s -M insert \r execute
    bind -s -M insert \n execute

    bind -s -M insert "" self-insert
     
    # Space and other command terminators expand abbrs _and_ inserts itself.
    bind -s -M insert " " self-insert expand-abbr
    bind -s -M insert ";" self-insert expand-abbr
    bind -s -M insert "|" self-insert expand-abbr
    bind -s -M insert "&" self-insert expand-abbr
    bind -s -M insert "^" self-insert expand-abbr
    bind -s -M insert ">" self-insert expand-abbr
    bind -s -M insert "<" self-insert expand-abbr
    # Closing a command substitution expands abbreviations
    bind -s -M insert ")" self-insert expand-abbr
    # Ctrl-space inserts space without expanding abbrs
    bind -s -M insert -k nul 'commandline -i " "'

    # Add a way to switch from insert to normal (command) mode.
    # Note if we are paging, we want to stay in insert mode
    # See #2871
    bind -s -M insert \e "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char repaint-mode; end"

    # Default (command) mode
    bind -s :q exit
    bind -s -m insert \cc cancel-commandline repaint-mode
    bind -s -M default m backward-char
    bind -s -M default i forward-char
    bind -s -m insert \n execute
    bind -s -m insert \r execute
    bind -s -m insert y insert-line-under repaint-mode
    bind -s -m insert Y insert-line-over repaint-mode
    bind -s -m insert u repaint-mode
    bind -s -m insert U beginning-of-line repaint-mode
    bind -s -m insert a forward-single-char repaint-mode
    bind -s -m insert A end-of-line repaint-mode
    bind -s -m visual d begin-selection repaint-mode

    #bind -s -m insert o "commandline -a \n" down-line repaint-mode
    #bind -s -m insert O beginning-of-line "commandline -i \n" up-line repaint-mode # doesn't work
    # 
    bind -s gg beginning-of-buffer
    bind -s G end-of-buffer

    for key in $eol_keys
        bind -s $key end-of-line
    end
    for key in $bol_keys
        bind -s $key beginning-of-line
    end

    bind -s l undo
    bind -s \cp redo

    bind -s [ history-token-search-backward
    bind -s ] history-token-search-forward

    bind -s e up-or-search
    bind -s n down-or-search
    bind -s v backward-word
    bind -s V backward-bigword
    bind -s gf backward-word
    bind -s gF backward-bigword
    bind -s w forward-word forward-single-char
    bind -s W forward-bigword forward-single-char
    bind -s f forward-single-char forward-word backward-char
    bind -s F forward-bigword backward-char

    # Vi/Vim doesn't support these keys in insert mode but that seems silly so we do so anyway.
    bind -s -M insert -k home beginning-of-line
    bind -s -M default -k home beginning-of-line
    bind -s -M insert -k end end-of-line
    bind -s -M default -k end end-of-line

    # Vi moves the cursor back if, after deleting, it is at EOL.
    # To emulate that, move forward, then backward, which will be a NOP
    # if there is something to move forward to.
    bind -s -M default x delete-char forward-single-char backward-char
    bind -s -M default X backward-delete-char
    bind -s -M insert -k sc delete-char forward-single-char backward-char
    bind -s -M default -k sc delete-char forward-single-char backward-char

    # Backspace deletes a char in insert mode, but not in normal/default mode.
    # THIS probably breaks enter char
    # bind -s -M insert -k backspace backward-delete-char
    # bind -s -M default -k backspace backward-char
    # bind -s -M insert \cm backward-delete-char
    # bind -s -M default \cm backward-char
    # bind -s -M insert \x7f backward-delete-char
    # bind -s -M default \x7f backward-char
    # bind -s -M insert -k sdc backward-delete-char # shifted delete
    # bind -s -M default -k sdc backward-delete-char # shifted delete

    bind -s ss kill-whole-line
    bind -s S kill-line
    bind -s s\$ kill-line
    bind -s s\^ backward-kill-line
    bind -s s0 backward-kill-line
    bind -s sw kill-word
    bind -s sW kill-bigword
    bind -s suw forward-single-char forward-single-char backward-word kill-word
    bind -s suW forward-single-char forward-single-char backward-bigword kill-bigword
    bind -s saw forward-single-char forward-single-char backward-word kill-word
    bind -s saW forward-single-char forward-single-char backward-bigword kill-bigword
    bind -s sf kill-word
    bind -s sF kill-bigword
    bind -s sv backward-kill-word
    bind -s sV backward-kill-bigword
    bind -s sgf backward-kill-word
    bind -s sgF backward-kill-bigword
    bind -s st begin-selection forward-jump kill-selection end-selection
    bind -s sb begin-selection forward-jump backward-char kill-selection end-selection
    bind -s sT begin-selection backward-jump kill-selection end-selection
    bind -s sB begin-selection backward-jump forward-single-char kill-selection end-selection
    bind -s sm backward-char delete-char
    bind -s si delete-char
    bind -s su backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection
    bind -s sa backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection
    bind -s 's;' begin-selection repeat-jump kill-selection end-selection
    bind -s 's,' begin-selection repeat-jump-reverse kill-selection end-selection

    bind -s -m insert r delete-char repaint-mode
    bind -s -m insert r kill-whole-line repaint-mode
    bind -s -m insert cc kill-whole-line repaint-mode
    bind -s -m insert C kill-line repaint-mode
    bind -s -m insert c\$ kill-line repaint-mode
    bind -s -m insert c\^ backward-kill-line repaint-mode
    bind -s -m insert c0 backward-kill-line repaint-mode
    bind -s -m insert cw kill-word repaint-mode
    bind -s -m insert cW kill-bigword repaint-mode
    bind -s -m insert cuw forward-single-char forward-single-char backward-word kill-word repaint-mode
    bind -s -m insert cuW forward-single-char forward-single-char backward-bigword kill-bigword repaint-mode
    bind -s -m insert caw forward-single-char forward-single-char backward-word kill-word repaint-mode
    bind -s -m insert caW forward-single-char forward-single-char backward-bigword kill-bigword repaint-mode
    bind -s -m insert cf kill-word repaint-mode
    bind -s -m insert cF kill-bigword repaint-mode
    bind -s -m insert cv backward-kill-word repaint-mode
    bind -s -m insert cV backward-kill-bigword repaint-mode
    bind -s -m insert cgf backward-kill-word repaint-mode
    bind -s -m insert cgF backward-kill-bigword repaint-mode
    bind -s -m insert ct begin-selection forward-jump kill-selection end-selection repaint-mode
    bind -s -m insert cb begin-selection forward-jump backward-char kill-selection end-selection repaint-mode
    bind -s -m insert cT begin-selection backward-jump kill-selection end-selection repaint-mode
    bind -s -m insert cB begin-selection backward-jump forward-single-char kill-selection end-selection repaint-mode
    bind -s -m insert cm backward-char begin-selection kill-selection end-selection repaint-mode
    bind -s -m insert ci begin-selection kill-selection end-selection repaint-mode
    bind -s -m insert cu backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode
    bind -s -m insert ca backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode

    bind -s '~' togglecase-char forward-single-char
    bind -s gl downcase-word
    bind -s gL upcase-word

    bind -s N end-of-line delete-char
    bind -s E 'man (commandline -t) 2>/dev/null; or echo -n \a'

    bind -s jj kill-whole-line yank
    bind -s J kill-whole-line yank
    bind -s j\$ kill-line yank
    bind -s j\^ backward-kill-line yank
    bind -s j0 backward-kill-line yank
    bind -s jw kill-word yank
    bind -s jW kill-bigword yank
    bind -s juw forward-single-char forward-single-char backward-word kill-word yank
    bind -s juW forward-single-char forward-single-char backward-bigword kill-bigword yank
    bind -s jaw forward-single-char forward-single-char backward-word kill-word yank
    bind -s jaW forward-single-char forward-single-char backward-bigword kill-bigword yank
    bind -s jf kill-word yank
    bind -s jF kill-bigword yank
    bind -s jv backward-kill-word yank
    bind -s jV backward-kill-bigword yank
    bind -s jgf backward-kill-word yank
    bind -s jgF backward-kill-bigword yank
    bind -s jt begin-selection forward-jump kill-selection yank end-selection
    bind -s jb begin-selection forward-jump-till kill-selection yank end-selection
    bind -s jT begin-selection backward-jump kill-selection yank end-selection
    bind -s jB begin-selection backward-jump-till kill-selection yank end-selection
    bind -s jm backward-char begin-selection kill-selection yank end-selection
    bind -s ji begin-selection kill-selection yank end-selection
    bind -s ju backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection yank end-selection
    bind -s ja backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection yank end-selection

    bind -s t forward-jump
    bind -s T backward-jump
    bind -s b forward-jump-till
    bind -s B backward-jump-till
    bind -s ';' repeat-jump
    bind -s , repeat-jump-reverse

    # in emacs yank means paste
    # in vim p means paste *after* current character, so go forward a char before pasting
    # also in vim, P means paste *at* current position (like at '|' with cursor = line),
    # \ so there's no need to go back a char, just paste it without moving
    bind -s o forward-char yank
    bind -s O yank
    bind -s go yank-pop

    # same vim 'pasting' note as upper
    bind -s '"*p' forward-char "commandline -i ( xsel -p; echo )[1]"
    bind -s '"*P' "commandline -i ( xsel -p; echo )[1]"

    #
    # Lowercase r, enters replace_one mode
    #
    bind -s -m replace_one p repaint-mode
    bind -s -M replace_one -m default '' delete-char self-insert backward-char repaint-mode
    bind -s -M replace_one -m default \r 'commandline -f delete-char; commandline -i \n; commandline -f backward-char; commandline -f repaint-mode'
    bind -s -M replace_one -m default \e cancel repaint-mode

    #
    # Uppercase R, enters replace mode
    #
    bind -s -m replace P repaint-mode
    bind -s -M replace '' delete-char self-insert
    bind -s -M replace -m insert \r execute repaint-mode
    bind -s -M replace -m default \e cancel repaint-mode
    # in vim (and maybe in vi), <BS> deletes the changes
    # but this binding just move cursor backward, not delete the changes
    bind -s -M replace -k backspace backward-char

    #
    # visual mode
    #
    bind -s -M visual m backward-char
    bind -s -M visual i forward-char

    bind -s -M visual e up-line
    bind -s -M visual n down-line

    bind -s -M visual v backward-word
    bind -s -M visual V backward-bigword
    bind -s -M visual gf backward-word
    bind -s -M visual gF backward-bigword
    bind -s -M visual w forward-word
    bind -s -M visual W forward-bigword
    bind -s -M visual f forward-word
    bind -s -M visual F forward-bigword
    bind -s -M visual y swap-selection-start-stop repaint-mode

    bind -s -M visual t forward-jump
    bind -s -M visual b forward-jump-till
    bind -s -M visual T backward-jump
    bind -s -M visual B backward-jump-till

    for key in $eol_keys
        bind -s -M visual $key end-of-line
    end
    for key in $bol_keys
        bind -s -M visual $key beginning-of-line
    end

    bind -s -M visual -m insert c kill-selection end-selection repaint-mode
    bind -s -M visual -m insert r kill-selection end-selection repaint-mode
    bind -s -M visual -m default s kill-selection end-selection repaint-mode
    bind -s -M visual -m default x kill-selection end-selection repaint-mode
    bind -s -M visual -m default X kill-whole-line end-selection repaint-mode
    bind -s -M visual -m default j kill-selection yank end-selection repaint-mode
    bind -s -M visual -m default '"*j' "fish_clipboard_copy; commandline -f end-selection repaint-mode"
    bind -s -M visual -m default '~' togglecase-selection end-selection repaint-mode

    bind -s -M visual -m default \cc end-selection repaint-mode
    bind -s -M visual -m default \e end-selection repaint-mode

    # Make it easy to turn an unexecuted command into a comment in the shell history. Also, remove
    # the commenting chars so the command can be further edited then executed.
    bind -s -M default \# __fish_toggle_comment_commandline
    bind -s -M visual \# __fish_toggle_comment_commandline
    bind -s -M replace \# __fish_toggle_comment_commandline

    # Set the cursor shape
    # After executing once, this will have defined functions listening for the variable.
    # Therefore it needs to be before setting fish_bind_mode.
    # fish_vi_cursor

    set fish_bind_mode $init_mode

    bind \cA -M insert beginning-of-line
    bind \cA beginning-of-line
    bind \cF -M insert end-of-line
    bind \cF end-of-line
    bind \cT -M insert accept-autosuggestion
    bind \cT accept-autosuggestion
    bind \cP -M insert _fzf-multi-command-history-widget
    bind \cP _fzf-multi-command-history-widget
    bind \; -M insert up-or-search
    bind \; up-or-search

end
