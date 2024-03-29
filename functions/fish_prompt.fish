function fish_prompt
  set -g last_status $status                                         # exit status of last command
  #set -l count (_file_count)
  _set_theme_icons                                                   # assign icons from patched fonts to vars
  _set_theme_vars                                                    # set theme vars if not set by user
  set -l p_path2 (_col brblue o u)(prompt_pwd2)(_col_res)            # path shortened to last two folders ($count)
  set -l symbols ''                                                  # add some pre-path symbols
  if [ $theme_es_show_symbols = 'yes' ]
    if [ ! -w . ];    set symbols $symbols(_col ff6600)$theme_es_icon_LOCK; end    #
    if set -q -x VIM; set symbols $symbols(_col 3300ff o)$theme_es_icon_VIM; end   #
  end
  if [ (_is_git_dirty) ]; set dirty ''; else; set dirty ' '; end     # add space only in clean git branches
  if test "$last_status" = 0                                         # prompt symbol: green normal, red on error
    set prompt (_col green b)"$dirty"(_UserSymbol)(_col_res)' '
  else
    set prompt (_col brred b)"$dirty"(_UserSymbol)(_col_res)' '
  end

  echo -n -s $symbols$p_path2                     # -n no newline, -s no space separation of arguments
  _is_git_folder; and _prompt_git
  echo -n -s $prompt
end

function fish_right_prompt
  if test "$last_status" -gt 0                    # set error code in red
    set errorp (_col brred)"$last_status⏎"(_col_res)" "
  end
  set -l duration (_cmd_duration)                 # set duration of last command
  if [ (jobs -l | wc -l) -gt 0 ]                  # set ⚙ if any background jobs exit
    set jobsp $theme_es_icon_JOBS
  end
  echo -n -s "$errorp$duration$jobsp"             # show error code, command duration and jobs status
  if _is_git_folder                               # show  only if in a git folder
    set git_SHAp (_git_prompt_sha)                # git long/short sha depending on config
    echo -n -s "$git_SHAp"                        # -n no newline -s no space separation
  end
  test "$theme_es_show_node_v"   = 'yes'; and set NODEp   (_node_version)   # Node.js version
  test "$theme_es_show_python_v" = 'yes'; and set PYTHONp (_python_version) # Python version
  test "$theme_es_show_ruby_v"   = 'yes'; and set RUBYp   (_ruby_version)   # Ruby prompt @ gemset
  echo -n -s "$NODEp$PYTHONp$RUBYp"      # show global/local  versions in a git folder or local elsewhere
  echo -n -s (_prompt_user)              # display user@host if different from default or SSH
end

function _set_theme_vars -d 'Set default values to theme variables unless already set in user config'
  # Global variables that affect how left and right prompts look like
  test -z "$theme_es_show_symbols"     	; and set -g theme_es_show_symbols     	'yes'  	# [yes] no
  test -z "$theme_es_extra_space"      	; and set -g theme_es_extra_space      	''     	# [''] ' '
  test -z "$theme_es_spacer_count"     	; and set -g theme_es_spacer_count     	''     	# [''] ' '
  test -z "$theme_es_verbose_git_ahead"	; and set -g theme_es_verbose_git_ahead	'yes'  	# [yes] no
  test -z "$theme_es_git_sha"          	; and set -g theme_es_git_sha          	'short'	# [short] long no
  test -z "$theme_es_show_user"        	; and set -g theme_es_show_user        	'no'   	# [no] yes
  test -z "$theme_es_show_hostname"    	; and set -g theme_es_show_hostname    	'yes'  	# [yes] no
  test -z "$theme_es_show_git_count"   	; and set -g theme_es_show_git_count   	'no'   	# [no] yes
  test -z "$theme_es_show_node_v"      	; and set -g theme_es_show_node_v      	'yes'  	# [yes] no
  test -z "$theme_es_show_python_v"    	; and set -g theme_es_show_python_v    	'yes'  	# [yes] no
  test -z "$theme_es_show_ruby_v"      	; and set -g theme_es_show_ruby_v      	'yes'  	# [yes] no

  # Other global variables
  if test -z "$theme_es_ismacOS"
    set -g theme_es_ismacOS 'no'
    set -l osname (uname)
    if test "$osname" = 'Darwin'
      set -g theme_es_ismacOS 'yes'
    end
  end
  test -z "$theme_es_notify_duration"	; and set -g theme_es_notify_duration	10000

  set -g ORANGE	FF8C00	# FF8C00 dark orange, FFA500 orange, another one fa0 o
end

