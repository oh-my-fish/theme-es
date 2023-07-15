# Changelog
All notable changes to this project will be documented in this file

[unreleased]: https://github.com/oh-my-fish/theme-es/compare/0.5.0...HEAD
## [Unreleased]
  <!-- - __Added__ -->
  <!--   + :sparkles:  -->
  <!--   new features -->
  <!-- - __Changed__ -->
  <!--   +   -->
  <!--   changes in existing functionality -->
  <!-- - __Fixed__ -->
  <!--   + :beetle:  -->
  <!--   bug fixes -->
  <!-- - __Deprecated__ -->
  <!--   + :poop:  -->
  <!--   soon-to-be removed features -->
  <!-- - __Removed__ -->
  <!--   + :wastebasket:  -->
  <!--   now removed features -->
  <!-- - __Security__ -->
  <!--   + :lock:  -->
  <!--   vulnerabilities -->

[0.5.0]: https://github.com/oh-my-fish/theme-es/releases/tag/0.5.0
## [0.5.0]
  - __Added__
    + :sparkles: all theme variables (including icons) customization
    + option to disable Node/Python/Ruby version checks via config
    + option `theme_show_git_count` to add the count of the number of files after each git status (e.g. staged5 deleted2)
  - __Changed__
    + duration var units to seconds
    + add an explicit theme name to user vars to avoid potential conflict
    + replace `grep` dependency with the builtin `string`
    + refactor functions to display git prompt sha
  - __Fixed__
    + errors on missing local Node/Python/Ruby versions
