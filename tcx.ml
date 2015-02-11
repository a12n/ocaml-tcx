(** [a @@> b] concatenetes lists [a] and [b]. *)
let (@@>) = (@)

(** [a @> l] prepends element [a] to the list [l]. *)
let (@>) a l = a :: l

(** [opt @?> l] prepends option [opt] to the list [l], if it's some. *)
let (@?>) opt l =
  match opt with None -> l | Some a -> a :: l

(** [a |?> f] is equivalent to [BatOption.map f a]. *)
let (|?>) opt f =
  match opt with None -> None | Some a -> Some (f a)

let identity a = a

let string_of_float = Printf.sprintf "%g"

let to_pcdata to_string a =
  Xml.PCData (to_string a)

let to_elem to_string tag a =
  Xml.Element (tag, [], [to_pcdata to_string a])

let to_nested_elem to_string ptag tag a =
  Xml.Element (ptag, [], [to_elem to_string tag a])

let is_elem tag = function
    Xml.Element (t, _, _) -> t = tag
  | Xml.PCData _ -> false

let attrib elem name =
  try Some (Xml.attrib elem name) with Xml.No_attribute _ -> None

let child_elem elem tag =
  try Some (List.find (is_elem tag) (Xml.children elem)) with Not_found -> None

let children elem tag =
  List.filter (is_elem tag) (Xml.children elem)

let child_pcdata elem tag =
  child_elem elem tag |?> (fun e -> Xml.children e |> List.hd |> Xml.pcdata)

let nested_child_pcdata elem ptag tag =
  match child_elem elem ptag with
    Some e -> child_pcdata e tag
  | None -> None

let default b = function
    Some a -> a
  | None -> b

let require = function
    Some a -> a
  | None -> failwith "required attribute/element missing"

module Position =
  struct
    type t = {
        latitude : float;
        longitude : float;
      }

    let of_elem elem =
      { latitude = child_pcdata elem "LatitudeDegrees" |> require |> float_of_string;
        longitude = child_pcdata elem "LongitudeDegrees" |> require |> float_of_string }

    let to_elem tag { latitude; longitude } =
      Xml.Element (tag, [],
                   [latitude |> to_elem string_of_float "LatitudeDegrees";
                    longitude |> to_elem string_of_float "LongitudeDegrees"])
  end

module Date =
  struct
    type t = {
        year : int;
        month : int;
        day : int;
      }

    let of_tm { Unix.tm_year; tm_mon; tm_mday; _ } =
      { year = tm_year + 1900; month = tm_mon + 1; day = tm_mday }

    let to_string { year; month; day } =
      Printf.sprintf "%04d-%02d-%02d" year month day

    let epoch = { year = 1970; month = 1; day = 1 }
  end

module Time =
  struct
    type t = {
        hour : int;
        minute : int;
        second : int;
      }

    let of_tm { Unix.tm_hour; tm_min; tm_sec; _ } =
      { hour = tm_hour; minute = tm_min; second = tm_sec }

    let to_string { hour; minute; second } =
      Printf.sprintf "%02d:%02d:%02d" hour minute second

    let midnight = { hour = 0; minute = 0; second = 0 }
  end

module Time_zone =
  struct
    type t = {
        hours : int;            (* [-12, 14] *)
        minutes : int;          (* [0, 59] *)
      }

    let to_string = function
      | { hours = 0; minutes = 0 } -> "Z"
      | { hours; minutes } -> Printf.sprintf "%+03d:%02d" hours minutes

    let utc = { hours = 0; minutes = 0 }
  end

module Timestamp =
  struct
    type t = {
        date : Date.t;
        time : Time.t;
        time_zone : Time_zone.t;
      }

    let of_tm time_zone tm =
      { date = Date.of_tm tm; time = Time.of_tm tm; time_zone }

    let to_string { date; time; time_zone } =
      (Date.to_string date) ^ "T" ^ (Time.to_string time) ^
        (Time_zone.to_string time_zone)

    let epoch =
      { date = Date.epoch; time = Time.midnight; time_zone = Time_zone.utc }

    let now () =
      of_tm Time_zone.utc (Unix.gmtime (Unix.time ()))

    let of_string _str =
      (* TODO *)
      epoch
  end

module Sensor_state =
  struct
    type t = Present | Absent

    let of_string = function
        "Present" -> Present
      | "Absent" -> Absent
      | _ -> raise (Invalid_argument "Tcx.Sensor_state.of_string")

    let to_string = function
        Present -> "Present"
      | Absent -> "Absent"
  end

module Intensity =
  struct
    type t = Active | Resting

    let of_string = function
        "Active" -> Active
      | "Resting" -> Resting
      | _ -> raise (Invalid_argument "Tcx.Intensity.of_string")

    let to_string = function
        Active -> "Active"
      | Resting -> "Resting"
  end

module Trigger_method =
  struct
    type t = Manual | Distance | Location | Time | Heart_rate

    let of_string = function
        "Manual" -> Manual
      | "Distance" -> Distance
      | "Location" -> Location
      | "Time" -> Time
      | "HeartRate" -> Heart_rate
      | _ -> raise (Invalid_argument "Tcx.Trigger_method.of_string")

    let to_string = function
        Manual -> "Manual"
      | Distance -> "Distance"
      | Location -> "Location"
      | Time -> "Time"
      | Heart_rate -> "HeartRate"
  end

module Sport =
  struct
    type t = Running | Biking | Other

    let of_string = function
        "Running" -> Running
      | "Biking" -> Biking
      | _ -> Other

    let to_string = function
        Running -> "Running"
      | Biking -> "Biking"
      | Other -> "Other"
  end

module Track_point =
  struct
    type t = {
        time : Timestamp.t;
        position : Position.t option;
        altitude : float option;
        distance : float option;
        heart_rate : int option;
        cadence : int option;
        sensor_state : Sensor_state.t option;
      }

    let of_elem elem =
      { time = child_pcdata elem "Time" |> require |> Timestamp.of_string;
        position = child_elem elem "Position" |?> Position.of_elem;
        altitude = child_pcdata elem "AltitudeMeters" |?> float_of_string;
        distance = child_pcdata elem "DistanceMeters" |?> float_of_string;
        heart_rate = nested_child_pcdata elem "HeartRateBpm" "Value" |?> int_of_string;
        cadence = child_pcdata elem "Cadence" |?> int_of_string;
        sensor_state = child_pcdata elem "SensorState" |?> Sensor_state.of_string; }

    let to_elem tag { time; position; altitude; distance;
                      heart_rate; cadence; sensor_state } =
      Xml.Element (tag, [],
                   (time |> to_elem Timestamp.to_string "Time")
                   @> (position |?> Position.to_elem "Position")
                   @?> (altitude |?> to_elem string_of_float "AltitudeMeters")
                   @?> (distance |?> to_elem string_of_float "DistanceMeters")
                   @?> (heart_rate |?> to_nested_elem string_of_int "HeartRateBpm" "Value")
                   @?> (cadence |?> to_elem string_of_int "Cadence")
                   @?> (sensor_state |?> to_elem Sensor_state.to_string "SensorState")
                   @?> []
                  )

    let sample =
      { time = Timestamp.epoch;
        position = None;
        altitude = None;
        distance = None;
        heart_rate = None;
        cadence = None;
        sensor_state = None }
  end

module Track =
  struct
    type t = {
        points : Track_point.t List_ext.Non_empty.t;
      }

    let of_elem elem =
      { points = children elem "Trackpoint" |> List.map Track_point.of_elem |>
                   List_ext.Non_empty.of_list }

    let to_elem tag { points } =
      Xml.Element (tag, [],
                   points |> List_ext.Non_empty.to_list |> List.map (Track_point.to_elem "Trackpoint"))
  end

module Activity_lap =
  struct
    type t = {
        start_time : Timestamp.t;
        total_time : float;     (* s *)
        distance : float;       (* m *)
        maximum_speed : float option; (* m/s *)
        calories : int;               (* kcal *)
        average_heart_rate : int option; (* bpm *)
        maximum_heart_rate : int option; (* bpm *)
        intensity : Intensity.t;
        cadence : int option;   (* rpm *)
        trigger_method : Trigger_method.t;
        tracks : Track.t list;
        notes : string option;
      }

    let of_elem elem =
      { start_time = attrib elem "StartTime" |> require |> Timestamp.of_string;
        total_time = child_pcdata elem "TotalTimeSeconds" |> require |> float_of_string;
        distance = child_pcdata elem "DistanceMeters" |> require |> float_of_string;
        maximum_speed = child_pcdata elem "MaximumSpeed" |?> float_of_string;
        calories = child_pcdata elem "Calories" |> require |> int_of_string;
        average_heart_rate = nested_child_pcdata elem "AverageHeartRateBpm" "Value" |?> int_of_string;
        maximum_heart_rate = nested_child_pcdata elem "MaximumHeartRateBpm" "Value" |?> int_of_string;
        intensity = child_pcdata elem "Intensity" |> require |> Intensity.of_string;
        cadence = child_pcdata elem "Cadence" |?> int_of_string;
        trigger_method = child_pcdata elem "TriggerMethod" |> require |> Trigger_method.of_string;
        tracks = children elem "Track" |> List.map Track.of_elem;
        notes = child_pcdata elem "Notes" }

    let to_elem tag { start_time; total_time; distance; maximum_speed;
                      calories; average_heart_rate; maximum_heart_rate;
                      intensity; cadence; trigger_method; tracks; notes } =
      Xml.Element (tag,
                   ["StartTime", Timestamp.to_string start_time],
                   (total_time |> to_elem string_of_float "TotalTimeSeconds")
                   @> (distance |> to_elem string_of_float "DistanceMeters")
                   @> (maximum_speed |?> to_elem string_of_float "MaximumSpeed")
                   @?> (calories |> to_elem string_of_int "Calories")
                   @> (average_heart_rate |?> to_nested_elem string_of_int "AverageHeartRateBpm" "Value")
                   @?> (maximum_heart_rate |?> to_nested_elem string_of_int "MaximumHeartRateBpm" "Value")
                   @?> (intensity |> to_elem Intensity.to_string "Intensity")
                   @> (cadence |?> to_elem string_of_int "Cadence")
                   @?> (trigger_method |> to_elem Trigger_method.to_string "TriggerMethod")
                   @> (tracks |> List.map (Track.to_elem "Track"))
                   @@> (notes |?> to_elem identity "Notes")
                   @?> []
                  )

    let sample =
      { start_time = Timestamp.epoch;
        total_time = 0.0;
        distance = 0.0;
        maximum_speed = None;
        calories = 0;
        average_heart_rate = None;
        maximum_heart_rate = None;
        intensity = Intensity.Active;
        cadence = None;
        trigger_method = Trigger_method.Manual;
        tracks = [];
        notes = None }
  end

module Activity =
  struct
    type t = {
        id : Timestamp.t;
        sport : Sport.t;
        laps : Activity_lap.t List_ext.Non_empty.t;
        notes : string option;
      }

    let of_elem elem =
      { id = child_pcdata elem "Id" |> require |> Timestamp.of_string;
        sport = attrib elem "Sport" |> require |> Sport.of_string;
        laps = children elem "Lap" |> List.map Activity_lap.of_elem |> List_ext.Non_empty.of_list;
        notes = child_pcdata elem "Notes" }

    let to_elem tag { id; sport; laps; notes } =
      Xml.Element (tag,
                   ["Sport", Sport.to_string sport],
                   (id |> to_elem Timestamp.to_string "Id")
                   @> (laps |> List_ext.Non_empty.to_list |> List.map (Activity_lap.to_elem "Lap"))
                   @@> (notes |?> to_elem identity "Notes")
                   @?> []
                  )

    let sample =
      { id = Timestamp.epoch;
        sport = Sport.Other;
        laps = Activity_lap.sample, [];
        notes = None }
  end

type t = {
    (* TODO: Folders, workouts, etc. *)
    activities : Activity.t list;
  }

let of_xml xml =
  { activities =
      match child_elem xml "Activities" with
        Some e -> children e "Activity" |> List.map Activity.of_elem
      | None -> [] }

let to_xml { activities } =
  let xmlns = "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2" in
  Xml.Element ("TrainingCenterDatabase",
               ["xmlns", xmlns],
               [Xml.Element ("Activities",
                             [],
                             activities |> List.map (Activity.to_elem "Activity"))])

let of_string str = Xml.parse_string str |> of_xml

let to_string tcx =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" ^
    (to_xml tcx |> Xml.to_string_fmt)

let parse_file path = Xml.parse_file path |> of_xml

let write_file tcx path =
  let str = to_string tcx in
  let chan = open_out path in
  output_string chan str;
  close_out chan
