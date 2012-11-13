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

class CayleyTableVis
  show: (data) ->
    structure = data[0]
    links = []
    for i in [0..structure.get_members().length-1]
      for j in [0..structure.get_members().length-1]
        #todo Fix label
        links.push({source: i, src: i, dest:structure.mul_a_b(i, j), target: structure.mul_a_b(i, j), label:j, type: "plain"})
    nodes = []
    deltaX = 140
    deltaY = 140
    baseX = 50
    ind = 0
    for memb in structure.get_members()
      nodes.push({x:(baseX + if (ind % 2 == 0) then deltaX else 0), y:(20 + if (ind % 2 != 0) then deltaY else 0), ind: memb, name: memb, fixed: 1})
      ind += 1
      baseX += if (ind % 2 == 0) then 50 else 0 
    w = 600
    h = 400

    force = d3.layout.force().nodes(d3.values(nodes)).links(links).size([w, h]).linkDistance(60).charge(10).start();

    svg = d3.select(OUTDEVICE_ID).append("svg:svg").attr("width", w).attr("height", h);
    svg.append("svg:defs").selectAll("marker").data(["plain", "dotted"]).enter().append("svg:marker")
      .attr("id", String).attr("viewBox", "0 -5 10 10").attr("refX", 15).attr("refY", -1.5).attr("markerWidth", 6)
      .attr("markerHeight", 6).attr("orient", "auto").append("svg:path").attr("d", "M0,-5L10,0L0,0");

    path = svg.append("svg:g").selectAll("path").data(force.links())
      .enter().append("svg:path").attr("class", (d) -> "link " + d.type)
      .attr("marker-end", (d) -> "url(#" + d.type + ")")
      .attr("src", (d) -> d.src).attr("dst", (d) -> d.dest)
      .attr("id", (d) -> d.src + "_" + d.dest)

    circle = svg.append("svg:g").selectAll("circle").data(force.nodes()).enter().append("svg:circle")
      .attr("r", 6).style("fill", "gray")
      .on("mouseover", (d) ->
        d3.select(this).style("fill", "orange");
        d3.selectAll("path.link").filter((el) -> el.src == d.ind).attr("class", "link selected")
      )
      .on("mouseout", () ->
        d3.select(this).style("fill", "gray");
        d3.selectAll("path").attr("class", "link plain")
      ).call(force.drag);
    
    text = svg.append("svg:g").selectAll("g").data(force.nodes()).enter().append("svg:g");
    text.append("svg:text").attr("x", 8).attr("y", ".31em").text((d) -> d.name);

    text_links = svg.append("svg:g").selectAll("g").data(force.links())
      .enter().append("svg:g").append("svg:text").attr("style", "text-anchor:middle").append("svg:textPath")
      .attr("xlink:href", (d) -> "##{d.src}_#{d.dest}").attr("startOffset", "120").text((d) -> d.label)


    force.on("tick", (e) ->
      circle.attr("transform", (d) -> "translate(#{d.x}, #{d.y})")
      text.attr("transform", (d) -> "translate(#{d.x},#{d.y})")

      path.attr("d", (d) ->
        dx = d.target.x - d.source.x
        dy = d.target.y - d.source.y
        dr = Math.sqrt(dx * dx + dy * dy)*2;
        "M#{d.source.x}, #{d.source.y}A#{dr},#{dr} 0 0,1 #{d.target.x},#{d.target.y}")
    )


vis_pool = {"ANY": new SimpleVis, "PTS": new SimplePointsVis, "STR_SHOW": new CayleyTableVis}