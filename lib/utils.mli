module Utils : sig
  val read_line_safe_into_bytes : unit -> Bytes.t Lwt.t
  val decode_bytes_safe : bytes -> string
  val time_float_to_bytes : float -> bytes
  val bytes_to_time_float : bytes -> float
end
