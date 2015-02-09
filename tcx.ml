type position = {
    latitude : float;       (* [-90, 90] *)
    longitude : float;      (* [-180, 180] *)
  }

type sensor_state = Present | Absent

type trackpoint = {
    (* Time time.Time *)
    position : position option;
    altitude : float option;
    distance : float option;
    heart_rate : int option;
    cadence : int option;
    sensor_state : sensor_state;
  }

type track = {
    trackpoint : trackpoint list;
  }

type intensity = Active | Resting

type trigger_method = Manual | Distance | Location | Time | Heart_rate

type activity_lap = {
    (* StartTime time.Time `xml:",attr"` *)
    total_time : float;
    distance : float;
    maximum_speed : float option;
    calories : int;
    average_heart_rate : int option;
    maximum_heart_rate : int option;
    intensity : intensity;
    cadence : int option;
    trigger_method : trigger_method;
    track : track list;
    notes : string option;
  }

type sport = Running | Biking | Other

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

type build_type = Internal | Alpha | Beta | Release

type build = {
    version : version;
    build_type : build_type;
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
    sport : sport;
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
