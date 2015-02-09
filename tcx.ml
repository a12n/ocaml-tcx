module Position =
  struct
    type t = {
        latitude : float;
        longitude : float;
      }
  end

module Date =
  struct
    type t = {
        year : int;
        month : int;
        day : int;
      }

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
  end

module Timestamp =
  struct
    type t = {
        date : Date.t;
        time : Time.t;
        time_zone : Time_zone.t;
      }

    let to_string { date; time; time_zone } =
      (Date.to_string date) ^ "T" ^ (Time.to_string time) ^
        (Time_zone.to_string time_zone)
  end

module Sensor_state =
  struct
    type t = Present | Absent
  end

module Intensity =
  struct
    type t = Active | Resting
  end

module Trigger_method =
  struct
    type t = Manual | Distance | Location | Time | Heart_rate
  end

module Sport =
  struct
    type t = Running | Biking | Other
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

let of_string string = Xml.parse_string string |> of_xml

let to_string tcx = to_xml tcx |> Xml.to_string_fmt
