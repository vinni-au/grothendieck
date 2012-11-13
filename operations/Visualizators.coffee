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
      
class MorphismVis
  show: (data) ->
  
    nodes = []
    data.from.elements.forEach((d, i) ->  nodes.push({x:100, y:100, cluster:1, name: d, fixed:1}));
    data.to.elements.forEach((d, i) ->  nodes.push({x:100, y:100, cluster:2, name: d, fixed:1 }) ); 
    
    links = []
    data.from.elements.forEach((d, i) ->  links.push({source: d, target: data.from.elements.length + data.map_index(d), type: "plain"}));   
    console.log(links)
        
    w = 960;
    h = 500;
   
    t = 50;
    a_count = 1;
    b_count = 1;
    max_ay = 0;
    max_by = 0;
  
    nodes.forEach( (d, i) ->
    
      console.log(d);
  
      if (d.cluster == 2) 
        d.x = t + w/2;
        d.y = (b_count++) * 50;
        max_by = Math.max(d.y, max_by);
    
      else 
        d.x = t;
        d.y = (a_count++) * 50; 
        max_ay = Math.max(d.y, max_ay); 
      
    );
   
    force = d3.layout.force()
      .nodes(d3.values(nodes))
      .links(links)
      .size([w, h])
      .linkDistance(60)
      .charge(10)
      .start();

    svg = d3.select(OUTDEVICE_ID).append("svg:svg")
      .attr("width", w)
      .attr("height", h);
      
    ellipse_a = svg.append("svg:ellipse")
    .attr("fill", "none")
    .attr("stroke", "#000")
    
    ellipse_b = svg.append("svg:ellipse")
    .attr("fill", "none")
    .attr("stroke", "#000")

    ellipse_a.attr("cx", t);
    ellipse_a.attr("cy", 25 + max_ay/2 );
    ellipse_a.attr("ry", max_ay/2 );
    ellipse_a.attr("rx", 50 );
    
    ellipse_b.attr("cx", t + w/2);
    ellipse_b.attr("cy", 25 + max_by/2 );
    ellipse_b.attr("ry", max_by/2 );
    ellipse_b.attr("rx", 50 );
  
    #{Per-type markers, as they don't inherit styles.}
    svg.append("svg:defs").selectAll("marker")
      .data(["plain", "dotted"])
    .enter().append("svg:marker")
      .attr("id", String)
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 15)
      .attr("refY", -1.5)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("svg:path")
      .attr("d", "M0,-5L10,0L0,0");

    path = svg.append("svg:g").selectAll("path")
      .data(force.links())
      .enter().append("svg:path")
      .attr("fill", "none")
      .attr("stroke", "#666")
      .attr("stroke-width", "1.5px")
      .attr("class", (d) -> return "link " + d.type; )
      .attr("marker-end", (d) -> return "url(#" + d.type + ")"; );

    circle = svg.append("svg:g").selectAll("circle")
      .data(force.nodes())
    .enter().append("svg:circle")
      .attr("r", 6)
      .attr("fill", "#ccc")
      .attr("stroke", "#333")
      .attr("stroke-width", "1.5px")
      .call(force.drag);

    text = svg.append("svg:g").selectAll("g")
      .data(force.nodes())
    .enter().append("svg:g");

    #{A copy of the text with a thick white stroke for legibility.}
    text.append("svg:text")
      .attr("x", 8)
      .attr("y", ".31em")
      .attr("stroke", "#fff")
      .attr("stroke-width", "3px")
      .attr("stroke-opacity", ".8")
      .attr("font", "10px sans-serif")
      .attr("pointer-events", "none")
      .attr("class", "shadow")
      .text((d) -> return d.name; );

    text.append("svg:text")
      .attr("x", 8)
      .attr("y", ".31em")
      .attr("font", "10px sans-serif")
      .attr("pointer-events", "none")
      .text((d) -> return d.name; );
   

    force.on("tick", (e) ->
      circle.attr("transform", (d) -> return "translate(" + d.x + "," + d.y + ")"; );

      text.attr("transform", (d) -> return "translate(" + d.x + "," + d.y + ")"; );

    path.attr("d", (d) ->
      dx = d.target.x - d.source.x
      dy = d.target.y - d.source.y
      dr = Math.sqrt(dx * dx + dy * dy)*2;
      return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
    );

    );
  
vis_pool = {"ANY": new SimpleVis, "PTS": new SimplePointsVis, "MOR": new MorphismVis}
window.vis_pool = vis_pool