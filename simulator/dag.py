def jct(stage, index, graph, parallel, sched, stage_lat, latmatrix, jcttable):
  
  if jcttable.has_key((stage, index)):
    return jcttable[(stage, index)]
  
  max_jct = 0

  for (child_stage, data) in graph[stage]:
    for p in range(parallel[child_stage]):
      max_jct = max(max_jct,
                    jct(child_stage, p, graph, parallel, sched,latmatrix, jcttable) + 
                    (data / (parallel[stage] * parallel[child_stage])) *
                    latmatrix[sched[stage][index]][sched[child_stage][p]]
                   )

  jcttable[(stage, index)] = max_jct + stage_lat[stage] / parallel[stage]

  return jcttable[(stage, index)]


def compute_jct(graph, parallel, sched, stage_lat, latmatrix):
  
  jcttable = {}

  for stage in graph:
    for index in range(parallel[stage]):
      if not jcttable.has_key((stage, index)):
        jct(stage, index, graph, parallel, sched, stage_lat, latmatrix, jcttable)

  return jcttable