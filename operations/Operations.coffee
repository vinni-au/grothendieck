class SimpleMul
  exec: (obj, args) ->
    return obj.mult(args[0], args[1]);

class SubSetMul
  exec: (obj, args) ->
    sub = args[0]
    results = []
    listed = {}
    for el in obj.elements
      tmp_res = []
      for sub_el in sub
        tmp_res.push(obj.mult(el, sub_el.name))
      is_dup = false
      for val in tmp_res
        if listed[val]?      
          is_dup = true
          break
        else
          listed[val] = true
      if not is_dup        
        results.push(tmp_res)
    [results, obj]


class IsSubGroup
  exec: (base, sub) ->
    return false if not (base.one == sub.one)
    
    sub_is_part_of_base = (base.is_member(i) for i in sub.members).reduce (a,b) -> a and b
    return false if not sub_is_part_of_base

    #todo check multiplication and closeness

    return true

class Id
  exec: (obj) -> obj
  

class ApplyMorphism
  exec: (group, morph) -> morph(el) for el in group.members 


operation_pool = {
  "ID": new Id, "a*b":new SimpleMul,"g*H": new SubSetMul, "isSub": new IsSubGroup, "f(g)": new ApplyMorphism}