(** [a @@> b] concatenetes lists [a] and [b]. *)
let (@@>) = (@)

(** [x @:> b] prepends element [x] to the list [b]. *)
let (@:>) hd tl = hd :: tl

(** [o @?> b] prepends option [o] to the list [b], if it's some. *)
let (@?>) opt tail =
  match opt with None -> tail | Some x -> x :: tail

(** [a |?> f] is equivalent to [BatOption.map f a]. *)
let (|?>) opt f =
  match opt with None -> None | Some x -> Some (f x)

let identity a = a

let string_of_float = Printf.sprintf "%g"

let to_pcdata to_string a =
  Xml.PCData (to_string a)

let to_elem to_string tag a =
  Xml.Element (tag, [], [to_pcdata to_string a])

let to_nested_elem to_string ptag tag a =
  Xml.Element (ptag, [], [to_elem to_string tag a])

module Position =
  struct
    type t = {
        latitude : float;
        longitude : float;
      }

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
  end

module Time_zone =
  struct
    type t = {
        hours : int;            (* [-12, 14] *)
        minutes : int;          (* [0, 59] *)
      }

    let to_string = function
      | { hours = 0; minutes = 0 } -> "Z"
      | { hours; minutes = 0 } -> Printf.sprintf "%+02d" hours
      | { hours; minutes } -> Printf.sprintf "%+02d:%02d" hours minutes

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

    let now () =
      of_tm Time_zone.utc (Unix.gmtime (Unix.time ()))
  end

module Sensor_state =
  struct
    type t = Present | Absent

    let to_string = function
        Present -> "Present"
      | Absent -> "Absent"
  end

module Intensity =
  struct
    type t = Active | Resting

    let to_string = function
        Active -> "Active"
      | Resting -> "Resting"
  end

module Trigger_method =
  struct
    type t = Manual | Distance | Location | Time | Heart_rate

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
        sensor_state : Sensor_state.t;
      }

    let to_elem tag { time; position; altitude; distance;
                      heart_rate; cadence; sensor_state } =
      Xml.Element (tag, [],
                   (time |> to_elem Timestamp.to_string "Time")
                   @:> (position |?> Position.to_elem "Position")
                   @?> (altitude |?> to_elem string_of_float "AltitudeMeters")
                   @?> (distance |?> to_elem string_of_float "DistanceMeters")
                   @?> (heart_rate |?> to_nested_elem string_of_int "HeartRateBpm" "Value")
                   @?> (cadence |?> to_elem string_of_int "Cadence")
                   @?> (sensor_state |> to_elem Sensor_state.to_string "SensorState")
                   @:> []
                  )
  end

module Track =
  struct
    type t = {
        points : Track_point.t list;
      }

    let to_elem tag { points } =
      Xml.Element (tag, [], List.map (Track_point.to_elem "Trackpoint") points)
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

    let to_elem tag { start_time; total_time; distance; maximum_speed;
                      calories; average_heart_rate; maximum_heart_rate;
                      intensity; cadence; trigger_method; tracks; notes } =
      Xml.Element (tag,
                   ["StartTime", Timestamp.to_string start_time],
                   (total_time |> to_elem string_of_float "TotalTimeSeconds")
                   @:> (distance |> to_elem string_of_float "DistanceMeters")
                   @:> (maximum_speed |?> to_elem string_of_float "MaximumSpeed")
                   @?> (calories |> to_elem string_of_int "Calories")
                   @:> (average_heart_rate |?> to_nested_elem string_of_int "AverageHeartRateBpm" "Value")
                   @?> (maximum_heart_rate |?> to_nested_elem string_of_int "MaximumHeartRateBpm" "Value")
                   @?> (intensity |> to_elem Intensity.to_string "Intensity")
                   @:> (cadence |?> to_elem string_of_int "Cadence")
                   @?> (trigger_method |> to_elem Trigger_method.to_string "TriggerMethod")
                   @:> (tracks |> List.map (Track.to_elem "Track"))
                   @@> (notes |?> to_elem identity "Notes")
                   @?> []
                  )
  end

module Activity =
  struct
    type t = {
        id : Timestamp.t;
        sport : Sport.t;
        laps : Activity_lap.t list;
        notes : string option;
      }

    let to_elem { id; sport; laps; notes } =
      Xml.Element ("Activity",
                   ["Sport", Sport.to_string sport],
                   (id |> to_elem Timestamp.to_string "Id")
                   @:> (laps |> List.map (Activity_lap.to_elem "Lap"))
                   @@> (notes |?> to_elem identity "Notes")
                   @?> []
                   )
  end

type t = {
    (* TODO: Folders, workouts, etc. *)
    activities : Activity.t list;
  }

let xmlns = "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"

let of_xml xml =
  (* TODO *)
  { activities = [] }

let to_xml { activities } =
  Xml.Element ("TrainingCenterDatabase",
               ["xmlns", xmlns],
               [Xml.Element ("Activities",
                             [],
                             List.map Activity.to_elem activities)])

let of_string str = Xml.parse_string str |> of_xml

let to_string tcx = to_xml tcx |> Xml.to_string_fmt
