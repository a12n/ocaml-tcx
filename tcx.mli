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
