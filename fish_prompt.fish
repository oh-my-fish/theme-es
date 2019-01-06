# Powerline-patched fonts are required

# Global variables that affect how left and right prompts look like
set -g symbols_style                   'symbols'
set -g theme_display_git_ahead_verbose  yes
set -g theme_hide_hostname              no
set -g theme_display_user               no

function fish_prompt
  set -g last_status $status                                         #exit status of last command
  #set -l count (_file_count)
  _icons_initialize
  set -l p_path2 (_col brblue o u)(prompt_pwd2)(_col_res)            #path shortened to last two folders ($count)
  set -l symbols ''                                                  #add some pre-path symbols
  if [ $symbols_style = 'symbols' ]
    if [ ! -w . ];    set symbols $symbols(_col ff6600);           end
    if set -q -x VIM; set symbols $symbols(_col 3300ff o)$ICON_VIM; end
  end
  if [ (_is_git_dirty) ]; set dirty ''; else; set dirty ' '; end     #add space only in clean git branches
  if test $last_status = 0                                           #prompt symbol green normal, red on error
    set prompt (_col green b)"$dirty"(_UserSymbol)(_col_res)' '
  else
    set prompt (_col brred b)"$dirty"(_UserSymbol)(_col_res)' '
  end

  echo -n -s $symbols$p_path2                                        #-n no newline, -s no space separation of arguments
  _is_git_folder; and _prompt_git
  echo -n -s $prompt
end

function fish_right_prompt
  if test $last_status -gt 0                                         #set error code in red
    set errorp (_col brred)"$last_status⏎"(_col_res)" "
  end
  set -l duration (_cmd_duration)                                    #set duration of last command
  if [ (jobs -l | wc -l) -gt 0 ]                                     #set ⚙ if any background jobs exit
    set jobsp $ICON_JOBS
  end
  echo -n -s "$errorp$duration$jobsp"                                #show error code, command duration and jobs status
  if _is_git_folder                                                  #show  only if in a git folder
  #command git rev-parse --is-inside-work-tree 1>/dev/null 2>/dev/null
    set git_sha (_git_prompt_short_sha)                              #git short sha
    set NODEp   (_node_version)                                      #Node.js version
    set PYTHONp (_python_version)                                    #Python version
    set RUBYp   (_ruby_version)                                      #Ruby prompt @ gemset
    echo -n -s "$git_sha$NODEp$PYTHONp$RUBYp"                        # -n no newline -s no space separation
  end
  echo -n -s (_prompt_user)                                          #display user@host if different from default or SSH
end

function _cmd_duration -d 'Displays the elapsed time of last command and show notification for long lasting commands'
  set -l days ''; set -l hours ''; set -l minutes ''; set -l seconds ''
  set -l duration (expr $CMD_DURATION / 1000)
  if [ $duration -gt 0 ]
    set seconds (expr $duration \% 68400 \% 3600 \% 60)'s'
    if [ $duration -ge 60 ]
      set minutes (expr $duration \% 68400 \% 3600 / 60)'m'
      if [ $duration -ge 3600 ]
        set hours (expr $duration \% 68400 / 3600)'h'
        if [ $duration -ge 68400 ]
          set days (expr $duration / 68400)'d'
        end
      end
    end
    set -l duration $days$hours$minutes$seconds
    if [ $last_status -ne 0 ]
      echo -n (_col brred)$duration(_col_res)
    else
      echo -n (_col brgreen)$duration(_col_res)
    end
    # OS X notification when a command takes longer than notify_duration and iTerm is not focused
    set notify_duration 10000
    set exclude_cmd "bash|less|man|more|ssh"
    if begin
      test $CMD_DURATION -gt $notify_duration
      and echo $history[1] | grep -vqE "^($exclude_cmd).*"
    end
    set -l osname (uname)
    if test $osname = Darwin          # only show notification in OS X
      #Only show the notification if iTerm and Terminal are not focused
      echo "
        tell application \"System Events\"
            set activeApp to name of first application process whose frontmost is true
            if \"iTerm\" is not in activeApp and \"Terminal\" is not in activeApp then
                display notification \"Finished in $duration\" with title \"$history[1]\"
            end if
        end tell
        " | osascript
    end
    end
  end
