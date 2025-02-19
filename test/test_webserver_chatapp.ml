open OUnit2
open Utils

let test_time_conversion _ =
  let time = Unix.gettimeofday () in
  let decoded_time = Utils.bytes_to_time_float (Utils.time_float_to_bytes time) in
  assert_equal time decoded_time
  
  let test_decode_bytes_safe _ =
    let input_safe = Bytes.of_string "Hello, world!" in
    let input_unsafe_1 = Bytes.create 1 in
    Bytes.set input_unsafe_1 0 '\xC1';
    let input_unsafe_2 = Bytes.create 1 in
    Bytes.set input_unsafe_2 0 '\xd0';

    let decoded_safe = Utils.decode_bytes_safe input_safe in
    let expected_safe = "Hello, world!" in
    assert_equal expected_safe decoded_safe;
  
    let expected_unsafe = "�" in
    let decoded_unsafe_1 = Utils.decode_bytes_safe input_unsafe_1 in
    assert_equal expected_unsafe decoded_unsafe_1;

    let decoded_unsafe_2 = Utils.decode_bytes_safe input_unsafe_2 in
    assert_equal expected_unsafe decoded_unsafe_2

let suite =
"Utils tests" >::: [
  "test_time_conversion" >:: test_time_conversion;
  "test_decode_bytes_safe" >:: test_decode_bytes_safe;
]

let () =
  run_test_tt_main suite
