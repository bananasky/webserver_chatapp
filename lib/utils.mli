module Utils : sig
  val read_line_into_bytes : unit -> Bytes.t Lwt.t
  val decode_bytes_safe : bytes -> string
  val current_time_ms : unit -> string
end
