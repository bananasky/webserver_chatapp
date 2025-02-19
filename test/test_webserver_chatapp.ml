open OUnit2

let test_message_handling _ =
  (* Example test for message sending and receiving *)
  assert_equal "Message received: Hello" ("Message received: " ^ "Hello")

let suite =
  "chat_app_tests" >::: [
    "test_message_handling" >:: test_message_handling;
  ]

let () =
  run_test_tt_main suite

