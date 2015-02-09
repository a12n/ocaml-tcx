module Position :
sig
  type t = {
      latitude : float;       (* [-90, 90] *)
      longitude : float;      (* [-180, 180] *)
    }
end

module Date :
sig
  type t = {
      year : int;
      month : int;
      day : int;
    }
end

module Time :
sig
  type t = {
      hour : int;
      minute : int;
      second : int;
    }
end

module Time_zone :
sig
  type t = {
      hours : int;            (* [-12, 14] *)
      minutes : int;          (* [0, 59] *)
    }
end

module Timestamp :
sig
  type t = {
      date : Date.t;
      time : Time.t;
      time_zone : Time_zone.t;
    }
end

module Sensor_state :
sig
  type t = Present | Absent
end

module Intensity :
sig
  type t = Active | Resting
end

module Trigger_method :
sig
  type t = Manual | Distance | Location | Time | Heart_rate
end

module Sport :
sig
  type t = Running | Biking | Other
end

module Build_type :
sig
  type t = Internal | Alpha | Beta | Release
end

module Track_point :
sig
  type t = {
      time : Timestamp.t;
      position : Position.t option;
      altitude : float option; (* m *)
      distance : float option; (* m *)
      heart_rate : int option; (* bpm *)
      cadence : int option;    (* rpm *)
      sensor_state : Sensor_state.t;
    }
end

module Track :
sig
  type t = {
      points : Track_point.t list;
    }
end

module Activity_lap :
sig
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
