#!/usr/bin/env ruby
# encoding: utf-8
# Converts jubeat memo to jubeat analyser format

input = ""
memoBlank = '□'
memoBackBlank = '－'
analyserSymbols = ['@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
analyserSymbolPrefix = '‡'
space = " "
groups = Array.new
group = Array.new
out = Array.new

ARGV.each_with_index do |item, i|
  input = item if i == 0
end

abort("ERROR : No input specified") if input.empty?
abort("ERROR : Input not found") if !File.exists?(input)

File.foreach(input, :encoding => "UTF-8") do |line|
  if /^\d+$/.match(line)
    groups.push group
    group = Array.new
  elsif /^.{4}\s+/.match(line)
    group.push line
  end
end

# push last group if group is not empty
groups.push group unless group.empty?

# flush first empty line
groups.shift

# convert into jubeat analyser format
groups.each_with_index do |a_group, index|
  front = Array.new
  back = Array.new
  a_group.each do |line|
    front.concat line[0..3].split('')
    backside = line[/\|(.+)\|/, 1]
    back.concat(backside.split('')) unless backside.nil?
  end

  # replace with jubeat analyser symbols
  back.each_with_index do |item, i|
    if item != memoBackBlank
      front.map! do |x|
        x == item ? "#{analyserSymbolPrefix}#{analyserSymbols[i]}" : x
      end
    end
  end

  #fill space
  front.map! do |x|
    x == memoBlank ? "#{analyserSymbolPrefix}#{space}" : x
  end

  out.push "---------- #{index+1}"
  while shifted = front.shift(4)
    break if shifted.empty?
    out.push shifted.join
  end
end

# write result
# Set encoding to windows 1252
# (jubeat analyser cannot read utf-8)
output = File.basename(input, ".*") + "_jma.txt"
f = File.new(output, 'w:Windows-1252')
out.each do |line|
  f.write("#{line}\n");
end
f.close