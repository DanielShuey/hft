class Ga
  pool_size = 100
  mutation = 0.1
  iterations = 100
  
  def score
    #profit
  end

  #population
  #matingpool
  #individual
  #genome, mutate, fuse, create_random
  #crossover
end

=begin
TARGET = 'one fish two fish red fish blue fish'

rand = (min, max) ->
  Math.round(Math.random() * (max - min) + min)

class DNA
  constructor: ->
    @genes = []
    for i in [0...TARGET.length]
      @genes.push(String.fromCharCode(rand(32,128)))

  process_fitness: ->
    score = 0
    for i in [0...@genes.length]
      if @genes[i] == TARGET.charAt(i)
        score++

    @fitness = score / TARGET.length

  code: ->
    @genes.join('')

  crossover: (partner) ->
    child = new DNA()
    midpoint = rand(0, TARGET.length - 1)
    for i in [0...@genes.length]
      if i > midpoint
        child.genes[i] = @genes[i]
      else
        child.genes[i] = partner.genes[i]
    return child

  mutate: ->
    for i in [0...@genes.length]
      if Math.random() < 0.01
        @genes[i] = String.fromCharCode(rand(32,128))
      undefined

draw = ->
  for i in [0...population.length]
    population[i].process_fitness()

  matingPool = []

  for i in [0...population.length]
    n = population[i].fitness * 100
    for j in [0...n]
      matingPool.push(population[i])

  for i in [0...population.length]
    a = rand(0,matingPool.length-1)
    b = rand(0,matingPool.length-1)
    partnerA = matingPool[a]
    partnerB = matingPool[b]
    child = partnerA.crossover(partnerB)
    child.mutate()
    population[i] = child

  population.sort((a,b) ->
    a.process_fitness()
    b.process_fitness()
    return -1 if a.fitness > b.fitness
    return 1 if a.fitness < b.fitness
    return 0
  )

  return population[0]

population = []
for i in [0...500]
  population.push(new DNA())

count = 0

while true
  result = draw()
  console.log(result.code())
  count++
  break if result.code() == TARGET

console.log count
=end

=begin

require("better-stack-traces").install(
  before: 4
  after: 4
  maxColumns: 80
  collapseLibraries: /usr\/lib/
)

rand = (min, max) ->
  Math.round(Math.random() * (max - min) + min)

zip = () ->
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  for i in [0...length]
    arr[i] for arr in arguments

class Trait
  constructor: (options) ->
    @mutationRate = options['mutationRate']
    @target       = options['target']

class MatingPool
  constructor: (population) ->
    @population = population
    @pool       = []
    (@pool.push i.bucket()...) for i in @population

  sample:  -> @pool[rand(0,@pool.length-1)]
  perform: -> (@sample().crossover @sample()).mutate() for i in [0...@population.length]

class Population
  constructor: (options) -> @population = (Individual.random(options['target'].size(), new Trait(options)) for i in [0...(options['size'])])

  reproduce: -> @population = new MatingPool(@population).perform()
  fittest:   ->
    @population.reduce((a,b) -> (if a.fitness < b.fitness then a else b))

class Individual
  constructor: (genome, trait) ->
    @trait = trait
    @genome = genome

  @random: (size, trait) -> new Individual(Genome.random(size), trait)
  bucket:  -> (this for fitness in [0...@fitness()])
  mutate:  -> @genome.mutate(@trait.mutationRate); this
  score:   -> zip(@genome.genes, @trait.target.genes).filter((x) -> x[0].value == x[1].value).length
  fitness: -> (@score() / @genome.size()) * 100
  crossover: (partner) ->
    midpoint = rand(0, @genome.size() - 1)
    new Individual(Genome.fuse(@genome.split(midpoint)[0], partner.genome.split(midpoint)[1]), @trait)

class Genome
  constructor: (genes) -> @genes = (new Gene(gene.value) for gene in genes)
  @fuse: (left, right) -> new Genome(left.genes.concat right.genes)
  @from_code:   (code) -> new Genome(new Gene(c) for c in code.split(''))
  @random:      (size) -> new Genome(Gene.random() for i in [0...size])
  mutate:     (chance) -> gene.mutate(chance) for gene in @genes; this
  split:       (locus) -> [new Genome(@genes.slice(0,locus)), new Genome(@genes.slice(locus))]
  size:                -> @genes.length
  code:                -> @genes.map((g) -> g.value).join('')

class Gene
  constructor: (value) -> @value = value
  @random:             -> new Gene(String.fromCharCode(rand(32,128)))
  mutate:     (chance) -> @value = String.fromCharCode(rand(32,128)) if Math.random() < chance; this

pop = new Population(target: Genome.from_code('one fish two fish'), size: 500, mutationRate: 0.01)
count = 0

loop
  pop.reproduce()
  fittest = pop.fittest()
  console.log("#{fittest.genome.code()}:#{fittest.fitness()}")
  count++
  break if fittest.fitness() == 100

console.log count

=end
