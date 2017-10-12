require "pqueue"
require "pp"

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
  frequencies = groupable.group_by(&:itself).transform_values(&:size)
  build_encoding(build_tree(frequencies)).to_h
end

def build_tree(frequency_dict)
  queue = PQueue.new(frequency_dict) { |(_, freq1), (_, freq2)| freq1 < freq2 }

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
    enumerable.flat_map { |e| @encoding.fetch(e) }
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

graph = { a: %I[b d g],
          b: %I[a c d],
          c: %I[b d i],
          d: %I[a b c],
          e: %I[f h k],
          f: %I[g h e],
          g: %I[a f h],
          h: %I[g f e],
          i: %I[c l j],
          j: %I[i l k],
          k: %I[e l j],
          l: %I[i j k] }

path = random_walk(graph, 1000)

encoding = huffman_build(path)
pp encoding

huff = Huffman.new(encoding)

encoded = huff.encode(path)
puts encoded.size
#puts encoded.join("")

#puts path.join("").inspect
#puts huff.decode(encoded).join("").inspect
