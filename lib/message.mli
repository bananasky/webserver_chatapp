module Message : sig
  val send_message : Lwt_unix.file_descr -> bytes -> bool -> unit Lwt.t
  val receive_message : Lwt_unix.file_descr -> (int * float * bool * bytes) Lwt.t
end
