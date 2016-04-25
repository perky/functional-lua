test = {}

function test.fun()
  local items = {1, 2, 3}
  local result = fun(items)
  assert_equal(result, items)
  assert_equal(items.map, fun.map)
end

function test.spy()
  local somefn = function(a, b, c) return a+b+c end
  somefn = fun.spy(somefn)
  somefn(1,2,3)
  somefn(5,6,7)
  assert_equal(somefn.count, 2)
  assert_table_equal(somefn.last_args, {5,6,7})
end

function test.curry()
  local add = function(a,b) return a + b end
  local add5 = fun.curry(add, 5)
  local result = add5(5)
  assert_equal(result, 10)
end

function test.curryleft()
  local divide = function(a, b) return a / b end
  local divide100by = fun.curryleft(divide, 100)
  local result = divide100by(2)
  assert_equal(result, 50)
end

function test.curry_multiple_args()
  local function offset_point( p, x_offset, y_offset )
    return {x = p.x + x_offset, y = p.y + y_offset}
  end
  local offset_x_5 = fun.curry(offset_point, 5, 0)
  local points = {
    {x = 1, y = 3}, {x = -5, y = 0}, {x = 10, y = -2}
  }
  local result = fun.map(points, offset_x_5)
  assert_table_equal(result[1], {x = 6, y = 3})
end

function test.compose()
  local prefix1 = function(a) return "_" .. a end
  local prefix2 = function(a) return "$" .. a end
  local prefix = fun.compose(prefix1, prefix2)
  local result = prefix("hello")
  assert_equal(result, "$_hello")

  local prefix_reverse = fun.compose(prefix2, prefix1)
  result = prefix_reverse("hello")
  assert_equal(result, "_$hello")
end

function test.map()
  local items    = {2, 10, 100, 50, 1, -50, 0.5}
  local expected = {4, 20, 200, 100, 2, -100, 1}
  local double = function(a) return a * 2 end
  local result = fun.map(items, double)
  assert_table_equal(result, expected)
end

function test.filter()
  local items    = {10, 11, 12, 13, 14, 15, 16}
  local expected = {10, 12, 14, 16}
  local even = function(a) return a % 2 == 0 end
  local result = fun.filter(items, even)
  assert_table_equal(result, expected)
end

function test.reduce()
  local items = {5000, 2, 30, 400}
  local sum = function(last, next, index, t) return last + next end
  local result = fun.reduce(items, sum)
  assert_equal(result, 5432)

  result = fun.reduce(items, sum, 1)
  assert_equal(result, 5433)
end

function test.aggregate()
  local items = {"one", "two", "three"}
  local stringsum = function(a, b) return a + #b end
  local result = fun.aggregate(items, stringsum, 0)
  assert_equal(result, 11)

  local numbers = {2,3,4,1,8,7,9,3}
  local min = fun.aggregate(numbers, math.min)
  assert_equal(min, 1)

  function aggregate_inventories( ... )
    return fun({...}):aggregate(function(out, current)
        fun(current):for_each(function(value, key)
          out[key] = (out[key] or 0) + value
        end)
        return out
    end, {})
  end

  local inventory1 = {a = 10, b = 5, c = 2, e = 9}
  local inventory2 = {a = 10, b = 0, c = 3, d = 1}
  local inventory3 = {d = 1, x = 3, z = 3}
  local count = aggregate_inventories(inventory1, inventory2, inventory3)
  assert_equal(count.a, 20)
  assert_equal(count.b, 5)
  assert_equal(count.c, 5)
  assert_equal(count.e, 9)
  assert_equal(count.d, 2)
end

function test.every()
  local over50items = {51, 52, 99, 65, 78}
  local over20items = {51, 24, 99, 46, 78}
  local isOver50 = function(a) return a > 50 end
  local result = fun.every(over50items, isOver50)
  assert_equal(result, true)

  result = fun.every(over20items, isOver50)
  assert_equal(result, false)
end

function test.any()
  local over50items = {51, 52, 99, 65, 78}
  local over20items = {51, 24, 99, 46, 78}
  local isOver50 = function(a) return a > 50 end
  local result = fun.any(over50items, isOver50)
  assert_equal(result, true)

  result = fun.any(over20items, isOver50)
  assert_equal(result, true)
end

function test.boolean_operators()
  local items = {1,2,3,4,5,6,7,8,9}

  local between4and8 = fun.and_fn(fun.gt(4), fun.lt(8))
  local result = fun(items):filter(between4and8)
  assert_table_equal(result, {5,6,7})

  local predicate2 = fun.or_fn(between4and8, fun.eq(2))
  local result = fun(items):filter(predicate2)
  assert_table_equal(result, {2,5,6,7})

  local predicate3 = fun.and_fn(between4and8, fun.neq(6))
  local result = fun(items):filter(predicate3)
  assert_table_equal(result, {5,7})

  local on = fun.and_v(true)
  local off = fun.and_v(false)
  local items = {a = false, b = false, c = true, d = false}
  local result = fun(items):filter(on):concat_map(fun.key)
  assert_table_equal(result, {'c'})
  local result = fun(items):filter(off):concat_map(fun.key)
  assert_table_equal(result, {})
