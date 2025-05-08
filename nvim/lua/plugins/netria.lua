-- modern floating UI for netrw in nv
return {
  "mirhajian/netria",
  event = "VeryLazy",  -- Delays plugin registration until after startup
  config = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        require("netria").setup({
          title = " Netria ",
          position = "center",
          centered = true,
          width = 0.7,
          height = 0.8,
          border = true,
          border_style = "rounded",
          hide_banner = true,
          liststyle = 3,
          winsize = 0,
          show_line_numbers = true,
          show_relative_numbers = true,
          no_modify = true,
          readonly = true,
          no_wrap = true,
          banner = {
            enabled = true,
            art = {
              "",
              "███╗   ██╗███████╗████████╗██████╗ ██╗ █████╗    ┌───────────────────────────────┐",
              "████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║██╔══██╗   │ Netria - A Nice Looking Netrw │",
              "██╔██╗ ██║█████╗     ██║   ██████╔╝██║███████║   │ Version: 1.0.0                │",
              "██║╚██╗██║██╔══╝     ██║   ██╔══██╗██║██╔══██║   │ :Netria - Open Explorer       │",
              "██║ ╚████║███████╗   ██║   ██║  ██║██║██║  ██║   │ :NetriaToggle - Toggle Nerria │",
              "╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝   └───────────────────────────────┘",
              ""
            },
          },
        })
      end,
    })
  end,
}
