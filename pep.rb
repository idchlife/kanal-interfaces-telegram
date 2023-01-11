a = nil

until a.is_a?(Numeric) do
  puts "Введите первое число:"
  input = STDIN.gets.chomp

  a = Integer(input, exception: false)
end
