# dotfiles
Configuration files and utilities for Mac, Linux &amp; Windows

## Topic-based approach
Everything's built around topic areas. If you're adding a new area to your forked dotfiles — say, "Java" — you can simply add a java directory and put files in there. Anything with an extension of .shell will get automatically included into your shell. Anything with an extension of .symlink will get symlinked without extension into $HOME when you run ./bootstrap.

## Platform-specific configuration
If you need to do some OS-specific configuration, just add a script to the corresponding directory. `darwin` for macOS, `linux` for Linux, `windows` for Windows and `cygwin` for Cygwin.

## Components
There are a few special files in the hierarchy:

- **bin/**: Anything in bin/ will get added to your $PATH and be made available everywhere.
- **topic/\*.bootstrap**: Any files ending in .bootstrap are called when you run ./bootstrap and are expected to install dependencies for that topic.
- **topic/\*.symlink**: Any files ending in .symlink get symlinked into your $HOME. This is so you can keep all of those versioned in your dotfiles but still keep those autoloaded files in your home directory. These get symlinked in when you run ./bootstrap.
- **topic/path.shell**: Any file named path.sh is loaded first and is expected to setup $PATH or similar.
- **topic/\*.shell**: Any files ending in .shell get loaded into your bash and zsh environment.
- **topic/\*.bash**: Any files ending in .bash get loaded into your bash environment.
- **topic/\*.zsh**: Any files ending in .zsh get loaded into your zsh environment.
- **topic/completion.sh**: Any file named completion.sh is loaded last and is expected to setup autocomplete.


## Installation

```bash
git clone https://github.com/thomsan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap
```

## Credits

* [burnedikt's dotfiles](https://github.com/burnedikt/dotfiles) served as base for the multi-platform setup
* [holman's dotfiles](https://github.com/holman/dotfiles) for the topic-based approach
