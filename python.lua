return {

	{ import = "lazyvim.plugins.extras/lang.python" },
	{ import = "lazyvim.plugins.extras.dap.nlua" },

	-- which key integration
	{
		"folke/which-key.nvim",
		optional = true,
		opts = {
			defaults = {
				["<leader>d"] = { name = "+debug" },
				["<leader>da"] = { name = "+adapters" },
			},
		},
	},

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"mfussenegger/nvim-dap-python",
            -- stylua: ignore
            keys = {
              { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method" },
              { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class" },
            },
				config = function()
					local path = require("mason-registry").get_package("debugpy"):get_install_path()
					require("dap-python").setup(".venv/bin/python")
					table.insert(require("dap").configurations.python, {
						type = "python",
						django = true,
						python = "./.venv/bin/python",
						request = "launch",
						name = "Django",
						program = "./manage.py",
						args = { "runserver" },
						-- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
					})
				end,
			},

			{
				"rcarriga/nvim-dap-ui",
        -- stylua: ignore 
        keys = 
          { { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" }, 
            { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} }, 
          },
				opts = {},
				config = function(_, opts)
					local dap = require("dap")
					local dapui = require("dapui")
					dapui.setup(opts)
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open({})
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close({})
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close({})
					end
				end,
			},

			-- virtual text for the debugger
			{ "theHamsta/nvim-dap-virtual-text", opts = {} },

			-- which key integration
			{
				"folke/which-key.nvim",
				optional = true,
				opts = {
					defaults = {
						["<leader>d"] = { name = "+debug" },
						["<leader>da"] = { name = "+adapters" },
					},
				},
			},

			-- mason.nvim integration
			{
				"jay-babu/mason-nvim-dap.nvim",
				dependencies = "mason.nvim",
				cmd = { "DapInstall", "DapUninstall" },
				opts = {
					-- Makes a best effort to setup the various debuggers with
					-- reasonable debug configurations
					automatic_installation = true,

					-- You can provide additional configuration to the handlers,
					-- see mason-nvim-dap README for more information
					handlers = {
						function(config)
							-- all sources with no handler get passed here

							-- Keep original functionality
							require("mason-nvim-dap").default_setup(config)
						end,
						python = function(config)
							config.adapters = {
								type = "executable",
								command = "/usr/bin/python3",
								args = {
									"-m",
									"debugpy.adapter",
								},
							}
							require("mason-nvim-dap").default_setup(config) -- don't forget this!
						end,
					},

					-- You'll need to check that you have the required things installed
					-- online, please don't ask me how to install them :)
					ensure_installed = {
						-- Update this to ensure that you have the debuggers for the langs you want
					},
				},
			},
		},
        -- stylua: ignore
      keys = {
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
        { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
        { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
        { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
        { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
        { "<leader>dj", function() require("dap").down() end, desc = "Down" },
        { "<leader>dk", function() require("dap").up() end, desc = "Up" },
        { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
        { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
        { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
        { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
        { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
        { "<leader>ds", function() require("dap").session() end, desc = "Session" },
        { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
        { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
      },

		-- draw debug symbol at line's front
		config = function()
			local Config = require("lazyvim.config")
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			for name, sign in pairs(Config.icons.dap) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
				)
			end
		end,
	},

	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
			-- for DAP support
			"mfussenegger/nvim-dap-python",
		},
		config = true,
		keys = {
			"<leader>vs",
			"<cmd>:VenvSelect<cr>",
			-- optional if you use a autocmd (see #🤖-Automate)
			"<leader>vc",
			"<cmd>:VenvSelectCached<cr>",
		},
		opts = {

			-- auto_refresh (default: false). Will automatically start a new search every time VenvSelect is opened.
			-- When its set to false, you can refresh the search manually by pressing ctrl-r. For most users this
			-- is probably the best default setting since it takes time to search and you usually work within the same
			-- directory structure all the time.
			auto_refresh = true,

			-- search_venv_managers (default: true). Will search for Poetry/Pipenv/Anaconda virtual environments in their
			-- default location. If you dont use the default location, you can
			search_venv_managers = false,

			-- search_workspace (default: true). Your lsp has the concept of "workspaces" (project folders), and
			-- with this setting, the plugin will look in those folders for venvs. If you only use venvs located in
			-- project folders, you can set search = false and search_workspace = true.
			search_workspace = true,

			-- path (optional, default not set). Absolute path on the file system where the plugin will look for venvs.
			-- Only set this if your venvs are far away from the code you are working on for some reason. Otherwise its
			-- probably better to let the VenvSelect search for venvs in parent folders (relative to your code). VenvSelect
			-- searchs for your venvs in parent folders relative to what file is open in the current buffer, so you get
			-- different results when searching depending on what file you are looking at.
			-- path = "/home/username/your_venvs",

			-- search (default: true). Search your computer for virtual environments outside of Poetry and Pipenv.
			-- Used in combination with parents setting to decide how it searches.
			-- You can set this to false to speed up the plugin if your virtual envs are in your workspace, or in Poetry
			-- or Pipenv locations. No need to search if you know where they will be.
			search = true,

			-- dap_enabled (default: false). When true, uses the selected virtual environment with the debugger.
			-- require nvim-dap-python from https://github.com/mfussenegger/nvim-dap-python
			-- require debugpy from https://github.com/microsoft/debugpy
			-- require nvim-dap from https://github.com/mfussenegger/nvim-dap
			dap_enabled = true,

			-- parents (default: 2) - Used when search = true only. How many parent directories the plugin will go up
			-- (relative to where your open file is on the file system when you run VenvSelect). Once the parent directory
			-- is found, the plugin will traverse down into all children directories to look for venvs. The higher
			-- you set this number, the slower the plugin will usually be since there is more to search.
			-- You may want to set this to to 0 if you specify a path in the path setting to avoid searching parent
			-- directories.
			parents = 2,

			-- name (default: venv) - The name of the venv directories to look for.
			name = { "venv", ".venv" }, -- NOTE: You can also use a lua table here for multiple names: {"venv", ".venv"}`

			-- fd_binary_name (default: fd) - The name of the fd binary on your system.
			fd_binary_name = "fdfind",

			-- notify_user_on_activate (default: true) - Prints a message that the venv has been activated
			notify_user_on_activate = true,
		},
	},
}
