#!/usr/bin/lua

local function parse_rule(line)
   for name, r1s, r1e, r2s, r2e in string.gmatch(line, "(.+): (%d+)-(%d+) or (%d+)-(%d+)") do
      return {name, 0+r1s, 0+r1e, 0+r2s, 0+r2e}
   end
end

local function parse_ticket(line)
   local ticket = {}
   for num in string.gmatch(line, "(%d+)") do
      table.insert(ticket, 0+num)
   end
   return ticket
end

local rules = {}
local your = {}
local nearby = {}
local mode = 1
for line in io.lines() do
   if (line ~= "")
   then
      if (line == "your ticket:")
      then
         mode = 2
      elseif (line == "nearby tickets:")
      then
         mode = 3
      else
         if (mode == 1)
         then
            table.insert(rules, parse_rule(line))
         elseif (mode == 2)
         then
            your = parse_ticket(line)
         else
            table.insert(nearby, parse_ticket(line))
         end
      end
   end
end

local function print_tickets(tickets)
   for i, ticket in ipairs(tickets) do
      print(i, table.concat(ticket, ","))
   end
end

--print("your")
--print_tickets({your})
--print("nearby")
--print_tickets(nearby)

local function check_rule(value, rule)
   return (value >= rule[2]) and (value <= rule[3]) or ((value >= rule[4]) and (value <= rule[5]))
end

local function find_invalid(ticket, rules)
   local invalid = {}
   for i,col in ipairs(ticket) do
      local is_good = false
      for j,rule in ipairs(rules) do
         if (check_rule(col, rule))
         then
            is_good = true
            break
         end
      end
      if (not is_good) then
         table.insert(invalid, col)
      end
   end

   return invalid
end


local invalid_sum = 0
local valid = {}
for i, ticket in ipairs(nearby) do
   local is_invalid = false
   for j, value in ipairs(find_invalid(ticket, rules)) do
      invalid_sum = invalid_sum + value
      is_invalid = true
   end
   if (not is_invalid)
   then
      table.insert(valid, ticket)
   end
end

print("sum of invalid entries", invalid_sum)

--print("valid nearby")
--print_tickets(valid)
table.insert(valid, your)

local function find_rule(tickets, col, rules, found)
   local matched = nil
   for i, rule in ipairs(rules) do
      if (not found[i])
      then
         local failed = false
         for j, ticket in ipairs(tickets) do
            if (not check_rule(ticket[col], rule))
            then
               failed = true
               break
            end
         end
         if (not failed)
         then
            if (matched)
            then
               return nil
            end
            matched = i
         end
      end
   end

   return matched
end

local found = {}
local found_rules = {}
repeat
   local left = false
   for col in pairs(your) do
      if (not found[col])
      then
         left = true
         rule = find_rule(valid, col, rules, found_rules)
         if (rule)
         then
            found[col] = rule
            found_rules[rule] = col
         end
      end
   end
until (not left)

local mul = 1
for i, rule in ipairs(rules) do
   value = your[found_rules[i]]
--   print(rule[1], value)
   if (string.find(rule[1], "departure"))
   then
      mul = mul * value
   end
end
print("MUL", mul)
