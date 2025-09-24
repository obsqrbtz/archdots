vim.cmd("highlight clear")
vim.cmd("syntax reset")
vim.g.colors_name = "matugen"

local palette = {
	background = "{{colors.background.default.hex}}",
	onBackground = "{{colors.on_background.default.hex}}",
	outline = "{{colors.outline.default.hex}}",
	primary = "{{colors.primary.default.hex}}",
	secondary = "{{colors.secondary.default.hex}}",
	tertiary = "{{colors.tertiary.default.hex}}",
	surfaceVariant = "{{colors.surface_variant.default.hex}}",
	error = "{{colors.red.default.hex}}",
	warning = "{{colors.orange.default.hex}}",
	success = "{{colors.green.default.hex}}",
	underline = "{{colors.red_source.default.hex}}",
}

local function set_hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

vim.o.winborder = "rounded"

-- Basic highlights
set_hl("Normal", { fg = palette.ground, bg = palette.background })
set_hl("Comment", { fg = palette.outline, italic = false })
set_hl("Constant", { fg = palette.primary })
set_hl("String", { fg = palette.outline })
set_hl("Identifier", { fg = palette.tertiary })
set_hl("Function", { fg = palette.tertiary })
set_hl("Statement", { fg = palette.primary })
set_hl("PreProc", { fg = palette.onBackground })
set_hl("Type", { fg = palette.primary })
set_hl("Special", { fg = palette.secondary })
set_hl("Underlined", { fg = palette.underline })
set_hl("Error", { fg = palette.error, bg = palette.background })
set_hl("Todo", { fg = palette.background, bg = palette.secondary })

-- Line numbers
set_hl("LineNr", { fg = palette.outline })
set_hl("CursorLineNr", { fg = palette.tertiary })

-- Cursor and selection
set_hl("CursorLine", { bg = palette.surfaceVariant })
set_hl("Visual", { bg = palette.surfaceVariant })

-- Status line
set_hl("StatusLine", { fg = palette.background, bg = palette.tertiary })
set_hl("StatusLineNC", { fg = palette.outline, bg = palette.background })

-- Tabline
set_hl("TabLine", { fg = palette.onBackground, bg = palette.outline })
set_hl("TabLineSel", { fg = palette.background, bg = palette.secondary })

-- Floating windows

set_hl("NormalFloat", { bg = "none" })
set_hl("FloatBorder", { fg = palette.tertiary, bg = "none" })

-- Completion menu

set_hl("Pmenu", { bg = "none" })
set_hl("PmenuSel", { bg = palette.tertiary, fg = palette.background })

set_hl("BlinkCmpLabel", { bg = "none" })
set_hl("BlinkCmpMenuSelection", { bg = "none" })
set_hl("BlinkCmpMenu", { bg = "none" })
set_hl("BlinkCmpMenuBorder", { fg = palette.tertiary })
set_hl("BlinkCmpDoc", { bg = "none" })
set_hl("BlinkCmpDocBorder", { fg = palette.tertiary })

-- Diff
set_hl("DiffAdd", { fg = palette.success, bg = palette.background })
set_hl("DiffChange", { fg = palette.secondary, bg = palette.background })
set_hl("DiffDelete", { fg = palette.error, bg = palette.background })
set_hl("DiffText", { fg = palette.tertiary, bg = palette.background })

-- Diagnostics
set_hl("DiagnosticError", { fg = palette.error })
set_hl("DiagnosticWarn", { fg = palette.warning })
set_hl("DiagnosticInfo", { fg = palette.primary })
set_hl("DiagnosticHint", { fg = palette.tertiary })

-- Git signs
set_hl("GitSignsAdd", { fg = palette.success })
set_hl("GitSignsChange", { fg = palette.secondary })
set_hl("GitSignsDelete", { fg = palette.error })

-- Treesitter
set_hl("@string", { link = "String" })
set_hl("@function", { link = "Function" })
set_hl("@variable", { fg = palette.onBackground })
