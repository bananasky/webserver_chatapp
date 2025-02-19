(** The signature for chat-related logic. *)

module Chat : sig
  val start_chat : Lwt_unix.file_descr -> unit Lwt.t
end 

