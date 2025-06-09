extends Node2D

@export var Individuals:Array
@export var MainScene: PackedScene

func createRandom():
var reflexMatrix = []
for i in range(16):
reflexMatrix.append(randf() - 0.5)
return reflexMatrix

class Individual extends Object:
func _init(genes, name):
self.genes = genes
self.name = name

var name = ""
var genes = []
var representation:Area2D = null
var score = -1
var bestScore = 0

func getScore(score):
self.score = score
print(self.score)
printerr("got score")
if score > self.bestScore:
self.bestScore = score
self.gotScore.emit(self)

signal gotScore(individual:Individual)

func shallowCopy(ind):
var new_Ind = Individual.new(ind.genes.duplicate(), ind.name + "I")
new_Ind.bestScore = ind.bestScore
return new_Ind

func Ind_got_score(ind):
var count = 0
for i in Individuals:
if i.score < 0:
count += 1
if count == 0:
printerr("done scoring")
newGeneration()

var subViews = []
var numberOfIndividuals = 0

func select(population):
population.sort_custom(func(a, b): return a.score > b.score)
var chosen = []
chosen.append(population[0])
while chosen.size() < int(len(population) / 2):
var a = population[randi_range(0, population.size() - 1)]
var b = population[randi_range(0, population.size() - 1)]
chosen.append(a if a.score > b.score else b)
return chosen

func cross(population):
var children = []
children.append(population[0])
while children.size() < subViews.size():
var parent1 = population[randi_range(0, population.size() - 1)]
var parent2 = population[randi_range(0, population.size() - 1)]
var start = randi_range(0, 15)
var end = randi_range(start, 15)
var childGenes = []
for i in range(16):
if i >= start and i <= end:
childGenes.append(parent1.genes[i])
else:
childGenes.append(parent2.genes[i])
var child = Individual.new(childGenes, "child_" + str(numberOfIndividuals))
numberOfIndividuals += 1
children.append(child)
return children

func mutate(population):
for i in range(2):
var ind = population[randi_range(0, population.size() - 1)]
for j in range(2):
var index = randi_range(0, 15)
ind.genes[index] = randf() - 0.5
ind.name += "M"
return population

func newGeneration():
var population = []
Individuals.sort_custom(func(a, b): return a.score > b.score)
for i in Individuals:
population.append(shallowCopy(i))
population = mutate(cross(select(population)))
reset(population)

func reset(population):
for v in subViews:
for n in v.get_children():
v.remove_child(n)
n.queue_free()
Individuals = []
for i in range(len(subViews)):
var ms = MainScene.instantiate()
var ind = population[i]
ind.representation = ms
Individuals.append(ind)
ind.gotScore.connect(Ind_got_score)
ms.reflexMatrix = ind.genes
ms.gameover.connect(ind.getScore)
ms.NameLabel = ind.name
ms.BestScore = ind.bestScore
subViews[i].add_child(ms)

func _ready():
seed(43)
var gridchildren = $GridContainer.get_children()
subViews = []
for g in gridchildren:
subViews.append(g.get_child(0))
var population = []
var i = 0
for m in subViews:
population.append(Individual.new(createRandom(), "{" + str(i) + "}"))
i += 1
numberOfIndividuals += 1
reset(population)

func _process(delta):
pass


