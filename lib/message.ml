open Utils

module Message = struct
  (* Send a message over the given socket, 
  Custom format 4 bytes (msg_len) + 20 bytes (time_str) 1 byte (pkt_type) header prepended to message_bytes *)
  let send_message sock message_bytes isAckPkt =
    (* Compute the message length *)
    let message_len = Bytes.length message_bytes in
    let len_bytes = Bytes.create 4 in
    let time_bytes = Bytes.of_string (Utils.current_time_ms ()) in
    Bytes.set_int32_be len_bytes 0 (Int32.of_int message_len);
    
    (* 1 for ACK pkt, 0 for message pkt *)
    let pkt_type = if isAckPkt then '1' else '0' in
    
    let full_message = Bytes.concat Bytes.empty [len_bytes; time_bytes; Bytes.make 1 pkt_type; message_bytes] in
    
    let _ = Lwt_unix.write sock full_message 0 (Bytes.length full_message) in
    Lwt.return ()

  let receive_message sock =
    
    let len_bytes = Bytes.create 4 in
    let _ = Lwt_unix.read sock len_bytes 0 4 in
    let message_len = Int32.to_int (Bytes.get_int32_be len_bytes 0) in
    
    if message_len = 0 then
      (* Client disconnected *)
      Lwt.return (0, 0.0, false, Bytes.create 0)  (* Returning default values *)
    else (
    let time_bytes = Bytes.create 20 in
    let _ = Lwt_unix.read sock time_bytes 0 20 in
    let time_float = float_of_string (String.of_bytes time_bytes) in
    
    let type_byte = Bytes.create 1 in
    let _ = Lwt_unix.read sock type_byte 0 1 in
    let is_ack_pkt = Bytes.get type_byte 0 = '1' in
    
    let raw_message = Bytes.create message_len in
    let _ = Lwt_unix.read sock raw_message 0 message_len in
    
    Lwt.return (message_len, time_float, is_ack_pkt, raw_message))
end

