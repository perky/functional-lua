function tablestring(t)
  return table.concat(t, ",")
end

function assert_equal( value, expected, message, negate )
  if negate and (expected == value) then
    error("Expected not "..tostring(expected)..", got "..tostring(value).."  "..(message or ""))
  elseif not negate and (expected ~= value) then
    error("Expected "..tostring(expected)..", got "..tostring(value).."  "..(message or ""))
  end
  return true
end

function assert_table_equal( value, expected, message, negate )
  local equal = true
  if #value ~= #expected then
    equal = false
  else
    for i = 1, #value do
      if value[i] ~= expected[i] then
        equal = false
        break
      end
    end
  end
  if negate and equal then
    error("Expected not "..tablestring(expected)..", got "..tablestring(value).."  "..(message or ""))
  elseif not negate and not equal then
    error("Expected "..tablestring(expected)..", got "..tablestring(value).."  "..(message or ""))
  end
  return true
end

function assert_table_not_equal( value, expected, message )
  return assert_table_equal( value, expected, message, true )
end

function assert_not_equal( value, expected, message, negate )
  return assert_equal(value, expected, message, true)
end

function do_test( fn, k )
  local r, err = pcall(fn)
  local out = r and {"Passed:", k} or {"FAILED:", k, err}
  print(unpack(out))
  return r
end

function test_all()
  local passed = 0
  local count = 0
  for k, fn in pairs(test) do
    if do_test(fn, k) then passed = passed + 1 end
    count = count + 1
  end
  print(string.format("%i / %i tests passed.", passed, count))
end

function test_specific( name )
  if test[name] then
    do_test(test[name], name)
  else
    error("Test with name "..name.." does not exist.")
  end
end