function _cmd_duration -d 'Displays the elapsed time of last command and show notification for long lasting commands'
  set -l days ''; set -l hours ''; set -l minutes ''; set -l seconds ''
  set -l duration (expr $CMD_DURATION / 1000)
  set -l duration_sec $duration
  if       [ $duration -gt     0 ]
    set       seconds (expr $duration \% 68400 \% 3600 \% 60)'s'
    if     [ $duration -ge    60 ]
      set     minutes (expr $duration \% 68400 \% 3600 / 60)'m'
      if   [ $duration -ge  3600 ]
        set   hours   (expr $duration \% 68400 / 3600)'h'
        if [ $duration -ge 68400 ]
          set days    (expr $duration / 68400)'d'
        end
      end
    end
    set -l duration $days$hours$minutes$seconds
    if [ $last_status -ne 0 ]
      echo -n (_col brred)$duration(_col_res)
    else
      echo -n (_col brgreen)$duration(_col_res)
    end
    # Show a system notificaton when...
    set exclude_cmd "bash|less|man|more|ssh"
    if     test "$theme_es_ismacOS" = 'yes'                        	# 1. on a macOS
       and test "$duration_sec" -gt "$theme_es_notify_duration"    	# 2. a command duration exceeds a threshold
       and echo $history[1] | string match -rvq "^($exclude_cmd).*"	# 3. a command isn't excluded
      # 4. iTerm and Terminal are not focused
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

function _col -d "Set Color, 'name b u' bold, underline"
  set -l col; set -l bold; set -l under
  if [ -n "$argv[1]" ];       set col   $argv[1]; end
  if [ (count $argv) -gt 1 ]; set bold  "-"(string replace b o $argv[2] 2>/dev/null); end
  if [ (count $argv) -gt 2 ]; set under "-"$argv[3]; end
  set_color $bold $under $argv[1]
end
function _col_res -d "Reset background and foreground colors"
  set_color -b normal
  set_color normal
end

function prompt_pwd2
  set realhome ~
  set -l _tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $PWD)  # replace $HOME with '~' in path
  set -l _tmp2 (basename (dirname $_tmp))/(basename $_tmp)          # get last two dirs from path
  echo (string trim -l -c=/ (string replace "./~" "~" $_tmp2))      # trim left '/' or './' for special cases
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
  if [ "$theme_es_show_user" = "yes" ]
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
  if [ "$theme_es_show_hostname" = "yes" -a -n "$SSH_CLIENT" ]
    set -g HOSTNAME_PROMPT (hostname)
  end
end

function _UserSymbol                                        # prompt symbol: '#' superuser or '>' user
  if test (id -u $USER) -eq 0
    echo "#"
  else
    echo ">"
  end
end

function _prompt_git -a current_dir -d 'Display the actual git state'
  # add space if dirty to separate from icons "$dirty"; $flag_fg set in the _git_status function
  echo -n -s $flag_fg(_git_branch)(_git_status)(_col_res)
