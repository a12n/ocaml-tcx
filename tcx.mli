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
