# -*- coding: utf-8 -*-
require "rubygems"
require "bundler/setup"
require "./random"

class Generator
  attr_reader :current_generation

  def random_name(n = 7)
    # The seed file gets read and rewritten
    # it is generated manually from random.org
    # so when it's over please refill it
    result = ""
    n.times do |i|
      begin
        seed = @random_seeds.shift
      rescue TypeError
        refill_seeds
        seed = @random_seeds.shift
      end
      seed = rand(36) if seed.nil?
      if i == n - 1
        result << @vowels[seed % @vowels.size]
      elsif i % 2 == 0
        result << @consonants[seed % @consonants.size]
      else
        result << @vowels[seed % @vowels.size]
      end
    end
    File.open('seeds.txt', 'w') do |f|
      f.write(@random_seeds.join("\n"))
    end
    result
  end

  def refill_seeds
    client = RandomOrgClient.new('intinig@gmail.com')
    if seeds = client.get_random_integer(10000, 0, 35)
      @random_seeds = seeds.split.collect {|i| i.to_i}
      File.open('seeds.txt', 'w') do |f|
        f.write seeds
      end
    else
      # fallback to normal numbers
      @random_seeds = []
      10000.times do |i|
        @random_seeds << rand(36)
      end
    end
  end

  def initialize(n = 200)
    @allowed_chars = ('a'..'z').to_a + (0..9).to_a.collect {|i| i.to_s}
    @vowels = %w(a e i o u)
    @consonants = ('a'..'z').to_a - @vowels - ['q']
    @current_generation = []
    @random_seeds = File.readlines('seeds.txt').collect {|i| i.to_i}

    refill_seeds if @random_seeds.size < 5000

    begin
      name = random_name
      @current_generation << name if validates(name)
    end while @current_generation.size < 200
  end

  def validates(name)
    return false unless name =~ /k/
    return false if name =~ /.+ch.+/
    return false if name[-1] == name[-2]
    %w(w j k z x).each do |i|
      return false if name.gsub(/[^#{i}]/, '').size > 1
    end
    numbers = name.gsub(/\D/,'').size
    return false if numbers > 2

    if numbers == 2
      num = (name =~ /\d{2}/)
      return false unless num
      return false unless num == 0 || num == 5
    end

    if numbers == 1
      num = (name =~ /\d/)
      return false unless num == 0 || num == 6
    end

    vowels = name.gsub(/[^aeiou]/,'').size
    return false unless vowels >= 2 and vowels <= 4

    true
  end
end

g = Generator.new

puts g.current_generation.inspect