end
function _git_status -d 'Check git status'
  set -l git_status (command git status --porcelain 2>/dev/null | cut -c 1-2)
  set -l ahead (_git_ahead); echo -n $ahead                                    # show # of commits ahead/behind
  set -l staged; set -l stashed
  set -l count_staged   	(count (string match -ra "[ACDMT][ MT]|[ACMT]D" $git_status))	# added/staged
  set -l count_deleted  	(count (string match -ra "[ ACMRT]D"            $git_status))	# deleted
  set -l count_modified 	(count (string match -ra ".[MT]"                $git_status))	# modified
  set -l count_renamed  	(count (string match -ra "R."                   $git_status))	# renamed
  set -l count_unmerged 	(count (string match -ra "AA|DD|U.|.U"          $git_status))	# unmerged
  set -l count_untracked	(count (string match -ra "\?\?"                 $git_status))	# untracked (new)

  if test $count_staged       -gt 0
    echo -ns (_col green)  $theme_es_icon_VCS_STAGED; set staged 'y'
    if test \( "$theme_es_show_git_count" = 'yes' \) -a \( $count_staged    -gt 1 \)
      echo -ns "$theme_es_spacer_count""$count_staged"
    else; echo -ns ' '; end
  end
  if test $count_deleted     -gt 0
    echo -ns (_col red)    $theme_es_icon_VCS_DELETED
    if test \( "$theme_es_show_git_count" = 'yes' \) -a \( $count_deleted  -gt 1 \)
      echo -ns "$theme_es_spacer_count""$count_deleted"
    else; echo -ns ' '; end
  end
  if test $count_modified    -gt 0
    echo -ns (_col $ORANGE)$theme_es_icon_VCS_MODIFIED
    if test \( "$theme_es_show_git_count" = 'yes' \) -a \( $count_modified -gt 1 \)
      echo -ns "$theme_es_spacer_count""$count_modified"
    else; echo -ns ' '; end
  end
  if test $count_renamed     -gt 0
    echo -ns (_col purple) $theme_es_icon_VCS_RENAMED
    if test \( "$theme_es_show_git_count" = 'yes' \) -a \( $count_renamed  -gt 1 \)
      echo -ns "$theme_es_spacer_count""$count_renamed"
    else; echo -ns ' '; end
  end
  if test $count_unmerged    -gt 0
    echo -ns (_col brred)  $theme_es_icon_VCS_UNMERGED
    if test \( "$theme_es_show_git_count" = 'yes' \) -a \( $count_unmerged -gt 1 \)
      echo -ns "$theme_es_spacer_count""$count_unmerged"
    else; echo -ns ' '; end
  end
  if test $count_untracked   -gt 0
    echo -ns (_col brcyan) $theme_es_icon_VCS_UNTRACKED
    if test \( "$theme_es_show_git_count" = 'yes' \) -a \( $count_untracked -gt 1 \)
      echo -ns "$theme_es_spacer_count""$count_untracked"
    else; echo -ns ' '; end
  end
  if test (command git rev-parse --verify --quiet refs/stash)                # stashed (was '$')
    echo -ns (_col brred)$theme_es_icon_VCS_STASH
    set stashed 'y'
  end

  set -l dirty   (_is_git_dirty)
  set -g flag_fg (_col brgreen)
  if [ "$dirty" -o "$staged" ]
    set flag_fg (_col yellow)
  else if [ "$stashed" ]
    set flag_fg (_col brred)
  end
  echo ''
end
function _is_git_dirty -d 'Check if branch is dirty'
  echo (command git status --porcelain --ignore-submodules=dirty 2>/dev/null)
end
function _git_branch -d "Display the current git state"
  set -l ref
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set ref (command git symbolic-ref HEAD 2>/dev/null)
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev |head -n1 2>/dev/null)
      set ref "$theme_es_icon_VCS_DETACHED_BRANCH$branch"
    end
    set -l branch (echo $ref | sed  "s-refs/heads/--")
    echo " $theme_es_icon_VCS_BRANCH"(_col magenta)"$branch"(_col_res)
  end
end
function _is_git_folder     -d "Check if current folder is a git folder"
  git status 1>/dev/null 2>/dev/null
end
function _git_ahead -d         'Print the ahead/behind state for the current branch'
  if [ "$theme_es_verbose_git_ahead" = 'yes' ]
    _git_ahead_verbose
    return
  end
  command git rev-list --left-right '@{upstream}...HEAD' 2>/dev/null | awk '/>/ {a += 1} /</ {b += 1} {if (a > 0 && b > 0) nextfile} END {if (a > 0 && b > 0) print "⇕"; else if (a > 0) print ""; else if (b > 0) print ""}' #↑↓⇕⬍↕
end
function _git_ahead_verbose -d 'Print a more verbose ahead/behind state for the current branch'
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' 2>/dev/null)
  if [ $status != 0 ]
    return
  end
  set -l behind (count (for arg in $commits; echo $arg; end | string match -r  '^<'))
  set -l ahead  (count (for arg in $commits; echo $arg; end | string match -rv '^<'))
  switch "$ahead $behind"
    case ''     # no upstream
    case '0 0'  # equal to upstream
      return
    case '* 0'  # ahead of upstream
      echo (_col blue)"$theme_es_icon_ARROW_UP$ahead"
    case '0 *'  # behind upstream
      echo (_col red)"$theme_es_icon_ARROW_DOWN$behind"
    case '*'    # diverged from upstream
      echo (_col blue)"$theme_es_icon_ARROW_UP$ahead"(_col red)"$theme_es_icon_ARROW_DOWN$behind"
  end
end

function _git_prompt_sha
  set -l GIT_SHA ''
  if      [ "$theme_es_git_sha" = 'short' ]
    set GIT_SHA (command git rev-parse --short HEAD 2>/dev/null)
  else if [ "$theme_es_git_sha" = 'long' ]
    set GIT_SHA (command git rev-parse         HEAD 2>/dev/null)
  end
  if test -n "$GIT_SHA"
    echo -n -s (_col brcyan)\[(_col brgrey)$GIT_SHA(_col brcyan)\](_col_res)
  end
end

