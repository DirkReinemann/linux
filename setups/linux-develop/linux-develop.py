#!/bin/python

import git
import logging
import optparse
import os
import platform
import subprocess
import sys

PLUGINS = [
    ("ctrlp.vim", "https://github.com/kien/ctrlp.vim.git"),
    ("delimitmate", "https://github.com/raimondi/delimitmate.git"),
    ("indentline", "https://github.com/yggdroot/indentline.git"),
    ("lightline.vim", "https://github.com/itchyny/lightline.vim.git"),
    ("nerdtree", "https://github.com/scrooloose/nerdtree.git"),
    ("syntastic", "https://github.com/scrooloose/syntastic.git"),
    ("tabular", "https://github.com/godlygeek/tabular.git"),
    ("vim-commentary", "https://github.com/tpope/vim-commentary.git"),
    ("vim-dirdiff", "https://github.com/will133/vim-dirdiff.git"),
    ("vim-fugitive", "httpws://github.com/tpope/vim-fugitive.git"),
    ("vim-gitgutter", "https://github.com/airblade/vim-gitgutter.git"),
    ("vim-indexed-search", "https://github.com/henrik/vim-indexed-search.git"),
    ("vim-misc", "https://github.com/xolox/vim-misc.git"),
    ("vim-polyglot", "https://github.com/sheerun/vim-polyglot.git"),
    ("vim-surround", "https://github.com/tpope/vim-surround.git"),
    ("Vundle.vim", "https://github.com/VundleVim/Vundle.vim.git")
]

DOTFILES = [
    '.bashrc',
    '.vimrc',
    '.tmux.conf'
]

FORMATTER = logging.Formatter('%(message)s')

STREAM_HANDLER = logging.StreamHandler()
STREAM_HANDLER.setLevel(logging.DEBUG)
STREAM_HANDLER.setFormatter(FORMATTER)

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
LOGGER.addHandler(STREAM_HANDLER)

def read_username():
    username = ""

    try:
        username = os.environ["USER"]
    except Exception as e:
        LOGGER.exception("Error while determining the name of the current user!")
        sys.exit(1)

    return username

def read_uid(username):
    uid = ""

    try:
        process = subprocess.Popen(['id', '-u', username], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        uid, stderr = process.communicate()
        uid = int(uid.decode('utf-8'))
    except Exception as e:
        LOGGER.exception("Error while determining the uid for user '%s'!" % username)
        sys.exit(1)

    return uid

def read_gid(username):
    gid = ""

    try:
        process = subprocess.Popen(['id', '-g', username], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        gid, stderr = process.communicate()
        gid = int(gid.decode('utf-8'))
    except Exception as e:
        LOGGER.exception("Error while determining the gid for user '%s'!" % username)
        sys.exit(1)

    return gid

def read_homedir(username):
    homedir = ""

    try:
        process = subprocess.Popen(['getent', 'passwd', username], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        stdout, stderr = process.communicate()
        homedir = stdout.decode('utf-8').split(':')[5]
    except Exception as e:
        LOGGER.exception("Error while determining the home directory for user '%s'!" % username)
        sys.exit(1)

    if not os.path.exists(homedir):
        LOGGER.info("The determined home directory '%s' doesn't exist!" % homedir)

    return homedir

def create_dir(path, uid, gid):
    if not os.path.exists(path):
        os.mkdir(path)

    os.chmod(path, 0o755)
    os.chown(path, uid, gid)

def create_repo(plugindir, reponame, repourl, uid, gid):
    repodir = "%s/%s" % (plugindir, reponame)
    create_dir(repodir, uid, gid)

    repo = None
    try:
        repo = git.Repo(repodir)
    except git.exc.InvalidGitRepositoryError:
        LOGGER.info("Cloning repository '%s' to '%s'." % (reponame, repodir))
        repo = git.Repo.clone_from(repourl, repodir)

    LOGGER.info("Updating repository %s'." % (repodir))
    repo.remotes.origin.pull()

def install_vim(username):
    if not username:
        username = read_username()

    homedir = read_homedir(username)
    vimdir = "%s/.vim" % homedir
    plugindir = "%s/bundle" % vimdir
    uid = read_uid(username)
    gid = read_gid(username)
    create_dir(vimdir, uid, gid)
    create_dir(plugindir, uid, gid)

    for reponame, repourl in PLUGINS:
        try:
            create_repo(plugindir, reponame, repourl, uid, gid)
        except Exception as e:
            LOGGER.exception("Error while creating the repository '%s'!" % reponame)

def copy_file(srcpath, dstpath, uid, gid):
    srcfile = None
    dstfile = None

    try:
        srcfile = open(srcpath, 'r')
        dstfile = open(dstpath, 'w')
        for line in srcfile.readlines():
            dstfile.write(line)
    except Exception as e:
        LOGGER.exception("Error while copying the file '%s' to %s!" % (srcpath, dstpath))
    finally:
        if srcfile:
            srcfile.close()
        if dstfile:
            dstfile.close()

    os.chmod(dstpath, 0o644)
    os.chown(dstpath, uid, gid)

def copy_dotfiles(username):
    if not username:
        username = read_username()

    homedir = read_homedir(username)
    uid = read_uid(username)
    gid = read_gid(username)

    for dotfile in DOTFILES:
        workdir = os.getcwd()
        srcpath = "%s/%s" % (workdir, dotfile)
        dstpath = "%s/%s" % (homedir, dotfile)
        LOGGER.info("Copying file '%s' to '%s'." % (dotfile, dstpath))
        copy_file(srcpath, dstpath, uid, gid)

def uninstall_vim(username):
    if not username:
        username = read_username()

    homedir = read_homedir(username)
    vimdir = "%s/.vim" % homedir

    for root, dirs, files in os.walk(vimdir, topdown=False):
        for name in files:
            os.remove(os.path.join(root, name))
        for name in dirs:
            os.rmdir(os.path.join(root, name))

    os.rmdir(vimdir)

def main():
    parser = optparse.OptionParser()

    parser.add_option("-i", "--install",  help="installs all files", action="store_true", default=False)
    parser.add_option("-r", "--uninstall",  help="uninstalls all files", action="store_true", default=False)
    parser.add_option("-u", "--user", help="username to use for the installation", type="string")

    (options, arguments) = parser.parse_args()

    if options.install:
        install_packages()
        # copy_dotfiles(options.user)
        # install_vim(options.user)

    if options.uninstall:
        uninstall_vim(options.user)

if __name__ == "__main__":
    main()
