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
                   [to_elem string_of_float "LatitudeDegrees" latitude;
                    to_elem string_of_float "LongitudeDegrees" longitude])
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
  end

module Track =
  struct
    type t = {
        points : Track_point.t list;
      }
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
  end

module Activity =
  struct
    type t = {
        id : Timestamp.t;
        sport : Sport.t;
        laps : Activity_lap.t list;
        notes : string option;
      }
  end

type t = {
    (* TODO: Folders, workouts, etc. *)
    activities : Activity.t list;
  }

let xmlns = "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"

let of_xml xml =
  (* TODO *)
  { activities = [] }

let to_xml tcx =
  (* TODO *)
  Xml.Element ("TrainingCenterDatabase",
               ["xmlns", xmlns],
               [])

let of_string str = Xml.parse_string str |> of_xml

let to_string tcx = to_xml tcx |> Xml.to_string_fmt
