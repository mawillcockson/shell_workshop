if arg == nil then
  os.exit()
end

local keys = {}
for key, value in pairs(arg) do
  keys[#keys + 1] = key
end

table.sort(keys)

for i, key in ipairs(keys) do
  print(tostring(key) .. " " .. arg[key])
end
