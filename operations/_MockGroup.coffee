class Group
  constructor: (@mult_t, @one, @inv, @el_to_int, @members) ->
  get_members: () -> @members
  get_inverse: (x) -> inv[x]
  mul_a_b: (a,b) -> 
    @mult_t[@el_to_int[a]][@el_to_int[b]]
  is_member: (x) -> @el_to_int[a]?


class AddRemProvider
  parse: (data) -> 
    max = data[0]
    elems = [0..max-1]
    el_to_int = {}
    inv = {}
    for i in elems
      el_to_int[i] = i
      inv[i] = Math.abs(max - i)

    mult_t = []
    tmp_el = elems[..]
    for i in [0..max-1]
      mult_t.push(tmp_el)
      fst = tmp_el[0]
      tmp_el = tmp_el[1..]
      tmp_el.push(fst)

    new Group(mult_t, 0, inv, el_to_int, elems[..])

class RawDataParser
  parse: () -> 
