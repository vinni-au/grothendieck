g3 = {
  name:"g_3",
  elements:["a","b","c","d"],
  neutral:"a",
  operation:
    [["a","b","c","d"],
     ["b","a","d","c"],
     ["c","d","a","b"],
     ["d","c","b","a"]]
}

m1 = {
  name:"m3",
  from:"g_3",
  to: "g_3",
  map:
    [[1,1],
     [2,3],
     [3,4],
     [4,2]]
}