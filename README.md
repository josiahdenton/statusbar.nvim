# statusbar.nvim

This provides a "status" bar for nvim. I prefer having a less busy statusline
but still wanted all the info that typically comes with a statusline. This
is where the statusbar plugin comes in! 

> [!caution]
> bugs may exist, please report

## Install

#### [Lazy](https://github.com/folke/lazy.nvim)

```lua
{
    "josiahdenton/statusbar.nvim",
    config = function()
        require("statusbar").setup()
    end,
},
```

## Usage
