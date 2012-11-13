function GenerateRemS(modulo) {
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
    group.elements.push(i)
   
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

//indexes is array of indexes
function GenerateEndomorphism(group, indexes) {
  var und
  if (group.order != indexes.length)
    return und
  if (group.elements[indexes[0]] != group.neutral)
    return und
  
  var morphism = {
    name: group.name + "_aut" + Math.random(),
    from: group,
    to: group,
    rawmap: [],
    mapsize: indexes.length
  }
  
  for (var i = 0; i < indexes.length; ++i)
    morphism.rawmap.push([ group.elements[i], 
                           group.elements[indexes[i]] ])
  
  morphism.map = function(elem) {
    for (var i = 0; i < morphism.mapsize; ++i)
      if (morphism.rawmap[i][0] == elem)
        return morphism.rawmap[i][1]
  }
  
  morphism.map_index = function(elem) {
    for (var i = 0; i < morphism.mapsize; ++i) {
      if (morphism.rawmap[i][0] == elem)
        return i
    }
    var und
    return und
  }
  
  return morphism
}

function GenerateRandomEndomorphism(group) {
  ind = [0]
  for (var i = 1; i < group.order; ++i)
    ind.push(Math.floor(Math.random() * group.order))

  return GenerateEndomorphism(group, ind)  
}

function GenerateRandomMorphism(group1, group2) {
  var morphism = {
    name: group1.name + " to " + group2.name,
    from: group1,
    to: group2,
    rawmap:[],
    mapsize:group1.order
  }
  
  morphism.rawmap.push([group1.neutral, group2.neutral])
  for (var i = 1; i < group1.order; ++i) {
    var r = Math.floor(Math.random()*group2.order)
    morphism.rawmap.push([group1.elements[i],
                         group2.elements[r]])
  }
  
  morphism.map = function(elem) {
    for (var i = 0; i < morphism.mapsize; ++i)
      if (morphism.rawmap[i][0] == elem)
        return morphism.rawmap[i][1]
  }
  
  morphism.map_index = function(elem) {
    for (var i = 0; i < morphism.mapsize; ++i) {
      if (morphism.rawmap[i][0] == elem)
        return i
    }
    var und
    return und
  }
  
  return morphism
}