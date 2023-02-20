local status_ok, notify = pcall(require, "notify")
if not status_ok then
	return
end


notify.setup({
    opts = {
--     ---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
      -- stages = "fade_in_slide_out",
--     -- Render function for notifications. See notify-render()
      render = "default",
--     ---@usage highlight behind the window for stages that change opacity
      background_colour = "Normal",
    },
})

vim.notify = notify
