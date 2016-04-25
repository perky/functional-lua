fun = {}
fun._meta = {__index = fun}
fun.bound_functions = {}

function fun.attach_to( _, obj )
	if type(obj) == "table" then
		setmetatable(obj, fun._meta)
	end
	return obj
end

setmetatable(fun, {
	__index = fun.bound_functions,
	__call = fun.attach_to
})

function fun.curryleft( fn, ... )
	local fixed_args = {...}
	return function( ... )
		return fn(unpack(fixed_args), unpack({...}))
	end
end

function fun.curry( fn, ... )
	local fixed_args = {...}
	return function( ... )
		return fn(unpack({...}), unpack(fixed_args))
	end
end

function fun.tabulate( fn )
	local _i = 0
	return function(a)
		_i = _i + 1
		return fn(_i-1)
	end
end

function fun.spy( fn )
	local spy = {
		count = 0,
		last_args = {}
	}
	setmetatable(spy, {
		__call = function(_, ...)
			spy.count = spy.count + 1
			spy.last_args = {...}
			return fn(...)
		end
	})
	return spy
end

function fun.call( fn, ... )
	return fn(...)
end

function fun.push( items, value, key )
	if key and type(key) == "number" then
		table.insert(items, value)
	else
		items[key] = value
	end
	return fun(items)
end

function fun.compose( ... )
	local fns = {...}
	return function(...)
		local last = {...}
		for i = 1, #fns do
			last = {fns[i](unpack(last))}
		end
		return unpack(last)
	end
end

function fun.map( items, fn )
	local out = {}
	for k, v in pairs(items) do
		out[k] = fn(v, k)
	end
	return fun(out)
end

function fun.map_array( items, fn )
	local out = {}
	for k, v in pairs(items) do
		table.insert(out, fn(v, k))
	end
	return fun(out)
end

function fun.for_each( items, fn )
	for k, v in pairs(items) do
		fn(v, k, items)
	end
	return fun(items)
end

function fun.filter( items, predicate )
	local out = {}
	for k, v in pairs(items) do
		if predicate(v, k, items) then
			fun.push(out, v, k)
		end
	end
	return fun(out)
end

function fun.difference_left( a, b )
	return fun
	.filter(a, function(aval)
		return fun.every(b, function(bval) return bval ~= aval end)
	end)
end

function fun.difference( a, b )
	return fun
	.difference_left(a, b)
	:concat(fun.difference_left(b, a))
end

function fun.intersect( a, b )
	return fun
	.filter(a, function(aval)
		return fun.any(b, function(bval) return bval == aval end)
	end)
end

function fun.concat( a, b )
	local out = {}
	for k, v in pairs(a) do
		fun.push(out, v, k)
	end
	for k, v in pairs(b) do
		fun.push(out, v, k)
	end
	return fun(out)
end

function fun.concat_all( items )
	local out = {}
	fun.for_each(items, function(a)
		if type(a) == "table" then
			fun.for_each(a, function(b)
				table.insert(out, b)
			end)
		else
			table.insert(out, a)
		end
	end)
	return fun(out)
end

function fun.concat_map( items, fn )
	return fun.map(items, function(v,k,items) return fn(v,k,items) end):concat_all()
end

