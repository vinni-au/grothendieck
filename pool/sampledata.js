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

c4 = {
  name: "c_4",
  elements: [1, "i", -1, "-i"],
  neutral:1,
  operation:
    [[1, "i", -1, "-i"],
    ["i", -1, "-i", 1],
    [-1, "-i", 1, "i"],
    ["-i", 1, "i", -1]]
}

c2 = {
  name: "c_2",
  elements: [0,1],
  neutral: 0,
  operation:
    [[0, 1],
     [1, 0]]
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