vim.cmd("highlight clear")
vim.cmd("syntax reset")
vim.g.colors_name = "clrsync"

local palette = {
    -- Editor colors
    Default                 = "{editor_main.hex}",
    Keyword                 = "{editor_command.hex}",
    Number                  = "{editor_warning.hex}",
    String                  = "{editor_string.hex}",
    CharLiteral             = "{editor_string.hex}",
    Punctuation             = "{editor_main.hex}",
    Preprocessor            = "{editor_emphasis.hex}",
    Identifier              = "{editor_main.hex}",
    KnownIdentifier         = "{editor_link.hex}",
    PreprocIdentifier       = "{editor_link.hex}",

    Comment                 = "{editor_comment.hex}",
    MultiLineComment        = "{editor_comment.hex}",

    Background              = "{editor_background.hex}",
    Cursor                  = "{cursor.hex}",

    Selection               = "{editor_selected.hex}",
    ErrorMarker             = "{editor_error.hex}",
    Breakpoint              = "{editor_error.hex}",

    LineNumber              = "{editor_line_number.hex}",
    CurrentLineFill         = "{surface_variant.hex}",
    CurrentLineFillInactive = "{surface.hex}",

    CurrentLineEdge         = "{border_focused.hex}",
    
    -- Semantic colors
    Success                 = "{success.hex}",
    Warning                 = "{warning.hex}",
    Error                   = "{error.hex}",
    Info                    = "{info.hex}",
}

-- Helper function to set highlights in Neovim
local function set_hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

vim.o.winborder = "rounded"

-- Basic editor highlights using the mapped palette
set_hl("Normal", { fg = palette.Default, bg = palette.Background })
set_hl("CursorLine", { bg = palette.CurrentLineFill })
set_hl("Visual", { bg = palette.Selection })
set_hl("LineNr", { fg = palette.LineNumber })
set_hl("CursorLineNr", { fg = palette.Keyword })

-- Syntax highlights
set_hl("Comment", { fg = palette.Comment, italic = true })
set_hl("Constant", { fg = palette.Number })
set_hl("String", { fg = palette.String })
set_hl("Character", { fg = palette.CharLiteral })
set_hl("Identifier", { fg = palette.Identifier })
set_hl("Function", { fg = palette.Keyword })
set_hl("Statement", { fg = palette.Keyword })
set_hl("PreProc", { fg = palette.Preprocessor })
set_hl("Type", { fg = palette.Keyword })
set_hl("Special", { fg = palette.PreprocIdentifier })
set_hl("Underlined", { fg = palette.KnownIdentifier })
set_hl("Error", { fg = palette.ErrorMarker, bg = palette.Background })
set_hl("Todo", { fg = palette.Default, bg = palette.Keyword })

-- Floating windows
set_hl("NormalFloat", { bg = palette.Background })
set_hl("FloatBorder", { fg = palette.CurrentLineEdge, bg = palette.Background })

-- Completion menu
set_hl("Pmenu", { bg = palette.Background })
set_hl("PmenuSel", { bg = palette.Keyword, fg = palette.Background })

-- Git and diagnostic highlights
set_hl("DiffAdd", { fg = palette.Success, bg = palette.Background })
set_hl("DiffChange", { fg = palette.Keyword, bg = palette.Background })
set_hl("DiffDelete", { fg = palette.ErrorMarker, bg = palette.Background })
set_hl("DiagnosticError", { fg = palette.Error })
set_hl("DiagnosticWarn", { fg = palette.Warning })
set_hl("DiagnosticInfo", { fg = palette.Info })
set_hl("DiagnosticHint", { fg = palette.PreprocIdentifier })

-- Treesitter links
set_hl("@comment", { link = "Comment" })
set_hl("@string", { fg = palette.String })
set_hl("@function", { fg = palette.Keyword })
set_hl("@variable", { fg = palette.Identifier })
set_hl("@keyword", { fg = palette.Keyword })
set_hl("@type", { fg = palette.Preprocessor })