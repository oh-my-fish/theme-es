function fish_title -d 'Use PROCESS $PWD format, replacing /Users/username with ~'
  set realhome ~
  if test "$_" != "fish"
    echo $_ ''
  else
    echo ''
  end
  string replace -r '^'"$realhome"'($|/)' '~$1' $PWD
end
