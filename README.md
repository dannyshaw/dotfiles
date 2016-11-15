# dotfiles

My dotfiles.

Makes use of [kody](https://github.com/jh3y/kody) as an installation tool to handle symlinking and some basic node powered scripting.  Kody was mainly used on OSX so I've added some linux specific install options.

create `bootstrap.sh`:

    #!/bin/bash
    #install NVM
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    nvm install 6.0.0

    sudo apt-get install git

    git clone https://github.com/dannyshaw/dotfiles.git $HOME/.dotfiles

    cd $HOME/.dotfiles



## Installation and Usage

Download to ~/.dotfiles:
`git clone https://github.com/dannyshaw/dotfiles.git ~/.dotfiles`

running `bin/setup` will install Node Version Manager and Node 6.2.1.

Now just run `kody` in the root and you will be presented with options.

## Fork and Modify

Tweak away! See docs at [kody](https://github.com/jh3y/kody)
