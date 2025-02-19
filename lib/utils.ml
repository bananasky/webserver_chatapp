open Lwt

module Utils = struct  
  let current_time_ms () =
    let time_sec = Unix.gettimeofday () in
    Printf.sprintf "%20.3f" time_sec

  let read_line_into_bytes () =
    let buffer = Buffer.create 256 in
    let rec read_loop () =
      let b = Bytes.create 1 in
      Lwt_io.read_into Lwt_io.stdin b 0 1 >>= fun len ->
      match len with
      | 0 -> Lwt.return (Buffer.to_bytes buffer)  (* End of input *)
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
        | `Malformed _ -> Buffer.add_utf_8_uchar buf Uchar.rep; loop ()  (* Replace invalid bytes with U+FFFD *)
        | `Await -> assert false 
      in
      loop ()
end

    
  

    
