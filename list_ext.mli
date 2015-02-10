include (module type of List)

module Non_empty :
sig
  type 'a t = 'a * 'a list

  val map : ('a -> 'b) -> 'a t -> 'b t

  val of_list : 'a list -> 'a t

  val to_list : 'a t -> 'a list
end
