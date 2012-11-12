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



class MulElAndSet
  exec: (el, set, group) ->
    if group.is_member(el)
      return (group.mul_a_b(el, set_el) for set_el in set)

class SimpleMul
  exec: (args) ->
    return args[2].mul_a_b(args[0], args[1]);

class IsSubGroup
  exec: (base, sub) ->
    return false if not (base.one == sub.one)
    
    sub_is_part_of_base = (base.is_member(i) for i in sub.members).reduce (a,b) -> a and b
    return false if not sub_is_part_of_base

    #todo check multiplication and closeness

    return true

class ApplyMorphism
  exec: (group, morph) -> morph(el) for el in group.members 


operation_pool = {"a*b":new SimpleMul,"g*H": new MulElAndSet, "isSub": new IsSubGroup, "f(g)": new ApplyMorphism}


class SimpleVis
  show: (data) -> 
    alert(data)

vis_pool = {"ANY": new SimpleVis}


determine_dp = (args) ->
  dp_type = args[0]
  switch dp_type
    when "Rem5" then new Rem5Provider()
    else new RawDataParser()

process_data = (name, args...) ->
  dp = determine_dp(args)
  data = dp.parse()

  #pick operation
  operation = operation_pool[name]
  params = args[1..]
  params.push(data)
  result = operation.exec(params)

  #pick visualizer
  vis = vis_pool["ANY"]
  vis.show(result)

window.process_data = process_data