end

function _col                                     #Set Color 'name b u' bold, underline
  set -l col; set -l bold; set -l under
  if [ -n "$argv[1]" ];       set col   $argv[1]; end
  if [ (count $argv) -gt 1 ]; set bold  "-"(string replace b o $argv[2] 2>/dev/null); end
  if [ (count $argv) -gt 2 ]; set under "-"$argv[3]; end
  set_color $bold $under $argv[1]
end
function _col_res -d "Rest background and foreground colors"
  set_color -b normal
  set_color normal
end

function prompt_pwd2
  set realhome ~
  set -l _tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $PWD)  #replace $HOME with '~' in path
  set -l _tmp2 (basename (dirname $_tmp))/(basename $_tmp)          #get last two dirs from path
  echo (string trim -l -c=/ (string replace "./~" "~" $_tmp2))      #trim left '/' or './' for special cases
end
function prompt_pwd_full
  set -q fish_prompt_pwd_dir_length; or set -l fish_prompt_pwd_dir_length 1
  if [ $fish_prompt_pwd_dir_length -eq 0 ]
    set -l fish_prompt_pwd_dir_length 99999
  end
  set -l realhome ~
  echo $PWD | sed -e "s|^$realhome|~|" -e 's-\([^/.]{'"$fish_prompt_pwd_dir_length"'}\)[^/]*/-\1/-g'
end

function _file_count
  ls -1 | wc -l | sed 's/\ //g'
end

function _prompt_user -d "Display current user if different from $default_user"
  if [ "$theme_display_user" = "yes" ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      set USER (whoami)
      get_hostname
      if [ $HOSTNAME_PROMPT ]
        set USER_PROMPT (_col green)$USER(_col grey)"@"(_col $ORANGE)$HOSTNAME_PROMPT
      else
        set USER_PROMPT (_col green)$USER(_col grey)
      end
      echo -n -s (_col green)" $USER_PROMPT"
    end
  else
    get_hostname
    if [ $HOSTNAME_PROMPT ]
      echo -n -s (_col $ORANGE)"$HOSTNAME_PROMPT"
    end
  end
end
function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
  set -g HOSTNAME_PROMPT ""
  if [ "$theme_hide_hostname" != "yes" -a -n "$SSH_CLIENT" ]
    set -g HOSTNAME_PROMPT (hostname)
  end
end

function _UserSymbol                                                #prompt symbol: '#' superuser or '>' user
  if test (id -u $USER) -eq 0
    echo "#"
  else
    echo ">"
  end
end

function _prompt_git -a current_dir -d 'Display the actual git state'
  set -l dirty (command git diff --no-ext-diff --quiet --exit-code; or echo -n ' ')
  set -l flag_fg (_col brgreen)
  if [ "$dirty" -o "$staged" ]                                      # if either dirty or staged
    set flag_fg (_col yellow)
  else if [ "$stashed" ]
    set flag_fg (_col brred)
  end
  echo -n -s $flag_fg(_git_branch)(_git_status)(_col_res)           #add space if dirty to separate from icons "$dirty"
end
function _git_status -d 'Check git status'
  set -l git_status (command git status --porcelain 2> /dev/null | cut -c 1-2)
  set -l ahead (_git_ahead); echo -n $ahead                                    #show # of commits ahead/behind
  if [ (echo -sn $git_status\n | egrep -c "[ACDMT][ MT]|[ACMT]D") -gt 0 ]      #added
    echo -n (_col green)$ICON_VCS_STAGED
  end
  #set -l staged  (command git diff --cached --no-ext-diff --quiet --exit-code; or echo -n '~')      #was '~'
  if [ (echo -sn $git_status\n | egrep -c "[ ACMRT]D") -gt 0 ]                  #deleted
    echo -n (_col red)$ICON_VCS_DELETED
  end
  if [ (echo -sn $git_status\n | egrep -c ".[MT]") -gt 0 ]                      #modified
    echo -n (_col $ORANGE)$ICON_VCS_MODIFIED
  end
  if [ (echo -sn $git_status\n | egrep -c "R.") -gt 0 ]                         #renamed
    echo -n (_col purple)$ICON_VCS_RENAME
  end
  if [ (echo -sn $git_status\n | egrep -c "AA|DD|U.|.U") -gt 0 ]                #unmerged
    echo -n (_col brred)$ICON_VCS_UNMERGED(_col_res)
  end
  if [ (echo -sn $git_status\n | egrep -c "\?\?") -gt 0 ]                       #untracked (new) files
    echo -n (_col brcyan)$ICON_VCS_UNTRACKED
  end
  if test (command git rev-parse --verify --quiet refs/stash >/dev/null)        #stashed (was '$')
    echo -n (_col brred)$ICON_VCS_STASH
  end

  #set -l untracked ''
  #set -l show_untracked (git config --bool bash.showUntrackedFiles)
  #if [ "$theme_display_git_untracked" != 'no' -a "$show_untracked" != 'false' ]
  #  set untracked (command git ls-files --other --exclude-standard --directory --no-empty-directory)
  #  if [ "$untracked" ]
  #    set untracked $ICON_VCS_UNTRACKED           #was …
  #  end
  #end
  echo ''
  #echo -n $added\n$deleted\n$modified\n$renamed\n$unmerged\n$untracked
end
function _is_git_dirty -d 'Check if branch is dirty'
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)             #'-s' short format
end
function _git_branch -d "Display the current git state"
  set -l ref
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set ref (command git symbolic-ref HEAD 2>/dev/null)
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev |head -n1 2>/dev/null)
      set ref " $ICON_VCS_DETACHED_BRANCH$branch"
    end
    set -l branch (echo $ref | sed  "s-refs/heads/--")
    echo " $ICON_VCS_BRANCH"(_col magenta)"$branch"(_col_res)
  end
