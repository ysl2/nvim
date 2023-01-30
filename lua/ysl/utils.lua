local M = {}

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

return M
