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

type activity = {
    (* id : time.Time; *)
    sport : sport;
    lap : activity_lap list;
  }

type t = {
    (* TODO: Folders, workouts, etc. *)
    activities : activity list;
  }
