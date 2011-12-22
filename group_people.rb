#
# Creating People Groups Using Genetic Algorithms (By Their Similar Interests) 
# Copyright (c) 2011 Serdar Yildirim [me@serdaryildirim.com]
#

# Main class that uses Genetic Algorithm to create new generations on a population
# Population size, Generation count, Crossover and Selection type, Mutation Rate and
# some more constant values can be changed to see the effects on the program
# CROSSOVER_TYPE and SELECTION_TYPE constants may have different values, you can see the options near the constant values
require './person'
require './group'
require './chromosome'
require './population'
require './interest'
class GroupPeople
  # Constants used in GA
  POPULATION_SIZE = 20
  GENERATION_COUNT = 100
  USE_ELITISM_ON_CHOROMOSOMES = true
  CROSSOVER_TYPE = 'uniform' # options: '1point' '2point' 'uniform'
  SELECTION_TYPE = 'rank_selection' # options: 'random' 'rank_selection'
  MUTATION_RATE = 3 # 3%
  GROUP_SIZE = 4 # LIMITATION: People size MUST be divided to GROUP_SIZE. There is no check to prevent errors yet.
  
  # Generates a new population
  def initialize(people)
    generate_population people
  end
  
  # Creates generations
  def run
    create_generations
  end
 
  private
  # Generates a new population and creates new chromosomes by initial people
  def generate_population(people)
    @population = Population.new(POPULATION_SIZE, GROUP_SIZE)
    @population.generate_initial_population people
  end
  
  # Main method that loops as many as GENERATION_COUNT constant.
  # Calls make_generation method of population and creates a new population,
  # Outputs the best chromosome (Max Fitness Value Chromosome) to the console
  def create_generations
    @population.display_population true
      
    start_time = Time.now
    puts "Generation Creation Started..."
    print "Generation: "
    GENERATION_COUNT.times do |generation|
      print "#{generation+1}"
      
      @population = @population.make_generation USE_ELITISM_ON_CHOROMOSOMES, CROSSOVER_TYPE, MUTATION_RATE, SELECTION_TYPE
      
      print " - BF(#{@population.find_best_chromosome.fitness_value}), "
      #@population.display_chromosomes
      #@population.display_population true
    end 
    
    puts
    puts
    @population.display_chromosomes
    puts "Generations are created in #{Time.now - start_time} seconds."
  end
end