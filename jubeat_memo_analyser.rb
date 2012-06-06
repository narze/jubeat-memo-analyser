#!/usr/bin/env ruby
# encoding: utf-8
# Converts jubeat memo to jubeat analyser format

input = nil, output = nil
blank = '□'
one = '①'
front = []
back = []
blankBack = '－'
numberSymbols = ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩', '⑪', '⑫', '⑬', '⑭', '⑮', '⑯', '⑰', '⑱', '⑲', '⑳']
jubeatAnalyserSymbols = ['@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S']
prefix = '‡'
space = " "
groups = []
group = []
out = []

ARGV.each_with_index do |item, i|
  input = item if i == 0
  output = item if i == 1
end

File.foreach(input, :encoding => "UTF-8") do |line|
  if /^\d+$/.match(line)
    groups.push group
    group = Array.new
    # puts "number #{line}"
  elsif /^.{4}\s+.+$/.match(line)
    group.push line
    # puts line
  end
end

#push last group if group is not empty
groups.push group unless group.empty?

#flush first element
groups.shift

# puts groups

groups.each_with_index do |a_group, index|
  front = []
  back = []
  a_group.each do |line|
    front.concat line[0..3].split('')
    backside = line[/\|(.+)\|/, 1]
    back.concat(backside.split('')) unless backside.nil?
  end

  #replace with jubeat analyser symbols
  back.each_with_index do |item, i|
    if item != blankBack
      front.map! do |x|
        x == item ? "#{prefix}#{jubeatAnalyserSymbols[i]}" : x
      end
    end
  end

  #fill space
  front.map! do |x|
    x == blank ? "#{prefix}#{space}" : x
  end

  out.push "---------- #{index+1}"
  while shifted = front.shift(4)
    break if shifted.empty?
    out.push shifted.join
  end

end

f = File.new(output, 'w')
out.each do |line|
  f.write("#{line}\n");
end
f.close