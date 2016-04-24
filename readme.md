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
