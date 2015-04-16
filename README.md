AxiaCore Utils
==============

Tools and scripts to write beautiful code!

## Usage

The installation of these utilities may vary depending on their
nature, but most likely you can  use them by just copying the
file you want to your `~` root folder or ~/bin folder.

```bash
# Clone the repo
$ git clone https://github.com/AxiaCore/axiacore_utils.git

# Move lets say `.aliases` to your root directory
$ cd axiacore_utils && mv .aliases ~

# Reload the shell
$ source ~/.bashrc

# Use the shortcuts.
# Open dropbox folder
$ d
```

Installing git commands
=======================

```bash
#copy git_commands and make sure you have ~/bin/ in your PATH
cp git_commands/* && ~/bin
#if you do not have ~/bin in your path, on your ~/.bashrc do
#something like
#export PATH=$PATH:~/bin/
```

Now you should have

 * git patch
 * git minor
 * git major

That will update your version files and commit directly to your git repo with the proper version tag


# Contributing 

This are community files used to make our work more enjoyable. If you want to see something, please send us a pull request.
