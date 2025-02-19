open Lwt
open Message
open Utils

module Chat = struct
  let rec recv_loop sock () =
    Lwt_unix.wait_read sock >>= fun () ->
    Message.receive_message sock >>= fun (len_bytes, time_float, is_ack, message_bytes) ->
      if len_bytes = 0 then 
          Lwt.return ()
      else if is_ack then
          (* ACK pkt generally has no illegal chars, safe to_string *)
          let message = Bytes.to_string message_bytes in 
          let rtt = Unix.gettimeofday() -. time_float in
          (* is this case 'message' is "Message Received" *)
          Printf.printf "%s: RTT = %.3f ms\n%!" message (rtt *. 1000.0);
          recv_loop sock ()  
        else
          (* else decode received message to print to stdout and send ACK *)
          let message = Utils.decode_bytes_safe message_bytes in
          Printf.printf "                                    (Other): %s\n%!" message;
          
          let ack_message = "Message Received" in
          let _ = Message.send_message sock (Bytes.of_string ack_message) true in
          recv_loop sock ()


  let rec send_loop sock () =
    Utils.read_line_safe_into_bytes () >>= fun msg_bytes ->
    Lwt_unix.wait_write sock >>= fun () ->
    let _ = Message.send_message sock msg_bytes false in
    send_loop sock ()

  let start_chat sock =
    Lwt.pick [send_loop sock (); recv_loop sock ()] >>= fun _ ->
    Lwt.return ()
    
end