function _node_version -d "Print Node version via NVM/nodenv: local/global in a git folder, only local elsewhere"
  set -l node_version
  if type -q nvm
    if type -q node     # omf nvm wrapper caused previous check to pass even when no NVM was installed
      set node_version (string trim -l -c=v (node -v 2>/dev/null)) # trim left 'v' in 'v16.0.0', faster than 'nvm current'
    end
  end
  if type -q nodenv     # overwrites NVM version if nodenv is installed
    set node_version (nodenv version-name)
  end
  if test -n "$node_version"
    if begin _is_git_folder; or _is_node_local; end
      echo -n -s (_col brgreen)$theme_es_icon_NODE(_col green)$node_version(_col_res)
    end
  end
end
function _is_node_local -d "Check if local Node version is set via .node-version (current/parent folders)"
  if type -q nodenv
    nodenv version | string match -r '.node-version' >/dev/null
  end
end

function _ruby_version -d "Print Ruby version via RVM/rbenv: local/global in a git folder, only local elsewhere. Also displays Ruby@gemset version if a gemset is set locally"
  set -l ruby_ver
  if type -q rvm-prompt	; set ruby_ver (rvm-prompt i v g); end
  if type -q rbenv     	; set ruby_ver (rbenv version-name); end # overwrites RVM version if installed
  if test -n "$ruby_ver"
    if begin _is_git_folder; or _is_ruby_local; or _is_gemset_local; end
        echo -n -s (_col brred)$theme_es_icon_RUBY(_col green)$ruby_ver(_col_res)
        if test -n (_rbenv_gemset 2>/dev/null; or echo "")
          echo -n -s (_col grey)"@"(_col brgrey)(_rbenv_gemset)(_col_res)
        end
    end
  end
end
function _rbenv_gemset -d "Get the name of the currently active gemset"
  if type -q rbenv
    set -l _gemset_active_full (rbenv gemset active 2>/dev/null)
    if test -n "$_gemset_active"
      set -l _gemset_active_list (string split -m1 " " "$_gemset_active_full")
      echo -n -s $_gemset_active_list[1]
    else
      echo ''
    end
  else
    echo ''
  end
end
function _is_ruby_local -d "Check if local ruby version is set via .ruby-version (current/parent folders)"
  if type -q rbenv; rbenv version | string match -r '.ruby-version' >/dev/null; end
end
function _is_gemset_local -d "Check if local gemset version is set via .rbenv-gemsets (current/parent folders)"
  if type -q rbenv; rbenv gemset file | string match -r '.rbenv-gemsets' >/dev/null; end
end

function _python_version -d "Print Python version via pyenv: local/global in a git folder, only local elsewhere"
  set -l python_version
  if type -q pyenv
    if begin _is_git_folder; or _is_python_local; end
      set python_version (pyenv version-name)
    end
  end
  if test -n "$python_version"
    echo -n -s (_col brblue)$theme_es_icon_PYTHON(_col green)$python_version(_col_res)
  end
end
function _is_python_local -d "Check if local python version is set via .python-version (current/parent folders)"
  if type -q pyenv; pyenv version | string match -r '.python-version' >/dev/null; end
end

