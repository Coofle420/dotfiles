-- Noctalia "DarkPurple" palette (matches bar, Mango, kitty, Helium, btop)
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "noctalia-purple"

local c = {
  bg = "#120c1f", bg_alt = "#1f1535", bg_deep = "#0c0816", hover = "#2c1f4d", sel = "#3a2a66",
  line = "#4a3a78", fg = "#e9e0ff", fg_dim = "#c4b5e8", comment = "#7d6aa8",
  primary = "#b388ff", secondary = "#d58cf5", tertiary = "#8f9bff",
  red = "#ff6b9d", green = "#8de6b0", yellow = "#f7d58a", cyan = "#7fe0e8", orange = "#ffb48a",
}

local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end
local function link(a, b) vim.api.nvim_set_hl(0, a, { link = b, default = false }) end

-- Editor
hl("Normal", { fg = c.fg, bg = "NONE" })
hl("NormalNC", { fg = c.fg, bg = "NONE" })
hl("NormalFloat", { fg = c.fg, bg = c.bg_alt })
hl("FloatBorder", { fg = c.primary, bg = c.bg_alt })
hl("FloatTitle", { fg = c.bg, bg = c.primary, bold = true })
hl("SignColumn", { bg = "NONE" })
hl("EndOfBuffer", { fg = c.bg })
hl("LineNr", { fg = c.line })
hl("CursorLineNr", { fg = c.primary, bold = true })
hl("CursorLine", { bg = c.bg_alt })
hl("ColorColumn", { bg = c.bg_alt })
hl("Visual", { bg = c.sel })
hl("VisualNOS", { bg = c.sel })
hl("Search", { fg = c.bg, bg = c.yellow })
hl("IncSearch", { fg = c.bg, bg = c.secondary })
hl("CurSearch", { fg = c.bg, bg = c.secondary })
hl("MatchParen", { fg = c.secondary, bold = true, underline = true })
hl("VertSplit", { fg = c.line })
hl("WinSeparator", { fg = c.line })
hl("StatusLine", { fg = c.fg, bg = c.bg_alt })
hl("StatusLineNC", { fg = c.comment, bg = c.bg_alt })
hl("TabLine", { fg = c.fg_dim, bg = c.bg_alt })
hl("TabLineSel", { fg = c.bg, bg = c.primary, bold = true })
hl("TabLineFill", { bg = c.bg_deep })
hl("Pmenu", { fg = c.fg, bg = c.bg_alt })
hl("PmenuSel", { fg = c.fg, bg = c.sel, bold = true })
hl("PmenuSbar", { bg = c.hover })
hl("PmenuThumb", { bg = c.primary })
hl("Folded", { fg = c.comment, bg = c.bg_alt })
hl("FoldColumn", { fg = c.line })
hl("NonText", { fg = c.line })
hl("Whitespace", { fg = c.hover })
hl("SpecialKey", { fg = c.line })
hl("Directory", { fg = c.tertiary })
hl("Title", { fg = c.primary, bold = true })
hl("ErrorMsg", { fg = c.red, bold = true })
hl("WarningMsg", { fg = c.yellow })
hl("MoreMsg", { fg = c.green })
hl("Question", { fg = c.tertiary })
hl("WildMenu", { fg = c.bg, bg = c.primary })
hl("Cursor", { fg = c.bg, bg = c.primary })
hl("lCursor", { fg = c.bg, bg = c.primary })
hl("TermCursor", { fg = c.bg, bg = c.primary })
hl("DiffAdd", { bg = "#1b3a2f" })
hl("DiffChange", { bg = "#2a2250" })
hl("DiffDelete", { bg = "#3d1a30" })
hl("DiffText", { bg = "#3a2a66" })
hl("SpellBad", { undercurl = true, sp = c.red })
hl("SpellCap", { undercurl = true, sp = c.yellow })

