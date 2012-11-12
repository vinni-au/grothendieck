
class MulElAndSet
  exec: (el, set, group) ->
    if group.is_member(el)
      return (group.mul_a_b(el, set_el) for set_el in set)

class SimpleMul
  exec: (obj, args) ->
    return obj.mul_a_b(args[0], args[1]);

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