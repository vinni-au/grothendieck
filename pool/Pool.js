window.gerror = {}
window.gerror.msg = []

function SimpleAssociativityTest(as) {
//  console.log("Starting SAT on" + as.name)
  var count = as.elements.length;
  for (var i = 0; i < count; ++i) {
    var a = as.elements[i]
//    console.log("testing element: " + a)
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
    
//    console.log(t1)
//    console.log(t2)
    
    for (var ii = 0; ii < count; ++ii)
      for (var jj = 0; jj < count; ++jj) {
//        console.log("testing " + t1[ii][jj] + " and " + t2[ii][jj] + " " + (t1[ii][jj] != t2[ii][jj]))
        if (t1[ii][jj] != t2[ii][jj])
          return false
        }
  }
  return true
}

//TODO add error to window
function validateAS(s, pool) {
  window.gerror = {}
  window.gerror.msg = []
  
  if (typeof s.name == 'undefined')
    window.gerror.msg.push("name is not defined")
    
  if (pool.hasStructure(s))
    window.gerror.msg.push("there's structure already in the pool")

  var ecount = -1
  if (typeof s.elements == 'undefined') {
    window.gerror.msg.push("Elements is not defined")
  } else {
    ecount = s.elements.length
    if (s.elements.length == 0) 
      window.gerror.msg.push("There's no elements")
  }

  if (typeof s.neutral == 'undefined')
    window.gerror.msg.push("Neutral element is not defined")
  else {
    find = false
    for (var i = 0; i < s.elements.length; ++i)
      if (s.neutral == s.elements[i])
        find = true
      if (!find)
        window.gerror.msg.push("Neutral element doesn't belong to algebraic structure")
  }
  
  if (typeof s.operation == 'undefined')
    window.gerror.msg.push("Operation is not defined")
  else {
    if (s.operation.length < ecount)
      window.gerror.msg.push("There's too few rows in Cayley table")
    else if (s.operation.length > ecount)
      window.gerror.msg.push("There's too many rows in Cayley table")
    for (var i = 0; i < s.operation.length; ++i) {
      if (s.operation[i].length != ecount) {
        window.gerror.msg.push("There's wrong elements count in Cayley table's row #" + i)
      }
    }
  }

  wrongtable = false
  for (var i = 0; i < ecount; ++i)
    if (s.operation[0][i] != s.elements[i] || s.operation[i][0] != s.elements[i])
      wrongtable = true
    
  if (wrongtable)
    window.gerror.msg.push("Cayley table is wrong - neutral element is not actually neutral")
}

function validateM(m, pool) {
  window.gerror = {}
  window.gerror.msg = []

  if (typeof m.name == 'undefined')
    window.gerror.msg.push("name is not defined")
    
  if (pool.hasMorphism(m))
    window.gerror.msg.push("There's morphism already")
    
  var from
  var to
  if (typeof m.from == 'undefined')
    window.gerror.msg.push("From is not defined")
  else {
    if (!pool.hasStructure(m.from))
      window.gerror.msg.push("There's no structure with name " + m.from)
    else from = pool.structure(m.from)
  }
  
  if (typeof m.to == 'undefined')
    window.gerror.msg.push("TO is not defined")
  else {
    if (!pool.hasStructure(m.to))
      window.gerror.msg.push("There's no structure with name " + m.to)
    else to = pool.structure(m.to)
  }
  
  if (typeof m.map == 'undefined')
    window.gerror.msg.push("Mapping is not defined")
  else {
    mapsize = m.map.length
    if (typeof from != 'undefined' && typeof to != 'undefined') {
      if (mapsize > from.order)
        window.gerror.msg.push("Map size should not be greater than from.order")
      else {
          for (var i = 0; i < mapsize; ++i) {
            if (!from.hasElement(m.map[i][0]))
              window.gerror.msg.push("Map is wrong - there's no element " + m.map[i][0] + " in From")
            if (!to.hasElement(m.map[i][1]))
              window.gerror.msg.push("Map is wrong - there's no element " + m.map[i][1] + " in To")
          }
          //TODO detect duplicate keys
      }
    }
  }
}

function Morphism(mraw, pool) {
  if (window.gerror.msg.length > 0) {
    console.log(window.gerror.msg)
    window.gerror = {}
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
  
  this.map_index = function(elem) {
    for (var i = 0; i < this.mapsize; ++i) {
      if (this.rawmap[i][0] == elem)
        return i
    }
    var und
    return und
  }
}

function AlgebraicStructure(struct, pool) {
  validateAS(struct, pool)
  if (window.gerror.msg.length > 0)
    return
    
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
      else window.gerror.msg.push("Associativity test not passed")
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


