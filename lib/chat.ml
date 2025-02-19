open Lwt
open Message
open Utils

module Chat = struct
  let rec recv_loop sock () =
    Lwt_unix.wait_read sock >>= fun () ->
    Message.receive_message sock >>= fun (len, time_float, is_ack, message_bytes) ->
      if len = 0 then
        Lwt_unix.close sock >>= fun () ->
        failwith "CLIENT DISCONNECT"
      else if is_ack then
        (let message = Bytes.to_string message_bytes in (* ACK pkt generally has no illegal chars, safe to_string *)
        let rtt = Unix.gettimeofday () -. time_float in
        Printf.printf "%s: RTT = %.6f seconds\n%!" message rtt;
        recv_loop sock ())
      else
        (* else decode received message to print to stdout and send ACK *)
        let message = Utils.decode_bytes_safe message_bytes in
        Printf.printf "Message Received: %s\n%!" message;
        let ack_message = "Message Received" in
        Message.send_message sock (Bytes.of_string ack_message) true >>= fun () ->
        recv_loop sock ()


  let rec send_loop sock () =
    Utils.read_line_into_bytes () >>= fun msg_bytes ->
    Lwt_unix.wait_write sock >>= fun () ->
    Message.send_message sock msg_bytes false >>= fun () ->
    send_loop sock ()

  let start_chat sock =
    Lwt.async (fun () -> recv_loop sock ());
    Lwt.async (fun () -> send_loop sock ()); 
    Lwt.join [recv_loop sock (); send_loop sock ()]
end
