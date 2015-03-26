let error msg =
  prerr_string "apply_time_lag: ";
  prerr_endline msg;
  exit 1

let shift_tcx_timestamp ts time_lag =
  Tcx.Timestamp.(of_unix_time (to_unix_time ts +. time_lag))

let shift_tcx tcx time_lag =
  let transform = function
    | `Activity a ->
       `Activity {a with Tcx.Activity.id =
                           shift_tcx_timestamp a.Tcx.Activity.id time_lag}
    | `Activity_lap l ->
       `Activity_lap {l with Tcx.Activity_lap.start_time =
                               shift_tcx_timestamp l.Tcx.Activity_lap.start_time time_lag}
    | `Track_point p ->
       `Track_point {p with Tcx.Track_point.time =
                              shift_tcx_timestamp p.Tcx.Track_point.time time_lag}
    | x -> x in
  Tcx.map transform tcx

let parse_args () =
  let in_path = ref "in.tcx" in
  let out_path = ref "out.tcx" in
  let time_lag = ref 0.0 in
  Arg.parse [ "-in", Arg.Set_string in_path,
              Printf.sprintf "Path to input TCX file (default \"%s\")" !in_path;
              "-out", Arg.Set_string out_path,
              Printf.sprintf "Path to output TCX file (default \"%s\")" !out_path;
              "-lag", Arg.Set_float time_lag,
              Printf.sprintf "Time lag in seconds to apply (default %.3f)" !time_lag ]
            (fun _anon -> ())
            "Apply time lag to data in TCX file";
  !in_path, !out_path, !time_lag

let () =
  let in_path, out_path, time_lag = parse_args () in
  let in_tcx =
    try Tcx.parse_file in_path
    with _ -> error ("couldn't load file \"" ^ in_path ^ "\"") in
  let out_tcx = shift_tcx in_tcx time_lag in
  try Tcx.format_file out_tcx out_path
  with _ -> error ("couldn't save file \"" ^ out_path ^ "\"")
