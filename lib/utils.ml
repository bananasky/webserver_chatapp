open Lwt

module Utils = struct  
  let time_float_to_bytes time =
    (* example time is 1739959758.78 *)
    let res = Bytes.create 8 in
    let time_int64 = Int64.bits_of_float time in
    for i = 0 to 7 do
      Bytes.set res i (Char.chr (Int64.to_int (Int64.logand (Int64.shift_right_logical time_int64 (i * 8)) 0xFFL)))
    done;
    res
  
  let bytes_to_time_float bytes =
    let int64_repr = ref 0L in
    for i = 0 to 7 do
      let byte_val = Int64.of_int (Char.code (Bytes.get bytes i)) in
      int64_repr := Int64.logor !int64_repr (Int64.shift_left byte_val (i * 8))
    done;
    Int64.float_of_bits !int64_repr

  let read_line_safe_into_bytes () =
    let buffer = Buffer.create 256 in
    let rec read_loop () =
      let b = Bytes.create 1 in
      Lwt_io.read_into Lwt_io.stdin b 0 1 >>= fun len ->
      match len with
      | 0 -> Lwt.return (Buffer.to_bytes buffer)  (* end of input *)
      | _ -> 
        Buffer.add_bytes buffer b;
        if Bytes.get b 0 = '\n' then
          Lwt.return (Buffer.to_bytes buffer)
        else
          read_loop ()
    in
    read_loop ()
        
    (* messages are sent and received in bytes, decode only used for printing to stdout *)
    let decode_bytes_safe bytes_data =
      let buf = Buffer.create (Bytes.length bytes_data) in
      let src = `String (Bytes.to_string bytes_data) in
      let d = Uutf.decoder src in
      let rec loop () =
        match (Uutf.decode d) with
        | `Uchar u -> Buffer.add_utf_8_uchar buf u; loop () 
        | `End -> Buffer.contents buf  
        | `Malformed _ -> Buffer.add_utf_8_uchar buf Uchar.rep; loop ()
        | `Await -> assert false 
      in
      loop ()
end

    
  

    
