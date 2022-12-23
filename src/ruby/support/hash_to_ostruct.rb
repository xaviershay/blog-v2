def hash_to_ostruct(x)
  case x
  when Hash
    OpenStruct.new(x.transform_values {|y| hash_to_ostruct(y) })
  when Array
    x.map {|y| hash_to_ostruct(y) }
  else
    x
  end
end