end
function _is_git_folder     -d "Check if current folder is a git folder"
  git status 1>/dev/null 2>/dev/null
end
function _git_ahead -d         'Print the ahead/behind state for the current branch'
  if [ "$theme_display_git_ahead_verbose" = 'yes' ]
    _git_ahead_verbose
    return
  end
  command git rev-list --left-right '@{upstream}...HEAD' 2> /dev/null | awk '/>/ {a += 1} /</ {b += 1} {if (a > 0 && b > 0) nextfile} END {if (a > 0 && b > 0) print "⇕"; else if (a > 0) print ""; else if (b > 0) print ""}' #↑↓⇕⬍↕
end
function _git_ahead_verbose -d 'Print a more verbose ahead/behind state for the current branch'
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' 2> /dev/null)
  if [ $status != 0 ]
    return
  end
  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead  (count (for arg in $commits; echo $arg; end | grep -v '^<'))
  switch "$ahead $behind"
    case ''     # no upstream
    case '0 0'  # equal to upstream
      return
    case '* 0'  # ahead of upstream
      echo (_col blue)"$ICON_ARROW_UP$ahead"
    case '0 *'  # behind upstream
      echo (_col red)"$ICON_ARROW_DOWN$behind"
    case '*'    # diverged from upstream
      echo (_col blue)"$ICON_ARROW_UP$ahead"(_col red)"$ICON_ARROW_DOWN$behind"
  end
end
function _git_prompt_short_sha
  set -l SHA (command git rev-parse --short HEAD 2> /dev/null)
  test $SHA; and echo -n -s (_col brcyan)\[(_col brgrey)$SHA(_col brcyan)\](_col_res)
end
function _git_prompt_long_sha
  set -l SHA (command git rev-parse HEAD 2> /dev/null)
  test $SHA; and echo -n -s (_col brcyan)\[(_col brgrey)$SHA(_col brcyan)\](_col_res)
end

