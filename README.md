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

## Examples

<img width="1509" alt="image" src="https://github.com/user-attachments/assets/31294f36-034d-4464-9ccb-420eb6141bb7" />


## Roadmap

- [ ] more configuration
- [ ] more segment options
- [ ] documentation
