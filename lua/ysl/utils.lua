local M = {}


-- =================
-- === Constants ===
-- =================
local sep = vim.fn.has('win32') == 1 and '\\' or '/'
M.SEP = sep

M.TOBOOLEAN = {
  ['true'] = true,
  ['false'] = false
}

M.SIGNS = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

M.GROUP = {
  NVIM_LSP = vim.api.nvim_create_augroup('UserLspConfig', {})
}

M.LSP = {
  CSPELL = {
    FILETYPES = {
      'markdown',
      'plaintext'
    },
    EXTRA_ARGS = {
      CONFIG = vim.fn.stdpath('config') .. sep .. 'templates' .. sep .. 'cspell.json'
    }
  },
  FLAKE8 = {
    EXTRA_ARGS = {
      '--max-line-length=120',
      '--ignore=ANN101,ANN102,E402,E741,E203',
    }
  },
  BLACK = {
    EXTRA_ARGS = {
      '--line-length=120',
      '--skip-string-normalization',
    }
  }
}

local path = function(...)
  local result, _ = table.concat({ ... }, sep):gsub('/', sep)
  return result
end

M.CUSTOM_SNIPPETS_PATH = path(vim.fn.stdpath('config'), 'templates', 'snippets')

-- =================
-- === Functions ===
-- =================

-- Set a value if given secret is not nil, else default to public.
-- @param secret: the given value.
-- @param public: the default value.
-- @return: if secret is not nil, then return it. Else return default.
M.set = function(secret, public) return secret ~= nil and secret or public end

-- Safely get value from a table.
-- @param item: table
-- @param keys: str|list
-- @return: value of the table
M.safeget = function(item, keys)
  local next = next
  if type(item) ~= 'table' or next(item) == nil then
    return nil
  end
  if type(keys) == 'string' then
    keys = { keys }
  end
  local idx = 1
  while type(item) == 'table' do
    item = item[keys[idx]]
    if idx == #keys then
      return item
    end
    idx = idx + 1
  end
  return nil
end

-- Split string by character.
-- @param inputstr: string
-- @param sep: string(character)
-- @return: the table contains the splited strings.
M.splitstr = function(inputstr, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

-- Find a string in a string list with regex
-- @param input: list[string]
-- @param str: string
M.greplist = function (inputlist, str)
  for _, v in ipairs(inputlist) do
    if v:match(str) then
      return v
    end
  end
  return nil
end

M.flattenlist = function(complexlist)
    local flattenedList = {}
    for _, list in ipairs(complexlist) do
        if type(list) ~= 'table' then
          list = { list }
        end
        for _, value in ipairs(list) do
            table.insert(flattenedList, value)
        end
    end
    return flattenedList
end

M.path = path

return M
