# jlebon/files

Random files I like to SCM for easy tweaking and
distributing.

#### Comparing repo files to their installed versions

```
$ utils/diff dotfiles/.bashrc    # single file
$ utils/diff-all                 # all files
$ utils/rdiff                    # single file inverted diff
$ utils/rdiff-all                # all files inverted diff
```

#### From repo to disk

```
$ utils/install dotfiles/.bashrc    # single file
$ utils/install-all                 # all files
```

Files on disk are first stashed before being overwritten.

#### All-in-one (install & reload)

```
$ source utils/setup
```

#### From disk to repo

```
$ utils/import dotfiles/.bashrc    # single file
$ utils/import-all                 # all files
```