function _node_version -d "Get the currently used node version if NVM exists"
  set -l node_version
  type -q nvm; and set node_version (string trim -l -c=v (node -v 2>/dev/null)) # trimmed lef 'v'; can use 'nvm current', but slower
  test $node_version; and echo -n -s (_col brgreen)$ICON_NODE(_col green)$node_version(_col_res)
end

function _ruby_version -d "Get RVM or rbenv version and output" #2>&1 stderr2stdout, >&2 vice versa, '>' stdout, '2>' stderr
  set -l ruby_ver
  if which rvm-prompt >/dev/null 2>&1
    set ruby_ver (rvm-prompt i v g)
  else
    if which rbenv >/dev/null 2>&1
      set ruby_ver (rbenv version-name)
    end
  end
  if test -n (_rbenv_gemset 2>/dev/null; or echo "")
    test $ruby_ver; and echo -n -s (_col brred)$ICON_RUBY(_col green)$ruby_ver(_col grey)"@"(_col brgrey)(_rbenv_gemset)(_col_res)
  else
    test $ruby_ver; and echo -n -s (_col brred)$ICON_RUBY(_col green)$ruby_ver(_col_res)
  end
end

function _rbenv_gemset -d "Get main current gemset name"
  if type -q rbenv
    if test (rbenv gemset active 2>/dev/null)                           #redirects stderr to /null
      set -l active_gemset (string split -m1 " " (rbenv gemset active))
      echo -n -s $active_gemset[1]
    else
      echo ''
    end
  else
    echo ''
  end
end

function _python_version -d "Get python version if pyenv is installed"
  set -l python_version
  if which pyenv >/dev/null 2>&1
    set python_version (pyenv version-name)
  end
  test $python_version; and echo -n -s (_col brblue)$ICON_PYTHON(_col green)$python_version(_col_res)
end

function _icons_initialize
  #echo \Uf00a \ue709 \ue791 \ue739 \uF0DD \UF020 \UF01F \UF07B \UF015 \UF00C \UF00B \UF06B \UF06C \UF06E \UF091 \UF02C \UF026 \UF06D \UF0CF \UF03A \UF03D \UF081 \UF02A \UE606 \UE73C      #\UF005 bugs in fish
  set -g ORANGE                     FF8C00        #FF8C00 dark orange, FFA500 orange, another one fa0 o
  set -g ICON_NODE                  \UE718" "     #  from Devicons or ⬢
  set -g ICON_RUBY                  \UE791" "     # \UE791 from Devicons; \UF047; \UE739; 💎
  set -g ICON_PYTHON                \UE606" "     # \UE606; \UE73C
  #set -g ICON_PERL                  \UE606" "     # \UE606; \UE73C
  set -g ICON_TEST                  \UF091        # 
  set -g ICON_VCS_UNTRACKED         \UF02C" "     #    #●: there are untracked (new) files
  set -g ICON_VCS_UNMERGED          \UF026" "     #    #═: there are unmerged commits
  set -g ICON_VCS_MODIFIED          \UF06D" "     # 
  set -g ICON_VCS_STAGED            \UF06B" "     #  (added) →
  set -g ICON_VCS_DELETED           \UF06C" "     # 
  set -g ICON_VCS_DIFF              \UF06B" "     # 
  set -g ICON_VCS_RENAME            \UF06E" "     # 
  set -g ICON_VCS_STASH             \UF0CF" "     #      #✭: there are stashed commits
  set -g ICON_VCS_INCOMING_CHANGES  \UF00B" "     #  or \UE1EB or \UE131
  set -g ICON_VCS_OUTGOING_CHANGES  \UF00C" "     #  or \UE1EC or 
  set -g ICON_VCS_TAG               \UF015" "     # 
  set -g ICON_VCS_BOOKMARK          \UF07B" "     # 
  set -g ICON_VCS_COMMIT            \UF01F" "     # 
  set -g ICON_VCS_BRANCH            \UE0A0        # \UE0A0 or \UF020
  set -g ICON_VCS_REMOTE_BRANCH     \UE804" "     #  not displayed, should be branch icon on a book
  set -g ICON_VCS_DETACHED_BRANCH   \U27A6" "     # ➦
  set -g ICON_VCS_GIT               \UF00A" "     #  from Octicons
  set -g ICON_VCS_HG                \F0DD" "      # Got cut off from Octicons on patching
  set -g ICON_VCS_CLEAN             \UF03A        # 
  set -g ICON_VCS_PUSH              printf "\UF005 " # bugs out in fish: \UF005 (printf "\UF005")
  set -g ICON_VCS_DIRTY             ±             #
  set -g ICON_ARROW_UP              \UF03D""      #  ↑
  set -g ICON_ARROW_DOWN            \UF03F""      #  ↓
  set -g ICON_OK                    \UF03A        # 
  set -g ICON_FAIL                  \UF081        # 
  set -g ICON_STAR                  \UF02A        # 
  set -g ICON_JOBS                  \U2699" "     # ⚙
  set -g ICON_VIM                   \UE7C5" "     # 
