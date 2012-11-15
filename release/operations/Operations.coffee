class SimpleMul
  exec: (obj, args) ->
    return obj.mult(args[0], args[1]);

class SubSetMul
  exec: (obj, args) ->
    [sub, results, listed] = [args[0], [], {}]
    for el in obj.elements
      tmp_res = []
      for sub_el in sub
        tmp_res.push(obj.mult(el, sub_el))
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

error = ""
class SubGroupChecker
  exec: (obj, args) ->    
    [base, sub] = [obj, args[0]]

    if (base.order % sub.length) != 0
      error = "Order of group isn't devided by order of subgroup.<br/> <i>Do you know about Lagrange?</i>"
      window.gerror.msg.push(error)
      return false

    if sub.indexOf(base.neutral) == -1
      error = "Neutral element (#{base.neutral}) is not in a given set.\n #{sub} is not a subgroup"
      window.gerror.msg.push(error)
      return false

    sub_is_part_of_base = (base.hasElement(i) for i in sub).reduce (a,b) -> a and b
    if not sub_is_part_of_base
      error = "Some element of subgroup is not in the group. CONTRADICTION!"
      window.gerror.msg.push(error)
      return false

    for el1_sub in sub
      for el2_sub in sub
        prod_res = base.mult(el1_sub, el2_sub)
        if sub.indexOf(prod_res) == -1
          error = "#{el1_sub} times #{el2_sub} is #{prod_res} which is not in subgroup. " +
                  "<p class='err_sumary'>Closure property is violated</p>"
          window.gerror.msg.push(error)
          return false

    return [obj, args]

class CompositeOperation
  constructor: (@ops) ->
  exec: (obj, args) ->
    error = ""
    for operation in @ops
      res = operation.exec(obj, args)
      if error != ""
        return []
    return res

class Id
  exec: (obj) -> obj

class ApplyMorphism
  exec: (group, morph) -> morph(el) for el in group.members 


operation_pool = {
  "ID": new Id, "a*b":new SimpleMul,
  "g*H": new CompositeOperation([new SubGroupChecker, new SubSetMul]),
  "f(g)": new ApplyMorphism,
  "subgroupChecker": new SubGroupChecker
}