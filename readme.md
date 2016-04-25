# Functional Lua
## Fun functional programming with Lua.

```lua
local videos = {
  {id = 5, title = "Die Hard", rating = 5, boxart = {
    {id = 52, width = 512, height = 1024},
    {id = 88, width = 256, height = 768}
  }},
  {id = 233, title = "Up", rating = 5, boxart = {
    {id = 202, width = 512, height = 1024},
    {id = 203, width = 256, height = 768}
  }},
  {id = 12, title = "Funny Man", rating = 2, boxart = {
    {id = 32, width = 512, height = 1024},
    {id = 84, width = 256, height = 768}
  }},
  {id = 105, title = "Bad Boys", rating = 4, boxart = {
    {id = 30, width = 512, height = 1024},
    {id = 5, width = 256, height = 768}
  }}
}

-- Select videos where rating is greater than 2
local result = fun(videos):filter(fun.gt(2, 'rating')):concat_map(function(video)
  -- Select boxart where width is 512
  return fun(video.boxart):filter(fun.eq(512, 'width')):map(function(boxart)
    -- Create entry
    return {id = video.id, title = video.title, boxart = boxart.id}
  end)
end)

--[[ result:
{
  {id = 5, title = "Die Hard", boxart = 202},
  {id = 233, title = "Up", boxart = 32},
  {id = 105, title = "Bad Boys", boxart = 30}
}
]]--
```

## About
Functional lua adds methods to help with functional programming.
It all revolves around the `fun` functable. Call `fun()` on your own table you wish to transform.

```lua
local items = {1,2,3,4,5}
fun(items):map(function(value) return value * 2 end)
-- returns: {2,4,6,8,10}
```

This allows you to easily chain functions. Do note that this will modify the `__index` metamethod of the `items` table. If you wish to not modify the metatable you can use this form:

```lua
local items = {1,2,3,4,5}
fun.map(items, function(value) return value * 2 end)
-- returns: {2,4,6,8,10}
```

But the return table will be still be chainable!

```lua
local items = {1,2,3,4,5}
fun
  .map(items, function(value) return value * 2 end)
  :filter(fun.gt(6)) -- gt = greater than
-- returns: {8,10}
```

## Main functions
The three main functions are `map`, `filter` and `reduce`. A lot can be achieved with just these three. Say you have an table of points and you want to shift them all to the right:

```lua
shifted_points = fun(points):map(function(p)
  return {x = p.x + 5, y = p.y}
end)
```

Filter lets you select specific fields according to some predicate, in this case we shift only the points where x > 0.

```lua
shifted_points = fun(points)
  :filter(function(p) return p.x > 0 end)
  :map(function(p)
    return {x = p.x + 5, y = p.y}
  end)
```
We can shorten that a bit by using the built in operator functions

```lua
filter(fun.gt(0, 'x'))
```

There's also `gte`, `lt`, `lte`, `eq`, `neq`, `and_fn`, `and_v`, `or_fn`, `or_v`, `not_fn`, `not_v` and `istype`. The `_fn` operators take two functions, one for either side, and is meant to operator with the other value operators.

If we wanted to get the average of all points we use the `reduce` method:

```lua
average_point = fun(points):reduce(function(average, p, i)
  average.x = average.x + p.x
  average.y = average.y + p.y
  if i == #points then
    average.x = average.x / #points
    average.y = average.y / #points
  end
  return average
end, {x = 0, y = 0})
```

We can use some use helper functions to make life easier such as `curry`:

```lua
function offset_point( p, x_offset, y_offset )
  return {x = p.x + x_offset, y = p.y + y_offset}
end
offset_x_5 = fun.curry(offset_point, 5, 0)
shifted_points = fun(point):map(offset_x_5)
```

The examples above do not modify the original `points` table, they return a new table with the modified points. If you wanted to modify them in place you would use the `for_each` method:

```lua
fun(points):for_each(function(p) p.x = p.x + 5 end)
```
