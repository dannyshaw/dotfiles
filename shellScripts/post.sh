echo "Running Post Installation Script"

# install Fuzzy File Search
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  $HOME/.fzf/install
fi

#symlink sublime text packages
rm -rf $HOME/.config/sublime-text-3/Packages/User
ln -s $HOME/.dotfiles/sublime/User $HOME/.config/sublime-text-3/Packages/User


echo "Post Installation Script Complete"
