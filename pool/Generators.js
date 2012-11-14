function GenerateRemS(args) {
  modulo = args[0]
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
    var hasa = group.hasElement(a)
    var hasb = group.hasElement(b)
    if (!hasa)
      window.gerror.msg.push("No element " + a + " in the group")
    if (!hasb)
      window.gerror.msg.push("No element " + b + " in the group")
    if (!hasa || !hasb)
      return
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

function gcd(a, b) {
  while (b != 0) {
    tmp = a
    a = b
    b = tmp % b
  }
  return a
}

function GenerateGroupRemM(args) {
  modulo = args[0]
  var group = {
    name: "Rem(" + modulo + ")*",
    elements: [],
    order: 0,
    neutral: 1,
    properties: [],
    type: "group",
    table: [],
    inv_map: {}
  }
  
  for (var i = 1; i < modulo; ++i)
    if (gcd(i, modulo) == 1)
      group.elements.push(i)
  group.order = group.elements.length
   
  group.mult = function(a,b) {
    return (a * b) % modulo
  }
  
  for (var i = 0; i < group.order; ++i) {
    group.table.push([])
    for (var j = 0; j < group.order; ++j)
      group.table[i][j] = (group.elements[i] * group.elements[j]) % modulo
      if (group.table[i][j] == group.neutral) {
        group.inv_map[i] = group.elements[j]
      }
  }      
  
  group.hasElement = function(elem) {
    return (elem >= 0 && elem < group.order)
  }
  
  group.inverse = function(elem) {
    return group.inv_map[elem]
  }
  
  group.properties.push("abelian")
  
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
    name: group.name + "_aut#" + Math.floor(Math.random()*10000),
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

pool = new Pool()

function GenerateFromRaw(data) {
  try {
  s = eval('(' + data[0] + ')')
  } catch (e) {
    window.gerror.msg.push(e)
  }
  return pool.addStruct(s)
}

function GenerateRandomEndomorphism(group) {
  ind = [0]
  for (var i = 1; i < group.order; ++i)
    ind.push(Math.floor(Math.random() * group.order))

  return GenerateEndomorphism(group, ind)  
}

function GenerateRandomMorphism(group1, group2) {
  var morphism = {
    name: group1.name + " to " + group2.name + " #" + Math.floor(Math.random()*10000),
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

providers = {"Rem+": GenerateRemS, "Rem*": GenerateGroupRemM, "Raw": GenerateFromRaw} 