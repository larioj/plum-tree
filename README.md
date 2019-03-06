# plum-tree
Plum actions on tree output

## Example
Open files by clicking on a tree:
```txt
  .
  ├── README.md
  └── autoload
      └── plum
          └── tree.vim
```

## plum#tree#File()
Open file from tree format.

## plum#tree#Directory()
List directory from tree format.

## Recommended Priority
```viml
let g:plum_actions = [
      \ plum#fso#Directory(),
      \ plum#fso#File(),
      \ plum#term#SmartTerminal(),
      \ plum#vim#Execute(),
      \ plum#tree#Directory(),
      \ plum#tree#File(),
      \ ]
```
