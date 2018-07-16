# dotfiles

My dotfiles.

Uses a schema of anything ending in '.link' will have a symlink created in $HOME
ie, `./vim/vim.link` will get a symlink pointing to it at `~/.vim`


## installation

1. `run-parts --regex 'setup_*' --exit-on-error ./install`
1. This should stop and prompt a manual change of shell to zsh which requires logging out and in.
1. run the zsh script again to finish `./bin/setup_10_zsh.sh`


## Fork and Modify

Tweak away!
