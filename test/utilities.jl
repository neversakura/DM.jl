using DM, Test

test_array = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
@test convert_recursive_array(test_array) == [[1, 2, 3] [4, 5, 6] [7, 8, 9]]
test_array = [[[1,2],[3,4]],[[5,6],[7,8]],[[9,10],[10,11]]]
@test convert_recursive_array(test_array) == cat([hcat(x...) for x in test_array]..., dims=3)
test_dict = parse_string_to_num(Dict("hello"=>"2*pi"))
@test test_dict["hello"] ≈ 2π