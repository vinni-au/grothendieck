function SimpleAssociativityTest(as) {
  var count = as.elements.length;
  for (var i = 0; i < count; ++i) {
    var a = as.elements[i]
    var t1 = [] //for  x (a  y)
    var t2 = [] //for (x  a) y
    for (var ii = 0; ii < count; ++ii) {
      t1.push([])
      for (var jj = 0; jj < count; ++jj)
        t1[ii][jj] = as.mult(as.elements[ii], as.mult(a, as.elements[jj]))
    }
    
    for (var ii = 0; ii < count; ++ii) {
      t2.push([])
      for (var jj = 0; jj < count; ++jj)
        t2[ii][jj] = as.mult(as.mult(as.elements[ii], a), as.elements[jj])
    }
    
    for (var ii = 0; ii < count; ++ii)
      for (var jj = 0; jj < count; ++jj)
        if (t1[ii][jj] != t2[ii][jj])
          return false
  }
  return true
}

function validateAS(s, pool) {
  error = {}
  error.msg = []
  
  if (typeof s.name == 'undefined')
    error.msg.push("name not defined")
    
  if (pool.hasStructure(s))
    error.msg.push("there's structure already in the pool")

  var ecount = -1
  if (typeof s.elements == 'undefined') {
    error.msg.push("Elements not defined")
  } else {
    ecount = s.elements.length
    if (s.elements.length == 0) 
      error.msg.push("There's no elements")
  }

  if (typeof s.neutral == 'undefined')
    error.msg.push("Neutral element is undefined")
  else {
    find = false
    for (var i = 0; i < s.elements.length; ++i)
      if (s.neutral == s.elements[i])
        find = true
      if (!find)
        error.msg.push("Neutral element doesn't belong to group")
  }
  
  if (typeof s.operation == 'undefined')
    error.msg.push("Operation not defined")
  else {
    if (s.operation.length != ecount)
      error.msg.push("There's too few rows in Cayley table")
    for (var i = 0; i < s.operation.length; ++i) {
      if (s.operation[i].length != ecount) {
        error.msg.push("There's wrong count in Cayley table's row #" + i)
      }
    }
  }

  wrongtable = false
  for (var i = 0; i < ecount; ++i)
    if (s.operation[0][i] != s.elements[i] || s.operation[i][0] != s.elements[i])
      wrongtable = true
    
  if (wrongtable)
    error.msg.push("Cayley table is wrong - neutral element is not actually neutral")
    
  return error
}

function validateM(m, pool) {
  error = {}
  error.msg = []

  if (typeof m.name == 'undefined')
    error.msg.push("name not defined")
    
  if (pool.hasMorphism(m))
    error.msg.push("There's morphism already")
    
  var from
  var to
  if (typeof m.from == 'undefined')
    error.msg.push("From not defined")
  else {
    if (!pool.hasStructure(m.from))
      error.msg.push("There's no structure with name " + m.from)
    else from = pool.structure(m.from)
  }
  
  if (typeof m.to == 'undefined')
    error.msg.push("TO is not defined")
  else {
    if (!pool.hasStructure(m.to))
      error.msg.push("There's no structure with name " + m.to)
    else to = pool.structure(m.to)
  }
  
  if (typeof m.map == 'undefined')
    error.msg.push("Mapping not defined")
  else {
    mapsize = m.map.length
    if (typeof from != 'undefined' && typeof to != 'undefined') {
      if (mapsize > from.order)
        error.msg.push("Map size should not be greater than from.order")
      else {
          for (var i = 0; i < mapsize; ++i) {
            if (!from.hasElement(m.map[i][0]))
              error.msg.push("Map is wrong - there's no element " + m.map[i][0] + " in From")
            if (!to.hasElement(m.map[i][1]))
              error.msg.push("Map is wrong - there's no element " + m.map[i][1] + " in To")
          }
          //TODO detect duplicate keys
      }
    }
  }
  return error
}

function Morphism(mraw, pool) {
  errors = validateM(mraw, pool)
  if (errors.msg.length > 0) {
    console.log(errors.msg)
    return
  }
    
  this.name = mraw.name
  this.from = pool.structure(mraw.from)
  this.to = pool.structure(mraw.to)
  this.mapsize = mraw.map.length
  this.rawmap = []
  for (var i = 0; i < this.mapsize; ++i) {
    this.rawmap[i] = []
    this.rawmap[i][0] = mraw.map[i][0]
    this.rawmap[i][1] = mraw.map[i][1]
  }
  
  this.map = function(elem) {
    for (var i = 0; i < this.mapsize; ++i) {
      if (this.rawmap[i][0] == elem)
        return this.rawmap[i][1]
    }
    var und
    return und
  }
}

function AlgebraicStructure(struct, pool) {
  errors = validateAS(struct, pool);
  if (errors.msg.length > 0) {
    return
  }
  
  this.name = struct.name
  this.order = struct.elements.length
  this.type = "monoid"
  
  this.elements = []
  for (var i = 0; i < this.order; ++i)
    this.elements.push(struct.elements[i])
  
  this.neutral = struct.neutral
  
  this.table = []
  for (var i = 0; i < this.order; ++i) {
    this.table[i] = []
    for (var j = 0; j < this.order; ++j)
      this.table[i][j] = struct.operation[i][j]
  }  

  this.mult = function(a,b) {
    inda = -1
    indb = -1
    for (var i = 0; i < this.order; ++i) {
      if (this.elements[i] == a)
        inda = i
      if (this.elements[i] == b)
        indb = i
    }
    if (inda == -1 || indb == -1) {
      var und
      return und
    }
    return this.table[inda][indb]
  }
  
  this.hasElement = function(elem) {
    for (var i = 0; i < this.order; ++i)
      if (this.elements[i] == elem)
        return true
    return false
  }
  
  //check for monoid and group
  this.properties = []
  //TODO check some properties (cyclic)
  var isabelian = true
  for (var i = 0; i < this.order; ++i)
    for (var j = i; j < this.order; ++j)
      if (i != j)
        if (this.table[i][j] != this.table[j][i]) {
          isabelian = false
          break
        }
  if (isabelian)
    this.properties.push("abelian")
}

function Pool() {
  this.structures = []
  this.morphisms = []
  
  this.addStruct = function (s) {
    str = new AlgebraicStructure(s, this)
    if (typeof str.name != 'undefined') {
      if (SimpleAssociativityTest(str))
        this.structures.push(str)
      else console.log()
    }
    return str
  }
  
  this.addMorphism = function(m) {
    m = new Morphism(m, this)
    if (typeof m.name != 'undefined') {
      this.morphisms.push(m)
    }    
    return m
  }
  
  this.structure = function(name) {
    for (var i = 0; i < this.structures.length; ++i)
      if (this.structures[i].name == name)
        return this.structures[i]
    var und
    return und
  }
  
  this.morphism = function(name) {
    for (var i = 0; i < this.morphisms.length; ++i)
      if (this.morphisms[i].name == name)
        return this.morphisms[i]
    var und
    return und
  }
  
  this.hasStructure = function(name) {
    str = this.structure(name)
    return typeof str != 'undefined'
  }  
  
  this.hasMorphism = function(name) {
    m = this.morphism(name)
    return typeof m != 'undefined'
  }
}
