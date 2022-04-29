# darchive
Name comes from 'dated archive' or 'directory archive'.

By default the program takes every subdir of a given directory and creates an archive directory with the same name in the same folder as the given directory. It then moves every file in the subdirectory into the archive directory under a subdirectory by file modification date.

The reasoning behind this, is moving files out of sync-folders.

**My usecase:**
I've got a NAS server working as a backup server as well. I'm using [syncthing](https://syncthing.net/) to share pictures from my phone to my NAS on which I use this script to move files out of the sync-folder for easier backup.

## Example
Running `$ darchive parentdir/testdir` on the directory structure on the left-side produces the directory structure on the right-side.
All `testfile1` and `testfile3` are from December 2021 and all `testfile2` and `testfile4` are from April 2021.
```
$ tree parentdir                $ tree parentdir
parentdir                       parentdir
└── testdir                     ├── testdir
    ├── testdir1                │   ├── testdir1
    │   ├── testfile1           │   ├── testdir2
    │   ├── testfile2           │   └── testdir3
    │   ├── testfile3           ├── testdir1
    │   └── testfile4           │   ├── 2021-04
    ├── testdir2                │   │   ├── testfile2
    │   ├── testfile1           │   │   └── testfile4
    │   ├── testfile2           │   └── 2021-12
    │   ├── testfile3           │       ├── testfile1
    │   └── testfile4           │       └── testfile3
    └── testdir3                ├── testdir2
        ├── testfile1           │   ├── 2021-04
        ├── testfile2           │   │   ├── testfile2
        ├── testfile3           │   │   └── testfile4
        └── testfile4           │   └── 2021-12
                                │       ├── testfile1
4 directories, 12 files         │       └── testfile3
                                └── testdir3
                                    ├── 2021-04
                                    │   ├── testfile2
                                    │   └── testfile4
                                    └── 2021-12
                                        ├── testfile1
                                        └── testfile3

                                13 directories, 12 files
```

