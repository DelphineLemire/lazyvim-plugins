return {

	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		-- build = "cd app && yarn install",
		build = ":call mkdp#util#install()",

		dependencies = {
			-- which key integration
			{
				"folke/which-key.nvim",
				optional = true,
				opts = {
					defaults = {
						["<leader>m"] = { name = "+markdown" },
					},
				},
				keys = {
					{ "<leader>mp", "<cmd>:MarkdownPreview<cr>", desc = "MarkdownPreview" },
					{ "<leader>ms", "<cmd>:MarkdownPreviewStop<cr>", desc = "MarkdownPreviewStop" },
					{ "<leader>mt", "<cmd>:MarkdownPreviewToggle<cr>", desc = "MarkdownPreviewToggle" },
				},
			},
		},
	},
}
