function show_dataset(dataset) {

  var sampleSVG = d3.select("#viz")
    .append("svg")
    .attr("width", 800)
    .attr("height", 600);
		

  var g = sampleSVG.selectAll("g.node")
		.data(dataset)
		.enter()
		.append("svg:g")
		.attr("class", "node")
		.attr("transform", function(d) { return "translate(" + d.x + ","+ d.y + ")"; })
		
		
    g.append("svg:circle")
    .attr("r", 20)
	  .attr("cx", function(d, i) { return 50*i + 50; })
	  .attr("cy", 50)
	  .style("fill", "white")
	  .style("stroke", "gray");
	  
	g.append("svg:text")
    .attr("x", function(d, i) { return 50*i + 50; })
    .attr("y", 50)
    .attr("dy", "0.5ex")
    .text(function(d) { return d; });

}