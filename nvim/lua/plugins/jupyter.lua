-- ~/.config/nvim/lua/plugins/jupyter.lua

return {
    {
        "benlubas/molten-nvim",
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        opts = {
            auto_open_output = true,
            enter_output_behavior = "open_and_enter",
        },
        config = function(_, opts)
            for k, v in pairs(opts) do
                vim.g["molten_" .. k] = v
            end
        end,
    },
}
