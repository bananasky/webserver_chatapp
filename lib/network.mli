module Network : sig 
  val create_server_socket : Unix.inet_addr -> int -> Lwt_unix.file_descr Lwt.t
  val accept_client_connection : Lwt_unix.file_descr -> Lwt_unix.file_descr Lwt.t
  val connect_to_server : Unix.inet_addr -> int -> Lwt_unix.file_descr Lwt.t
end 
