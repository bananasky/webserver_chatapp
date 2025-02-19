open Lwt
open Network
open Chat

let start_server addr port =
  Network.create_server_socket addr port >>= fun server_sock ->
    Printf.printf "Server started on address %s:%d\n%!" (Unix.string_of_inet_addr addr) port;
    
    let rec accept_loop () =
      Network.accept_client_connection server_sock >>= fun client_sock ->
        Printf.printf "Client connected!\n%!";
      
      Chat.start_chat client_sock >>= fun () ->
        Lwt_unix.close client_sock >>= fun () ->
          Printf.printf "Client disconnected!\n%!";
          accept_loop ()
    in
    accept_loop ()
      
let start_client addr port =
  Network.connect_to_server addr port >>= fun sock ->
    Printf.printf "Connected to server on %s:%d\n%!" (Unix.string_of_inet_addr addr) port;
    Chat.start_chat sock >>= fun () ->
      Printf.printf "Disconnected from server!\n%!";
      Lwt.return ()

let () =
  let args = Sys.argv in
  let usage_message = 
    "Usage: main.exe <mode> <addr> <port>\n\
      - mode: server OR client\n\
      - addr (optional - default: loopback address): IPv4 address\n\
      - port: port number\n" in
  if Array.length args < 3 then
    (Printf.printf "%s" usage_message; exit 1)
  else
    try
      let mode = args.(1) in
      let port = 
        if Array.length args = 4 then int_of_string args.(3) else int_of_string args.(2)
      in
      let addr =
        if Array.length args = 4 then Unix.inet_addr_of_string args.(2) else Unix.inet_addr_loopback 
      in
      match mode with
      | "server" -> (try Lwt_main.run (start_server addr port) with
        | exn -> 
          Printf.printf "Error starting server: %s\n" (Printexc.to_string exn);
          exit 1)
      | "client" -> (try Lwt_main.run (start_client addr port) with 
        | exn -> 
          Printf.printf "Error starting client: %s\n" (Printexc.to_string exn);
          exit 1)
      | _ -> 
          Printf.printf "Invalid mode. Use 'server' or 'client'.\n";
          exit 1
    with 
    | Failure msg -> 
        Printf.printf "Error: %s\n%s" msg usage_message;
        exit 1
    | Invalid_argument msg ->
        Printf.printf "Error: %s\n%s" msg usage_message;
        exit 1
    | _ -> 
        Printf.printf "%s" usage_message;
        exit 1
  
    
  

    
