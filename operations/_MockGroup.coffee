class Rem5
  mult_t: [[0,1,2,3,4],[1,2,3,4,0],[2,3,4,0,1],[3,4,0,1,2],[4,0,1,2,3]]
  one: 0
  inv: {0:0, 1:4, 2:3, 3:2, 4:1}
  el_to_int: {0:0, 1:1, 2:2, 3:3, 4:4}
  members: [0, 1, 2, 3, 4]

  get_inverse: (x) -> inv[x]
  mul_a_b: (a,b) -> 
    @mult_t[@el_to_int[a]][@el_to_int[b]]
  is_member: (x) -> @el_to_int[a]?

class Rem5Provider
  parse: () -> new Rem5()

class RawDataParser
  parse: () -> 
