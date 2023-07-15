<img src="https://cdn.rawgit.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg" align="left" width="144px" height="144px"/>

#### es theme
> A Powerline-style, Git-aware theme for [Oh My Fish][omf-link].

[![MIT License][license-badge]](/LICENSE)
[![Fish Shell Version][fish-version-badge]](https://fishshell.com)
[![Oh My Fish Framework][omf-badge]](https://www.github.com/oh-my-fish/oh-my-fish)

<br/>

## Install
Make sure you have [Oh My Fish][omf-link] installed. Then just
```fish
$ omf install es
```

## Requirements
* A font patched with extra glyphs from [Powerline](https://github.com/powerline/fonts) (`E0A0-E0B3`), [Devicons][font-devicons] (`E600-E6C5`), and [Octicons ][font-octicons] (`F000-F0E8`) (see the [__Nerd Fonts__](https://github.com/ryanoasis/nerd-fonts) project for more details)

## Features

* Git-aware theme with detailed __Git status__
  - at the left prompt: `added`, `removed`, `modified`, `renamed`, `unstaged`, `stashed`
  - at the right prompt: `sha`
* __Node/Python/Ruby@gemset__ current version (local/global in a git folder, only local elsewhere) at the right prompt if respective virtual environment manager is installed (nodenv/NVM, pyenv, rbenv/RVM)
* __Error status__ and __duration of last command__ at the right prompt
* Mac-notifications on completion of long commands (10+&nbsp;seconds by default) if terminal (iTerm and Terminal) is out of focus
* Limits path to __last two folders__ for better visibility, with `$HOME` directory abbreviated to `~`

## Configuration
* Set the following variables in your `~/.config/fish/config.fish` to define how this theme looks:
```fish
#      Variable                  	Default	  Option 	Prompt	Description
set -g theme_es_show_symbols     	'yes'  	# no     	  ←   	Show pre-path symbols, e.g. read-only
set -g theme_es_verbose_git_ahead	'yes'  	# no     	      	
set -g theme_es_show_git_count   	'no'   	# yes    	  ←   	Show git count
set -g theme_es_git_sha          	'short'	# long no	  →   	Show git sha (short/long)
set -g theme_es_show_user        	'no'   	# yes    	  →   	Show username
set -g theme_es_show_hostname    	'yes'  	# no     	  →   	Show hostname on SSH connections
set -g theme_es_show_node_v      	'yes'  	# no     	  →   	Show Node.js version
set -g theme_es_show_python_v    	'yes'  	# no     	  →   	Show Python version
set -g theme_es_show_ruby_v      	'yes'  	# no     	  →   	Show Ruby prompt @ gemset
set -g theme_es_notify_duration  	10     	#        	      	Notify if command runs longer than this time (seconds)
```

## Screenshots

### __Git folder__
<p align="center">
<img src="https://github.com/oh-my-fish/theme-es/blob/master/Fish%20Prompt%20Git-es.png?raw=true">
</p>

### __Normal folder (no Git)__
<p align="center">
<img src="https://github.com/oh-my-fish/theme-es/blob/master/Fish%20Prompt%20NoGit-es.png?raw=true">
</p>

### __Normal read-only folder (no Git)__
<p align="left">
<img src="https://github.com/oh-my-fish/theme-es/blob/master/Fish%20Prompt%20NoGit%20Read-only-es.png?raw=true" width="280">
</p>

## License

[MIT][mit] © [eugenesvk][author] et [al][contributors]

[mit]:               	https://opensource.org/licenses/MIT
[author]:            	https://github.com/eugenesvk
[contributors]:      	https://github.com/oh-my-fish/theme-es/graphs/contributors
[omf-link]:          	https://www.github.com/oh-my-fish/oh-my-fish
[license-badge]:     	https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square
[fish-version-badge]:	https://img.shields.io/badge/fish-v3.0.0-007EC7.svg?style=flat-square
[omf-badge]:         	https://img.shields.io/badge/Oh%20My%20Fish-Framework-007EC7.svg?style=flat-square

[font-awesome]:                          	https://github.com/FortAwesome/Font-Awesome
[font-devicons]:                         	https://vorillaz.github.io/devicons/
[font-octicons]:                         	https://github.com/primer/octicons
[font-material-design-icons]:            	https://github.com/Templarian/MaterialDesign
[font-weather]:                          	https://github.com/erikflowers/weather-icons
[font-ryanoasis-powerline-extra-symbols]:	https://github.com/ryanoasis/powerline-extra-symbols
