
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
  vis = vis_pool["PTS"]
  vis.show([result])

window.process_data = process_data