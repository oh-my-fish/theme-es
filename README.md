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
* A font patched with extra glyphs from [Font Awesome][font-awesome], [Devicons][font-devicons] and [Octicons ][font-octicons] (see the [__Nerd Fonts__](https://github.com/ryanoasis/nerd-fonts) project for more details)

## Features

* Git-aware theme with detailed __Git status__ in the left prompt (added, removed, modified, renamed, unstaged, stashed)
* __Node/Python/Ruby@gemset__ current version inside a git folder in the right prompt if respective virtual environment manager is installed (nvm, pyenv, rbenv)
* __Error status__ and __duration of last command__ in the right prompt
* Mac-notifications on completion of long commands (10+&nbsp;seconds by default) if terminal (iTerm and Terminal) is out of focus
* Limits path to __two last folders__ for better visibility, with `$HOME` directory abbreviated to `~`

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