end

function test.concat()
  local left = {6,5,4}
  local right = {3,2,1}
  local expected = {6,5,4,3,2,1}
  local result = fun.concat(left, right)
  assert_table_equal(result, expected)
end

function test.concat_all()
  local items = {{1,2,3}, {4,5,6}, {7,8,9}}
  local expected = {1,2,3,4,5,6,7,8,9}
  local result = fun.concat_all(items)
  assert_table_equal(result, expected)

  local result = fun.apply(items, fun.concat)
  assert_table_equal(result, expected)
end

function test.concat_map()
  local words = { {"cero","rien","zero"}, {"uno","un","one"}, {"dos","deux","two"} };
  local expected = {"cero","rien","zero", "uno","un","one", "dos","deux","two"}
  local result = fun.concat_map({1,2,3}, function(index)
    return words[index]
  end)
  assert_table_equal(result, expected)

  local movies = {{
    name = "queue",
    videos = {
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
      }},
    }
  }}

  local result = fun(movies):concat_map(function(list)
    -- Select videos where rating is greater than 2
    return fun(list.videos):filter(fun.gt(2, 'rating')):concat_map(function(video)
      -- Select boxart where width is 512
      return fun(video.boxart):filter(fun.eq(512, 'width')):map(function(boxart)
        -- Create entry
        return {id = video.id, title = video.title, boxart = boxart.id}
      end)
    end)
  end)
  assert_table_equal(result[1], {id = 5, title = "Die Hard", boxart = 52})
  assert_table_equal(result[3], {id = 105, title = "Bad Boys", boxart = 30})
end

function test.apply()
  local items = {{1,2,3}, {4,5,6}, {7,8,9}}
  local expected = {1,2,3,4,5,6,7,8,9}
  local result = fun.apply(items, fun.concat)
  assert_table_equal(result, expected)

  local names = {"bob", "Phil", "jAmes", "joNES", "sophie"}
  local expected = {"BOB", "PHIL", "JAMES", "JONES", "SOPHIE"}
  local to_upper_case = fun.apply(string.upper)
  assert_table_equal(to_upper_case(names), expected)
end

function test.best()
  local items = {45, 28, 33, 32, 11, 93, 10, 5, 78}
  local expected = 93
  local biggest = function(a, b) return a > b end
  local best = fun.best(items, biggest)
  assert_equal(best, expected)

  local closest = function(a, b) return math.abs(a) < math.abs(b) end
  local points = {-100, -56, -24, 25, 66, 932}
  best = fun.best(points, closest)
  assert_equal(best, -24)
end

function test.pluck()
  local items = {
    {
      firstname = "James",
      lastname  = "Greives",
      age = 42
    },
    {
      firstname = "Charlie",
      lastname  = "Brown",
      age = 15
    },
    {
      firstname = "Sophie",
      lastname  = "Corner",
      age = 71
    }
  }
  local expected = {42, 15, 71}
  local ages = fun.pluck(items, "age")
  assert_table_equal(ages, expected)
end

function test.shuffle()
  local items = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,foo = "bar",baz = "noop"}
  local result = fun.shuffle(items)
  assert_table_not_equal(result, items)
end

function test.chaining()
  local items = {10, "foo", 8, 5, 9, 100, "baz", -15}
  local expected = {20, 10, 200, -30}
  local filter_numbers = function(a) return type(a) == "number" end
  local factor5 = function(a) return a % 5 == 0 end
  local double = function(a) return a * 2 end
  local result = fun(items):filter(filter_numbers):filter(factor5):map(double)
  assert_table_equal(result, expected)
end

function test.bind_chaining()
  local items = {10, "foo", 8, 5, 9, 100, "baz", -15}
  local expected = {20, 10, 200, -30}

  fun.bind("filter_numbers", fun.filter, function(a) return type(a) == "number" end)
  fun.bind("filter_factor5", fun.filter, function(a) return a % 5 == 0 end)
  fun.bind("double", fun.map, function(a) return a * 2 end)

  local result = fun(items):filter_numbers():filter_factor5():double()
  assert_table_equal(result, expected)

  fun.bind("map", fun.map, function(a) error("Oops, I have overwritted the map function") end)
  fun.map(items, fun.noop)
end

function test.select_while()
  local items = {1,2,3,4,5,6,7,8,9}
  local expected = {1,2,3,4}
  local result = fun.select_while(items, fun.lt(5))
  assert_table_equal(result, expected)
