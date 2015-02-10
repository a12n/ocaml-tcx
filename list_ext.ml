include List

module Non_empty =
  struct
    type 'a t = 'a * 'a list

    let map f (h, t) = f h, map f t

    let of_list = function
        h :: t -> h, t
      | [] -> raise (Invalid_argument "List_ext.Non_empty.of_list")

    let to_list (h, t) = h :: t
  end