end

set -g CMD_DURATION 0

#Additional info
  #set -l time (date '+%I:%M'); #set -l time_info (_col blue)($time)(_col_res); #echo -n -s $time_info
  #function print_blank_line() {
  #    if git rev-parse --git-dir > /dev/null 2>&1
  #     echo -e "n"
  #    else
  #     echo -n "b"
  #    end
  #end
  # use this to enable users to see their ruby version, no matter which version management system they use
  #function ruby_prompt_info
  #  echo $(rvm_prompt_info || rbenv_prompt_info || chruby_prompt_info)
  #end

  #bash
  # echo "$(rbenv gemset active 2&>/dev/null | sed -e ":a" -e '$ s/\n/+/gp;N;b a' | head -n1)"
  # fenv echo "\$(rbenv gemset active 2\&>/dev/null | sed -e ":a" -e '\$ s/\n/+/gp;N;b a' | head -n1)"
  # bass echo "\$(rbenv gemset active 2\&>/dev/null | sed -e ":a" -e '\$ s/\n/+/gp;N;b a' | head -n1)"
  #Run command in background: command &
  #0 is stdin. 1 is stdout. 2 is stderr.
  #Redirect STDERR to STDOUT: command 2>&1
  #One method of combining multiple commands is to use a -e before each command
  #sed -e 's/a/A/' -e 's/b/B/' <old >new
  #:label
  #' to turn quoting on/off, so '$ is
  #g get; p print; N next
  #head -n1         #print 1 line of a file to stdout
  #end

  #current_gemset alternativ
  #  else if test (rbenv gemset active >/dev/null 2>&1) = "no active gemsets" # not sure what 2>&1
  #  else
  #    set -l active_gemset (string split -m1 " " (rbenv gemset active))
  #    echo $active_gemset[1]
  #
  #  set -l active_gemset (rbenv gemset active 2> /dev/null)
  #  if test -z "$active_gemset"
  #  else if test $active_gemset = "no active gemsets"
  #    else
  #      set -l active_gemset (string split -m1 " " $active_gemset)
  #      echo $active_gemset[1]
  #  end
  # echo (rbenv gemset active 2&>/dev/null | sed -e ":a" -e '$ s/\n/+/gp;N;b a' | head -n1)
  # if [ ]

  #The short summary is that if $VAR is not set, then test -n $VAR is equivalent to test -n, and POSIX requires that we just  check if that one argument (the -n) is not null.
  #1. if test -n "$SSH_CLIENT" # You can fix it by quoting, which forces an argument even if it's empty:
  #2. test -n (EXPRESSION; or echo "")
  #3. use count



#function __bobthefish_prompt_user -d 'Display actual user if different from $default_user'
#  if [ "$theme_display_user" = 'yes' ]
#    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
#      __bobthefish_start_segment $__bobthefish_lt_grey $__bobthefish_slate_blue
#      echo -n -s (whoami) '@' (hostname | cut -d . -f 1) ' '
#    end
#  end
#end

#echo "Python 3.5.0" | cut -d ' ' -f 2 2>/dev/null        #-d use DELIM instead of tabs, -f print line without delims