function _set_theme_icons
  set s "$theme_es_extra_space"
  #echo A quick test of glyph output: \Uf00a \ue709 \ue791 \ue739 \uF0DD \UF020 \UF01F \UF07B \UF015 \UF00C \UF00B \UF06B \UF06C \UF06E \UF091 \UF02C \UF026 \UF06D \UF0CF \UF03A \UF005 \UF03D \UF081 \UF02A \UE606 \UE73C
  test -z "$theme_es_icon_NODE"                	; and set -g theme_es_icon_NODE                	"$s"\UE718" "	#  from Devicons or ⬢
  test -z "$theme_es_icon_RUBY"                	; and set -g theme_es_icon_RUBY                	"$s"\UE791" "	# \UE791 from Devicons; \UF047; \UE739; 💎
  test -z "$theme_es_icon_PYTHON"              	; and set -g theme_es_icon_PYTHON              	"$s"\UE606" "	# \UE606; \UE73C
  test -z "$theme_es_icon_PERL"                	; and set -g theme_es_icon_PERL                	"$s"\UE606" "	# \UE606; \UE73C
  test -z "$theme_es_icon_TEST"                	; and set -g theme_es_icon_TEST                	"$s"\UF091   	# 
  test -z "$theme_es_icon_VCS_STAGED"          	; and set -g theme_es_icon_VCS_STAGED          	"$s"\UF06B   	#  (added) →
  test -z "$theme_es_icon_VCS_DELETED"         	; and set -g theme_es_icon_VCS_DELETED         	"$s"\UF06C   	# 
  test -z "$theme_es_icon_VCS_MODIFIED"        	; and set -g theme_es_icon_VCS_MODIFIED        	"$s"\UF06D   	# 
  test -z "$theme_es_icon_VCS_RENAMED"         	; and set -g theme_es_icon_VCS_RENAMED         	"$s"\UF06E   	# 
  test -z "$theme_es_icon_VCS_UNMERGED"        	; and set -g theme_es_icon_VCS_UNMERGED        	"$s"\UF026   	#    #═: there are unmerged commits
  test -z "$theme_es_icon_VCS_UNTRACKED"       	; and set -g theme_es_icon_VCS_UNTRACKED       	"$s"\UF02C   	#    #●: there are untracked (new) files
  test -z "$theme_es_icon_VCS_DIFF"            	; and set -g theme_es_icon_VCS_DIFF            	"$s"\UF06B" "	# 
  test -z "$theme_es_icon_VCS_STASH"           	; and set -g theme_es_icon_VCS_STASH           	"$s"\UF0CF" "	#      #✭: there are stashed commits
  test -z "$theme_es_icon_VCS_INCOMING_CHANGES"	; and set -g theme_es_icon_VCS_INCOMING_CHANGES	"$s"\UF00B" "	#  or \UE1EB or \UE131
  test -z "$theme_es_icon_VCS_OUTGOING_CHANGES"	; and set -g theme_es_icon_VCS_OUTGOING_CHANGES	"$s"\UF00C" "	#  or \UE1EC or 
  test -z "$theme_es_icon_VCS_TAG"             	; and set -g theme_es_icon_VCS_TAG             	"$s"\UF015" "	# 
  test -z "$theme_es_icon_VCS_BOOKMARK"        	; and set -g theme_es_icon_VCS_BOOKMARK        	"$s"\UF07B" "	# 
  test -z "$theme_es_icon_VCS_COMMIT"          	; and set -g theme_es_icon_VCS_COMMIT          	"$s"\UF01F" "	# 
  test -z "$theme_es_icon_VCS_BRANCH"          	; and set -g theme_es_icon_VCS_BRANCH          	"$s"\UE0A0   	# \UE0A0 or \UF020
  test -z "$theme_es_icon_VCS_BRANCH_REMOTE"   	; and set -g theme_es_icon_VCS_BRANCH_REMOTE   	"$s"\UE804" "	#  not displayed, should be branch icon on a book
  test -z "$theme_es_icon_VCS_BRANCH_DETACHED" 	; and set -g theme_es_icon_VCS_BRANCH_DETACHED 	"$s"\U27A6" "	# ➦
  test -z "$theme_es_icon_VCS_GIT"             	; and set -g theme_es_icon_VCS_GIT             	"$s"\UF00A" "	#  from Octicons
  test -z "$theme_es_icon_VCS_HG"              	; and set -g theme_es_icon_VCS_HG              	"$s"\UF0DD" "	# Got cut off from Octicons on patching
  test -z "$theme_es_icon_VCS_CLEAN"           	; and set -g theme_es_icon_VCS_CLEAN           	"$s"\UF03A   	# 
  test -z "$theme_es_icon_VCS_PUSH"            	; and set -g theme_es_icon_VCS_PUSH            	"$s"\UF005" "	# 
  test -z "$theme_es_icon_VCS_DIRTY"           	; and set -g theme_es_icon_VCS_DIRTY           	"$s""±"      	#
  test -z "$theme_es_icon_ARROW_UP"            	; and set -g theme_es_icon_ARROW_UP            	"$s"\UF03D   	#  ↑
  test -z "$theme_es_icon_ARROW_DOWN"          	; and set -g theme_es_icon_ARROW_DOWN          	"$s"\UF03F   	#  ↓
  test -z "$theme_es_icon_OK"                  	; and set -g theme_es_icon_OK                  	"$s"\UF03A   	# 
  test -z "$theme_es_icon_FAIL"                	; and set -g theme_es_icon_FAIL                	"$s"\UF081   	# 
  test -z "$theme_es_icon_STAR"                	; and set -g theme_es_icon_STAR                	"$s"\UF02A   	# 
  test -z "$theme_es_icon_JOBS"                	; and set -g theme_es_icon_JOBS                	"$s"\U2699" "	# ⚙
  test -z "$theme_es_icon_VIM"                 	; and set -g theme_es_icon_VIM                 	"$s"\UE7C5" "	# 
  test -z "$theme_es_icon_LOCK"                	; and set -g theme_es_icon_LOCK                	"$s"""      	#
end

set -g CMD_DURATION 0
