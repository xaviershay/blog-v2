def hash_to_ostruct(x)
  case x
  when Hash
    if x.keys.all? {|y| y.is_a?(String) }
      OpenStruct.new(x.transform_values {|y| hash_to_ostruct(y) })
    else
      x.transform_values {|y| hash_to_ostruct(y) }
    end
  when Array
    x.map {|y| hash_to_ostruct(y) }
  else
    x
  end
end
