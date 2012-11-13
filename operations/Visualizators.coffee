OUTDEVICE_ID = "#grot"

class SimpleVis
  show: (data) -> 
    alert(data)


class SimplePointsVis
  show: (data) ->
    sampleSVG = d3.select(OUTDEVICE_ID)
      .append("svg").attr("width", 700).attr("height", 600);
    
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

HUGE_CRITERIA = 10
is_str_huge = (structure) -> structure.get_members().length > HUGE_CRITERIA

class CayleyTableVis
  show: (data) ->
    structure = data[0]

    links = []
    for i in [0..structure.get_members().length-1]
      for j in [0..structure.get_members().length-1]
        #todo Fix label
        links.push({source: i, src: i, dest:structure.mul_a_b(i, j), target: structure.mul_a_b(i, j), label:j, type: "plain"})
    nodes = []

    radius = if is_str_huge(structure) then 200 else 100
    curr_alpha = 0
    delta_alpha = 2 * Math.PI / structure.get_members().length

    for memb in structure.get_members()
      coord_x = radius * Math.cos(curr_alpha) + 300
      coord_y = radius * Math.sin(curr_alpha) + 200
      nodes.push({x:coord_x, y:coord_y, ind: memb, name: memb, fixed: 1})
      curr_alpha += delta_alpha
    w = 700
    h = 600

    force = d3.layout.force().nodes(d3.values(nodes)).links(links).size([w, h]).linkDistance(60).charge(10).start();

    svg = d3.select(OUTDEVICE_ID).append("svg:svg").attr("width", w).attr("height", h);
    ### FIX merkers
    svg.append("svg:defs").selectAll("marker").data(["plain"]).enter().append("svg:marker")
      .attr("id", String).attr("viewBox", "0 -5 10 10").attr("refX", 15).attr("refY", -1.5).attr("markerWidth", 6)
      .attr("markerHeight", 6).attr("orient", "auto").append("svg:path").attr("d", "M0,-5L10,0L0,0");
    ###
    #NO LOOPS
    path = svg.append("svg:g").selectAll("path").data(force.links())
      .enter().append("svg:path").attr("class", (d) -> "link " + d.type)
      #.attr("marker-end", (d) -> if d.src != d.desc then "url(##{d.type})" else "")
      .attr("src", (d) -> d.src).attr("dst", (d) -> d.dest)
      .attr("id", (d) -> d.src + "_" + d.dest)

    circle = svg.append("svg:g").selectAll("circle").data(force.nodes()).enter().append("svg:circle")
      .attr("r", 6).style("fill", "gray")
      .on("mouseover", (d) ->
        d3.select(this).style("fill", "orange");
        d3.selectAll("path.link").filter((el) -> el.src == d.ind).attr("class", "link selected")
        
        if is_str_huge(structure)
          for i in [0..structure.get_members().length-1]
            d3.select("#t_#{d.ind}_#{i}").attr("class", "visible")
      )
      .on("mouseout", (d) ->
        d3.select(this).style("fill", "gray");
        d3.selectAll("path").attr("class", "link plain")

        if is_str_huge(structure)
          for i in [0..structure.get_members().length-1]
            d3.select("#t_#{d.ind}_#{i}").attr("class", "invisible")
      ).call(force.drag);
    
    text = svg.append("svg:g").selectAll("g").data(force.nodes()).enter().append("svg:g");
    text.append("svg:text").attr("x", 8).attr("y", ".31em").text((d) -> d.name);

    link_text_style = if is_str_huge(structure) then "invisible" else "visible"
    text_links = svg.append("svg:g").selectAll("g").data(force.links())
      .enter().append("svg:text").attr("id", (d) -> "t_#{d.src}_#{d.dest}").attr("class", link_text_style).append("svg:textPath")
      .attr("xlink:href", (d) -> "##{d.src}_#{d.dest}").attr("startOffset", (d) -> if d.src == d.dest then 50 else 120)
      .text((d) -> d.label)


    force.on("tick", (e) ->
      circle.attr("transform", (d) -> "translate(#{d.x}, #{d.y})")
      text.attr("transform", (d) -> "translate(#{d.x},#{d.y})")

      path.attr("d", (d) ->
        dx = d.target.x - d.source.x
        dy = d.target.y - d.source.y
        dr = Math.sqrt(dx * dx + dy * dy)*2
        if d.src != d.dest
          "M#{d.source.x}, #{d.source.y}A#{dr},#{dr} 0 0,1 #{d.target.x},#{d.target.y}"
        else
          "M#{d.source.x}, #{d.source.y}C#{d.source.x},#{d.source.y-50},#{d.source.x-100},#{d.source.y},#{d.source.x},#{d.source.y}"
      )
    )


vis_pool = {"ANY": new SimpleVis, "PTS": new SimplePointsVis, "STR_SHOW": new CayleyTableVis}