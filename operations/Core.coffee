class Action
  constructor: (@op_id, @vis_id) ->
  perform_operation: (object, args) ->
    operation = operation_pool[@op_id]
    operation.exec(object, args)
  perform_visualization: (op_data) ->
    vis = vis_pool[@vis_id]
    console.log(op_data)
    if not (op_data instanceof Array)
      op_data = [op_data]
    vis.show(op_data)

determine_dp = (provider_data) ->
  provider_id = provider_data["id"]
  switch provider_id
    when "Rem+" then providers["Rem+"](provider_data['args'])
    when "Rem*" then providers["Rem*"](provider_data['args'])
    else {}

process_data = (action_id, provider_data, args...) ->
  structure = determine_dp(provider_data)

  #pick operation
  action = actions_pool[action_id]
  op_data = action.perform_operation(structure, args)
  action.perform_visualization(op_data)

actions_pool = {
 "mult" : new Action("a*b", "PTS"),
 "show_structure": new Action("ID", "STR_SHOW")
}

window.process_data = process_data