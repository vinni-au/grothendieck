function RemSGenerate(modulo) {
  var group = {
    name: "Rem(" + modulo + ")+",
    elements: [],
    order: modulo,
    neutral: 0,
    properties: [],
    type: "group",
    table: []
  }
  for (var i = 0; i < modulo; ++i)
    group.elements.push[i]
   
  group.mult = function(a,b) {
    return (a+b)%group.order
  }
  
  for (var i = 0; i < modulo; ++i) {
    group.table.push([])
    for (var j = 0; j < modulo; ++j)
      group.table[i][j] = (i+j)%modulo
  }      
  
  group.hasElement = function(elem) {
    return (elem >= 0 && elem < group.order)
  }
  
  group.inverse = function(elem) {
    for (var i = 0; i < group.order; ++i)
      if (((elem+i)%group.order) == 0)
        return i
  }
  
  group.properties.push("abelian")
  group.properties.push("cyclic")
    
  return group
}