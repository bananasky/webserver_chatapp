open Lwt
open Network
open Chat

(* Start server on a given port *)
let start_server addr port =
  Network.create_server_socket addr port >>= fun server_sock ->
    Printf.printf "Server started on address %s port %d\n%!" (Unix.string_of_inet_addr addr) port;
    
    let rec accept_loop () =
      Network.accept_client_connection server_sock >>= fun client_sock ->
      Printf.printf "Client connected!\n%!";
      Chat.start_chat client_sock >>= fun () ->
    
      (* Ensure the next client is accepted only after this one disconnects *)
      Lwt.catch
        (fun () -> 
          Chat.start_chat client_sock >>= fun () ->
          Printf.printf "Client disconnected!\n%!";
          accept_loop ()  (* Accept next client only after this one finishes *)
        )
        (fun exn ->
          Lwt_io.printlf "Client error CAUGHT: %s\n%!" (Printexc.to_string exn) >>= fun () ->
          Lwt_io.flush Lwt_io.stdout >>= fun () ->  (* Flush the output buffer *)
          accept_loop ()  (* Ensure the server keeps accepting new clients *)
        )
    in
    
    accept_loop ()  (* Start the loop *)
    
  

(* Start client and connect to server on the same port *)
  let start_client addr port =
    Network.connect_to_server addr port >>= fun sock ->
    Printf.printf "Connected to server on %s port %d\n%!" (Unix.string_of_inet_addr addr) port;
    Chat.start_chat sock >>= fun () ->
      Printf.printf "Disconnected from server!\n%!";
      Lwt.return ()


  let get_address addr_str =
    try
      Unix.inet_addr_of_string addr_str 
    with
    | _ -> Unix.inet_addr_loopback  (* If it fails, use default loopback address *)
  
  let () =
    (* Parse command-line arguments *)
    let args = Sys.argv in
    if Array.length args < 3 then
      Printf.printf "Usage:\n  %s server <port>\n  %s client <port>\n" args.(0) args.(0)
    else
      let addr =
        if Array.length args > 3 then
          get_address args.(3)
        else
          Unix.inet_addr_loopback
      in
      let port = int_of_string args.(2) in
      match args.(1) with
      | "server" -> Lwt_main.run (start_server addr port)
      | "client" -> Lwt_main.run (start_client addr port)
      | _ -> Printf.printf "Invalid mode. Use 'server' or 'client'.\n"
    
