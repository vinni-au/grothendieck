OUTDEVICE_ID = "#grot"

indexof = (elem, array) ->
    for i in [0..array.length]
      if (elem == array[i])
        return i
    return -1

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
      
class MorphismVis
    
  show: (data) ->
  
    nodes = []
    data.from.elements.forEach((d, i) ->  nodes.push({x:100, y:100, cluster:1, name: d, fixed:1}));
    data.to.elements.forEach((d, i) ->  nodes.push({x:100, y:100, cluster:2, name: d, fixed:1 }) ); 
    
    
    
    links = []
    console.log(data.to.elements); 
    data.from.elements.forEach((d, i) -> 
      if (indexof(data.map(d), data.to.elements) != -1)
        links.push({source: d, target: data.from.elements.length + indexof(data.map(d), data.to.elements), type: "plain"}) )   
      
    w = 960;
    h = 500;
   
    t = 50;
    a_count = 1;
    b_count = 1;
    max_ay = 0;
    max_by = 0;
  
    nodes.forEach( (d, i) ->
      
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

    d3.select("svg").remove();
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
  
    #{Per-type markers, as they don''t inherit styles.}
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


HUGE_CRITERIA = 10
is_str_huge = (structure) -> structure.order > HUGE_CRITERIA

class CayleyTableVis
  show: (data) ->
    struct = data[0]
    console.log(struct)
    links = []
    for i in [0..struct.order-1]
      for j in [0..struct.order-1]
        prod = struct.mult(struct.elements[i], struct.elements[j])
        prod_i = struct.elements.indexOf(prod)

        links.push({
            source: i, src: i, dest:prod_i, target: prod_i, label:struct.elements[j], type: "plain"
        })
    nodes = []

    radius = if is_str_huge(struct) then 200 else 100
    curr_alpha = 0
    delta_alpha = 2 * Math.PI / struct.order

    for memb in struct.elements
      coord_x = radius * Math.cos(curr_alpha) + 300
      coord_y = radius * Math.sin(curr_alpha) + 220
      nodes.push({x:coord_x, y:coord_y, ind: indexof(memb, struct.elements), name: memb, fixed: 1})
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
        
        if is_str_huge(struct)
          for i in [0..struct.order-1]
            d3.select("#t_#{d.ind}_#{i}").attr("class", "visible")
      )
      .on("mouseout", (d) ->
        d3.select(this).style("fill", "gray");
        d3.selectAll("path").attr("class", "link plain")

        if is_str_huge(struct)
          for i in [0..struct.order-1]
            d3.select("#t_#{d.ind}_#{i}").attr("class", "invisible")
      ).call(force.drag);
    
    text = svg.append("svg:g").selectAll("g").data(force.nodes()).enter().append("svg:g");
    text.append("svg:text").attr("x", 8).attr("y", ".31em").text((d) -> d.name);

    link_text_style = if is_str_huge(struct) then "invisible" else "visible"
    text_links = svg.append("svg:g").selectAll("g").data(force.links())
      .enter().append("svg:text").attr("id", (d) -> "t_#{d.src}_#{d.dest}").attr("class", link_text_style).append("svg:textPath")
      .attr("xlink:href", (d) -> "##{d.src}_#{d.dest}").attr("startOffset", (d) -> if d.src == d.dest then 90 else 120)
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

vis_pool = {"ANY": new SimpleVis, "PTS": new SimplePointsVis, "STR_SHOW": new CayleyTableVis, "MOR": new MorphismVis}
window.vis_pool = vis_pool
