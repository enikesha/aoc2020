#!/usr/bin/ruby -w
require 'set'

alles = Hash.new { |h,k| h[k] = [] }
all_ings = Set.new
all_prods = []
while line=gets
  parts = line.chomp.split ' (contains '
  ings = Set.new parts[0].split
  alle = Set.new parts[1].chomp(')').split(', ')
  alle.each {|a| alles[a] << ings}
  all_ings += ings
  all_prods << ings
end

all_map = Hash.new
while alles.size > 0
  alles.select { |k,v| v.reduce(:&).size == 1 }.each do |a,v|
    ing = v.reduce(:&).to_a[0]
    all_map[a] = ing
    alles.each { |k,v2| v2.each {|p| p.delete ing } }
    alles.delete(a)
  end
end

good = all_ings - all_map.values
puts all_prods.reduce(0) { |a,p| a + (p & good).size }
puts all_map.keys.sort.collect {|a| all_map[a]}.join ','