function fun.reduce( items, fn, initial )
	local reduceOne
	local len = initial and (#items) or (#items-1)
	local offset = initial and (0) or (1)
	reduceOne = function(index, value)
		if (index > len) then
			return value
		end
		return reduceOne(index + 1, fn(value, items[index+offset], index, items))
	end
	return fun(reduceOne(1, initial or items[1]))
end

function fun.every( items, predicate )
	for k, v in pairs(items) do
		if not predicate(v, k, items) then
			return false
		end
	end
	return true
end

function fun.any( items, predicate )
	for k, v in pairs(items) do
		if predicate(v, k, items) then
			return true
		end
	end
	return false
end

function fun.apply( items, fn )
	if type(items) == 'function' then
		local fn = items
		return fun.curry(fun.map, fn)
	else
		return fun.reduce(items, function(left, right)
			return fn(left, right)
		end)
	end
end

function fun.aggregate( items, fn, initial )
	return fun.reduce(items, function(a, b)
		return fn(a, b)
	end, initial)
end

function fun.pluck( items, key )
	return fun.map(items, function(a) return a[key] end)
end

function fun.best( items, fn, initial )
	local compare = function( a , b )
		return fn(a,b) and a or b
	end
	return fun.reduce(items, compare, initial)
end

function fun.array_only( items )
	return fun.filter(items, function(a, key) return type(key) == "number" end)
end

function fun.insert_to( items )
	return function(a) table.insert(items, a) end
end

function fun.to_array( items )
	local out = {}
	local insert = fun.insert_to(out)
	fun.for_each(items, insert)
	return fun(out)
end

function fun.map_key_value( items )
	local values = fun.map_array(items, function(v,k) return v end)
	local keys = fun.map_array(items, function(v,k) return k end)
	return fun.zip_with(values, keys, function(v,k)
		return {value = v, key = k}
	end)
end

function fun.shuffle( items )
	return fun(items)
	:to_array()
	:for_each(function(a, index, t)
		local roll = math.random(1, index)
		t[roll], t[index] = t[index], t[roll]
	end)
end

function fun.first( items )
	for i, v in ipairs(items) do
		return fun(v)
	end
	for k, v in pairs(items) do
		return fun(v)
	end
	return fun({})
end

function fun.last( items )
	if #items > 0 then
		return fun(items[#items])
	else
		local last
		for k, v in pairs(items) do
			last = v
		end
		return fun(last)
	end
	return fun({})
end

function fun.zip( a, b )
	return fun.zip_with(a, b, function(_a, _b) return {_a, _b} end)
end

function fun.zip_flat( a, b )
	local out = {}
	for i = 1, math.min(#a, #b) do
		table.insert(out, a[i])
		table.insert(out, b[i])
	end
	return fun(out)
end

function fun.zip_with( a, b, fn )
	local out = {}
	for i = 1, math.min(#a, #b) do
		out[i] = fn(a[i], b[i])
	end
	return fun(out)
end

function fun.select_while( items, predicate )
	local out = {}
	for k, v in pairs(items) do
		if predicate(v, k, items) then
			fun.push(out, v, k)
		else
			break
		end
	end
	return fun(out)
end

function fun.negate_predicate( predicate )
	return function(...) return not predicate(...) end
end

function fun.select_until( items, predicate )
	return fun.select_while(items, fun.negate_predicate(predicate))
end

function fun.bind( name, fn, arg )
	fun.bound_functions[name] = fun.curry(fn, arg)
end

function fun.noop()
end

function fun.value( value, key, items )
	return value
end

function fun.key( value, key, items )
	return key
end

function fun.items( value, key, items )
	return items
end

function fun.prop( obj, key )
	return type(obj) == 'table' and obj[key] or obj
end

function fun.value_or_prop( fn, k )
	local value_or_prop = fun.curry(fun.prop, k)
	return fun.compose(value_or_prop, fn)
end

function fun.eq( b, k )
	local fn = function(a) return a == b end
	return fun.value_or_prop(fn, k)
end

function fun.neq( b, k )
	local fn = function(a) return a ~= b end
	return fun.value_or_prop(fn, k)
end

function fun.gte( b, k )
	local fn = function(a) return a >= b end
	return fun.value_or_prop(fn, k)
end

function fun.gt( b, k )
	local fn = function(a) return a > b end
	return fun.value_or_prop(fn, k)
end

function fun.lt( b, k )
	local fn = function(a) return a < b end
	return fun.value_or_prop(fn, k)
end

function fun.lte( b, k )
	local fn = function(a) return a <= b end
	return fun.value_or_prop(fn, k)
end

function fun.and_fn( a, b, k )
	local fn = function(v) return a(v) and b(v) end
	return fun.value_or_prop(fn, k)
end

function fun.or_fn( a, b, k )
	local fn = function(v) return a(v) or b(v) end
	return fun.value_or_prop(fn, k)
end

function fun.not_fn( a, k )
	local fn = function(v) return not a(v) end
	return fun.value_or_prop(fn, k)
end

function fun.and_v( b, k )
	local fn = function(v) return v and b end
	return fun.value_or_prop(fn, k)
end

function fun.or_v( b, k )
	local fn = function(v) return v or b end
	return fun.value_or_prop(fn, k)
end

function fun.not_v( k )
	local fn = function(v) return not v end
	return fun.value_or_prop(fn, k)
end

function fun.istype( b, k )
	local fn = function(a) return type(a) == b end
	return fun.value_or_prop(fn, k)
end

function fun.len(a)
	return #a
end

function fun.identy(...)
	return ...
end

function fun.sum( items, fn )
	local fn = fn or fun.identy
	return fun.reduce(items, function(a, b)
		return a + fn(b)
	end, 0)
end
