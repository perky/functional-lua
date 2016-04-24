# Functional Lua
## Fun functional programming with Lua.

```
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
```
