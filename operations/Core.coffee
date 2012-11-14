class Action
  vis: null
  constructor: (@op_id, @vis_id) ->
  perform_operation: (object, args) ->
    operation = operation_pool[@op_id]
    operation.exec(object, args)
  perform_visualization: (op_data) ->
    @vis = vis_pool[@vis_id]
    if not (op_data instanceof Array)
      op_data = [op_data]
    @vis.show(op_data)
    
class MultiplicationAction extends Action
  structure: null

  perform_operation: (object, args) ->
    @structure = object
    super object, args

  perform_visualization: (op_data) ->
    super @structure
    if @vis_id == "STR_SHOW"
      @vis.setNodeColor(op_data, "red")
    
    

determine_dp = (provider_data) ->
  provider_id = provider_data["id"]
  switch provider_id
    when "Rem+" then providers["Rem+"](provider_data['args'])
    when "Rem*" then providers["Rem*"](provider_data['args'])
    when "Raw" then providers["Raw"](provider_data['args'])
    when "from_nodes" then providers["Subgroup"]([operation_pool["subgroupChecker"], provider_data['args']])
    else {}

process_data = (action_id, provider_data, args...) ->
  structure = determine_dp(provider_data)
  #pick operation
  action = actions_pool[action_id]
  op_data = action.perform_operation(structure, args)
  if window.gerror.msg.length == 0
    action.perform_visualization(op_data)

actions_pool = {
 "mult" : new MultiplicationAction("a*b", "STR_SHOW"),
 "show_structure": new Action("ID", "STR_SHOW")
 "show_coset": new Action("g*H", "FACT_S")
}

window.process_data = process_data