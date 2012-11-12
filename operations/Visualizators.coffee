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