end

function test.select_until()
  local items = {1,2,3,4,5,6,7,8,9}
  local expected = {1,2,3,4,5,6}
  local result = fun.select_until(items, fun.gte(7))
  assert_table_equal(result, expected)
end

function test.first()
  local items = {4,5,6,7,8,9}
  local result = fun.first(items)
  assert_equal(result, 4)
end

function test.last()
  local items = {4,5,6,7,8,9,"foo"}
  local result = fun.last(items)
  assert_equal(result, "foo")
end

function test.zip()
  local left = {1,2,3,4}
  local right = {"a", "b", "c", "d"}
  local result = fun.zip(left, right)
  assert_table_equal(result[1], {1, "a"})
  assert_table_equal(result[2], {2, "b"})
end

function test.zip_flat()
  local left = {1,2,3,4}
  local right = {"a", "b", "c", "d"}
  local result = fun.zip_flat(left, right)
  assert_table_equal(result, {1, "a", 2, "b", 3, "c", 4, "d"})
end

function test.zip_with()
  local left = {1,2,3,4}
  local right = {"a", "b", "c", "d"}
  local concat = function(a, b) return b..a end
  local result = fun.zip_with(left, right, concat)
  assert_table_equal(result, {"a1", "b2", "c3", "d4"})
end

function test.difference()
  local left = {1,2,3,4,5,6}
  local right = {2,5,6,10}
  local result = fun.difference(left, right)
  assert_table_equal(result, {1,3,4,10})
end

function test.intersect()
  local left = {1,2,3,4,5,6}
  local right = {2,5,6,10}
  local result = fun.intersect(left, right)
  assert_table_equal(result, {2,5,6})
end

function test.eq()
  local a, b, c = 5, 5, 2
  local equals5 = fun.eq(5)
  assert_equal(equals5(a), equals5(b), "equals5")

  local foo = {id = 2933}
  local bar = {id = 7099}
  local correctID = fun.eq(2933, 'id')
  assert_equal(correctID(foo), true, "correctID")
end

function test.sum()
  local items = {50, 100, 1}
  local result = fun.sum(items)
  assert_equal(result, 151)

  local names = {"one", "two", "three"}
  local charactercount = fun.sum(names, fun.len)
  assert_equal(charactercount, 11)
end

function test.map_key_value()
  local items = {a = 10, b = 5, c = 2}
  local result = fun.map_key_value(items)
  for _, pair in ipairs(result) do
    assert_equal(pair.value, items[pair.key])
  end
end

function test.complex()
  local videos = {
    {
      id = 70111470,
      title = "Die Hard",
      boxart =  "http://cdn-0.nflximg.com/images/2891/DieHard.jpg",
      uri = "http://api.netflix.com/catalog/titles/movies/70111470",
      rating = 5.0,
      bookmark = {}
    },
    {
      id = 654356453,
      title = "Bad Boys",
      boxart = "http://cdn-0.nflximg.com/images/2891/BadBoys.jpg",
      uri = "http://api.netflix.com/catalog/titles/movies/70111470",
      rating = 4.0,
      bookmark = { id = 432534, time = 65876586 }
    },
    {
      id = 65432445,
      title = "The Chamber",
      boxart = "http://cdn-0.nflximg.com/images/2891/TheChamber.jpg",
      uri = "http://api.netflix.com/catalog/titles/movies/70111470",
      rating = 5.0,
      bookmark = { id = 432534, time = 65876586 }
    }
  }
  local comments = {
    {id = 100, videoid = 65432445, comment = "Good movie, would reccomend."},
    {id = 101, videoid = 65432445, comment = "Meh."}
  }
  -- Get id and comments of all videos where ratings is 5 or more
  -- end result would be:
  -- { {id = 70111470, comments = {}}, {id = 65432445, comments = {"c1", "c2"}} }

  -- local result = fun(videos)
  -- 	:filter(function(a) return a.rating >= 5 end)
  -- 	:pluck("id")
  -- 	:map(function(id)
  -- 		local vcomments = fun.filter(comments, function(a) return a.videoid == id end):pluck("comment")
  -- 		return {['id'] = id, ['comments'] = vcomments}
  -- 	end)

  local add_comments = function(v_id)
    local v_comments = fun.filter(comments, fun.eq(v_id, 'videoid')):pluck('comment')
    return {id = v_id, comments = v_comments}
  end
  local result = fun(videos)
  :filter(fun.gte(5, 'rating'))
  :pluck('id')
  :map(add_comments)

  assert_equal(result[1].id, 70111470)
  assert_equal(result[2].id, 65432445)
  assert_table_equal(result[1].comments, {})
  assert_table_equal(result[2].comments, {"Good movie, would reccomend.", "Meh."})
end
