class Group
  constructor: (@mult_t, @one, @inv, @el_to_int, @members) ->
  
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

OUTDEVICE_ID = "#grot"

class SimpleVis
  show: (data) -> 
    alert(data)

class SimplePointsVis
  show: (data) ->
    sampleSVG = d3.select(OUTDEVICE_ID)
      .append("svg").attr("width", 800).attr("height", 600);
    
    g = sampleSVG.selectAll("g.node")
      .data(data)
      .enter()
      .append("svg:g")
      .attr("class", "node")
      .attr("transform", (d) -> "translate(" + d.x + ","+ d.y + ")")
    
    
    g.append("svg:circle")
      .attr("r", 20)
      .attr("cx", (d, i) -> 50*i + 50)
      .attr("cy", 50)
      .style("fill", "white")
      .style("stroke", "gray")
    
    g.append("svg:text")
      .attr("x", (d, i) -> 50*i + 50)
      .attr("y", 50)
      .attr("dy", "0.5ex")
      .text((d) -> d)

vis_pool = {"ANY": new SimpleVis, "PTS": new SimplePointsVis}

class Action
  constructor: (@op_id, @vis_id) ->
  perform_operation: (object, args) ->
    operation = operation_pool[@op_id]
    operation.exec(object, args)
  perform_visualization: (op_data) ->
    vis = vis_pool[@vis_id]
    if not (op_data instanceof Array)
      op_data = [op_data]
    vis.show(op_data)

determine_dp = (provider_data) ->
  provider_id = provider_data["id"]
  switch provider_id
    when "Rem" then providers["Rem+"].parse(provider_data['args'])
    else new RawDataParser()

process_data = (action_id, provider_data, args...) ->
  structure = determine_dp(provider_data)

  #pick operation
  action = actions_pool[action_id]
  op_data = action.perform_operation(structure, args)
  action.perform_visualization(op_data)
  
providers = {"Rem+": new AddRemProvider, "*": new RawDataParser()} 

actions_pool = {
 "mult" : new Action("a*b", "PTS")
}

window.process_data = process_data