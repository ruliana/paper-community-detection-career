require "pqueue"
require "pp"

module Enumerable
  def frequencies
    return frequencies(&:itself) unless block_given?
    each_with_object(Hash.new(0)) do |e, rslt|
      rslt[e] += 1
    end
  end
end

def random_walk(graph, steps)
  rslt = []
  current = graph.keys.sample
  rslt << current
  (steps - 1).times.each do
    current = graph[current].sample
    rslt << current
  end
  rslt
end

def huffman_build(groupable)
  frequencies = groupable.frequencies
  build_encoding(build_tree(frequencies)).to_h
end

def build_tree(frequency_dict)
  queue = PQueue.new(frequency_dict) do |(_, freq1), (_, freq2)|
    freq1 < freq2
  end

  while queue.size > 1
    e1 = queue.pop
    e2 = queue.pop
    queue.push([[e1, e2], e1.last + e2.last])
  end

  queue.pop
end

def build_encoding(tree, prefix = [])
  element, freq = tree
  case element
  when Array
    build_encoding(element[0], prefix + [0]) +
      build_encoding(element[1], prefix + [1])
  else
    [[element, [prefix, freq]]]
  end
end

class Huffman
  def initialize(encoding)
    @encoding = encoding.transform_values(&:first)
  end

  def encode(enumerable)
    enumerable.map { |e| @encoding.fetch(e) }
  end

  def decode(enumerable)
    decoder = @encoding.invert
    key = []
    rslt = []
    while enumerable.any?
      first, *enumerable = enumerable
      key << first
      value = decoder[key]
      next if value.nil?
      key = []
      rslt << value
    end
    rslt
  end
end

# graph = { a: %I[b c l],
#           b: %I[a c d],
#           c: %I[a b d],
#           d: %I[b c e],
#           e: %I[f g d],
#           f: %I[g h e],
#           g: %I[f h e],
#           h: %I[g f i],
#           i: %I[k j h],
#           j: %I[i l k],
#           k: %I[i l j],
#           l: %I[k j a] }

# path = random_walk(graph, 40 * 20)

# encoding = huffman_build(path)
# pp encoding

# huff = Huffman.new(encoding)

# encoded = huff.encode(path)
# printf "size: %d\n", encoded.size
# puts encoded.join("")

# puts path.map(&:upcase).each_slice(40).map { |es| es.join("") }.join("\n")
# freq = path.each_cons(2).frequencies.sort_by { |_, v| v }
# pp freq
# puts huff.decode(encoded).join("").inspect

sample_walk = <<~WALK.delete("\n").chars
  KLKJKJIKJLJKJKLKLKIJIJKIKJLJIJKIKJKJIHFH
  IKIJKJIHIJLALKIKIKIKJKJIJKLALJKJIKIHIHFH
  IKIJIHFGHFGEFHIKIHIJKLABCBABDBCACBDBCBCA
  LJKIJIJLACDEGHIKJLJLKJIHGHGFGEDEDCDCBDBD
  BCABCDEGEDEFGFHGFEFHFGHIKLABABCBDBDCACDC
  BDEFHGEFHFGEFGFEDCBDBDBCACBCABCABCBCALJK
  LABALABCABACBCDCDBABABCDBCDBALJKLKLALKIH
  IHFGEDBCBDCDEGEDCDBABABACDCABCBCACBCDBCD
  BACBCBCBDCDCBCBABABDCACBCDBALKJKJKLKIHGF
  EGFHGHGFHFEGEDCBABALACDBCBCDEFHFEDBALKIK
  LJLJLALJLABABDCABDCBABALJIHIHGHFEFEDEGHI
  JIHGFGEDEGHIHIHGHIJIHIJLACALKLJLKIKIHIJI
  JLKJLKIKLKJIHIHGFGEFGHGEFEFHIHGFEGEDCABA
  LJLKJLJIHGHIHFHGFHFEFHFGFGEGEGEGEDCBCBAB
  DCACBCDCALKLACBDCDBDEGFEGHFHFGEGEGEGEGED
  BACBCALKIHIHIJLKIKIKLJIKLKLKJLKLKJKIJKLA
  LKIKJIJLALKJLACACBALKLKJLJIHIHFHFEGHGFHI
  HGHFHIHGFHIKLKIJLJKIHIHIKIJKJIJIJIJIHIJK
  JIJIHFGHIHIHIJLKJKIHGHGHGEGHIKJKLJLJLJKJ
  LALJLJKJKIHFEGHFHGEFEGHFGFHIHFEDEGHFGHGE
WALK

encoding = huffman_build(sample_walk)
pp encoding

huff = Huffman.new(encoding)

encoded = huff.encode(sample_walk).flatten
puts encoded.each_slice(40).map { |es| es.join("") }.join("\n")
printf "size: %d\n", encoded.size

partition = sample_walk.chunk { |e| ["ABCD", "EFGH", "IJKL"]
                                .find_index { |g| g.include?(e)} }
            .group_by { |e| e[0] }
            .transform_values { |e| e.map { |g| g[1] } }

partition.values.each do |vs|
  sample = vs.map { |e| e + ["X"] }.reduce([], &:+)
  puts sample.inspect
  encoding = huffman_build(sample)
  pp encoding
end

new_coding = { "A" => "00",
               "B" => "01",
               "C" => "10",
               "D" => "110",
               "E" => "00",
               "F" => "01",
               "G" => "10",
               "H" => "110",
               "I" => "00",
               "J" => "01",
               "K" => "10",
               "L" => "110",
               "AL" => "1110",
               "LA" => "11111",
               "DE" => "11110",
               "ED" => "11111",
               "HI" => "1110",
               "IH" => "11110"}

reg = Regexp.new(new_coding.keys.reverse.join("|"))
rslt = sample_walk.join("").gsub(reg) { |match| new_coding.fetch(match) }
puts rslt.inspect
printf "size: %d\n", rslt.size

rev = Regexp.new(new_coding.values.sort_by { |e| e.size }.reverse.join("|"))
rev_coding = new_coding.invert
rslt = sample_walk.join("").gsub(rev) { |match| rev_coding.fetch(match) }
puts rslt.inspect
