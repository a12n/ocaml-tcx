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
  end

module Time =
  struct
    type t = {
        hour : int;
        minute : int;
        second : int;
      }
  end

module Time_zone =
  struct
    type t = {
        hours : int;            (* [-12, 14] *)
        minutes : int;          (* [0, 59] *)
      }
  end

module Timestamp =
  struct
    type t = {
        date : Date.t;
        time : Time.t;
        time_zone : Time_zone.t;
      }
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

module Build_type =
  struct
    type t = Internal | Alpha | Beta | Release
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

type activity_lap = {
    (* StartTime time.Time `xml:",attr"` *)
    total_time : float;
    distance : float;
    maximum_speed : float option;
    calories : int;
    average_heart_rate : int option;
    maximum_heart_rate : int option;
    intensity : Intensity.t;
    cadence : int option;
    trigger_method : Trigger_method.t;
    track : track list;
    notes : string option;
  }

type version = {
    major : int;
    minor : int;
    build_major : int option;
    build_minor : int option;
  }

type device = {
    name : string;
    unit_id : int;
    product_id : int;
    version : version;
  }

type build = {
    version : version;
    build_type : Build_type.t;
    time : string;
    builder : string option;
  }

type lang_id = string

type part_number = string

type application = {
    name : string;
    build : build;
    lang_id : lang_id;
    part_number : part_number;
  }

type abstract_source = Device of device
                     | Application of application

type quick_workout = {
    total_time : float;
    distance : float;
  }

type plan = {
    name : string;
  }

type training = {
    virtual_partner : bool;
    quick_workout_results : quick_workout option;
    plan : plan option;
  }

type activity = {
    sport : Sport.t;
    (* id : time.Time; *)
    lap : activity_lap list;
    notes : string option;
    training : training option;
    creator : abstract_source option;
  }

type t = {
    (* TODO: Folders, workouts, etc. *)
    activities : activity list;
  }
