open Lwt
open Lwt_unix

module Network = struct 
  let create_server_socket addr port =
    let sock = Lwt_unix.socket PF_INET SOCK_STREAM 0 in
    let sockaddr = ADDR_INET (addr, port) in
    let _ = Lwt_unix.bind sock sockaddr in
    Lwt_unix.listen sock 1; (* Only one connection at a time *)
    Lwt.return sock

  let accept_client_connection server_sock =
    Lwt_unix.accept server_sock >>= fun (client_sock, _) ->
      Lwt.return client_sock

  let connect_to_server addr port =
    let sock = Lwt_unix.socket PF_INET SOCK_STREAM 0 in
    let sockaddr = ADDR_INET (addr, port) in
    let _ = Lwt_unix.connect sock sockaddr in
      Lwt.return sock
end
