# THIS PROJECT WAS MOVED TO GITLAB.

# LinShares

Set filesystem permissions for fileshares easily!

### The problem

Let's say you have a directory structure that you want to share:

```
\myshares
    \toplevel1
        \midlevel1
        \midlevel2
    \toplevel2
        \midlevel3
        \midlevel4
```

You want very granular control over who will be able to access what. Ideally, you want to manage users in Linux groups, with two groups for each directory: one for readers, and one for those who can write there too.

So for the above example, that would mean 12 groups: toplevel1 readers, toplevel1 writers, midlevel1 readers, midlevel1 writers, midlevel2 readers... and so on.

Let's say the naming convention is this: `<prefix>_<parentdir>_<subdir>_ro` for the reader group, and `<prefix>_<parentdir>_<subdir>_rw` for the writer group. Of course depth is not limited to two, it can be any number, or can differ on tree branches.

For the above example, groups would be `shr_toplevel1_midlevel1_ro`, `shr_toplevel1_midlevel1_rw`, `shr_toplevel1_midlevel2_ro`, and so on.

Now you want to set filesystem permissions accordingly. For that, we use the acl features.

And that's it, groups and permissions are set up!

### LinShares

```
linshares.sh [-d <shares directory>] [-r] [-s] [-p <group name prefix>] [-h]

Options:
  -d <shares directory>  Root directory of the share structure. Groups will be
                         made based on this, permissions will be set here.
                         Default: .
  -r                     Real run. Do not just simulate, actually add groups
                         and set permissions.
  -s                     Simulation. Will only print actions. (Default)
  -p <prefix>            System group name prefix. Default: 'shr_'
  -g <start id>          New system group ids start from <start id>
                         Default: 3000
  -h                     Show help with command line options.
```

### Licence

MIT Licence