-- Syntax
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.orange })
hl("String", { fg = c.green })
hl("Character", { fg = c.green })
hl("Number", { fg = c.orange })
hl("Boolean", { fg = c.orange })
hl("Float", { fg = c.orange })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.tertiary })
hl("Statement", { fg = c.primary })
hl("Conditional", { fg = c.primary })
hl("Repeat", { fg = c.primary })
hl("Label", { fg = c.primary })
hl("Operator", { fg = c.cyan })
hl("Keyword", { fg = c.primary, italic = true })
hl("Exception", { fg = c.red })
hl("PreProc", { fg = c.secondary })
hl("Include", { fg = c.secondary })
hl("Define", { fg = c.secondary })
hl("Macro", { fg = c.secondary })
hl("Type", { fg = c.yellow })
hl("StorageClass", { fg = c.yellow })
hl("Structure", { fg = c.yellow })
hl("Special", { fg = c.cyan })
hl("SpecialChar", { fg = c.cyan })
hl("Delimiter", { fg = c.fg_dim })
hl("Underlined", { fg = c.tertiary, underline = true })
hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })
hl("Error", { fg = c.red })

-- Treesitter / semantic
for g, t in pairs({
  ["@variable"] = "Identifier", ["@constant"] = "Constant", ["@string"] = "String", ["@number"] = "Number",
  ["@boolean"] = "Boolean", ["@function"] = "Function", ["@function.call"] = "Function", ["@method"] = "Function",
  ["@keyword"] = "Keyword", ["@operator"] = "Operator", ["@type"] = "Type", ["@comment"] = "Comment",
  ["@punctuation"] = "Delimiter", ["@constructor"] = "Type", ["@module"] = "Include",
}) do link(g, t) end
hl("@variable.builtin", { fg = c.red })
hl("@variable.parameter", { fg = c.orange })
hl("@property", { fg = c.cyan })
hl("@tag", { fg = c.primary })
hl("@tag.attribute", { fg = c.secondary })
hl("@markup.heading", { fg = c.primary, bold = true })
hl("@markup.link", { fg = c.tertiary, underline = true })

-- Diagnostics / LSP
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.tertiary })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticOk", { fg = c.green })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.tertiary })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.cyan })
hl("LspReferenceText", { bg = c.hover })
hl("LspReferenceRead", { bg = c.hover })
hl("LspReferenceWrite", { bg = c.hover })

-- Git signs, indent guides, plugin UI used by LazyVim
hl("GitSignsAdd", { fg = c.green }); hl("GitSignsChange", { fg = c.tertiary }); hl("GitSignsDelete", { fg = c.red })
hl("IblIndent", { fg = c.hover }); hl("IblScope", { fg = c.primary })
hl("SnacksIndent", { fg = c.hover }); hl("SnacksIndentScope", { fg = c.primary })
hl("SnacksPickerDir", { fg = c.comment }); hl("SnacksPickerMatch", { fg = c.secondary, bold = true })
hl("WhichKey", { fg = c.primary }); hl("WhichKeyDesc", { fg = c.fg }); hl("WhichKeyGroup", { fg = c.tertiary })
hl("BlinkCmpMenu", { fg = c.fg, bg = c.bg_alt }); hl("BlinkCmpMenuBorder", { fg = c.primary, bg = c.bg_alt })
hl("BlinkCmpMenuSelection", { bg = c.sel }); hl("BlinkCmpLabelMatch", { fg = c.secondary, bold = true })
hl("LazyNormal", { bg = c.bg_alt }); hl("MasonNormal", { bg = c.bg_alt })
hl("NoicePopupmenu", { bg = c.bg_alt })
hl("MiniStatuslineModeNormal", { fg = c.bg, bg = c.primary, bold = true })
hl("MiniStatuslineModeInsert", { fg = c.bg, bg = c.green, bold = true })
hl("MiniStatuslineModeVisual", { fg = c.bg, bg = c.secondary, bold = true })

-- Terminal colours
local term = { c.bg_alt, c.red, c.green, c.yellow, c.tertiary, c.secondary, c.cyan, c.fg_dim,
  c.line, "#ff8fb5", "#a8f0c4", "#ffe3a3", "#aab4ff", "#e5a8ff", "#a0eef3", c.fg }
for i, col in ipairs(term) do vim.g["terminal_color_" .. (i - 1)] = col end
