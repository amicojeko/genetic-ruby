# -*- coding: utf-8 -*-
require "rubygems"
require "bundler/setup"
require "whois"
require "active_support/core_ext/array/grouping"

class String
  def vowel?
    self =~ /[aeiou]/i
  end

  def consonant?
    self =~ /[^aeiou]/i
  end

  def patternize
    self.split('').collect do |l|
      if l.vowel?
        "v"
      else
        "c"
      end
    end.join
  end
end

class Generator
  attr_reader :current_generation

  def initialize(n = 200)
    @allowed_chars = ('a'..'z').to_a - ['j', 'y'] # + (0..9).to_a.collect {|i| i.to_s}
    @allowed_patterns = %w(cvcvcv ccvccv vccvcv cvccvv vcvccv cvvccv cvcccv ccvvcv ccvcvv vcvvcv)
    @vowels = %w(a e i o u)
    @consonants = ('a'..'z').to_a - @vowels
    @current_generation = []

    begin
      name = @allowed_chars.sample(6).join
      @current_generation << name if validates(name)
    end while @current_generation.size < 200
  end

  def validates(name)
    return false unless @allowed_patterns.include? name.patternize
    return false if name =~ /q[^u]/
    return false if name =~ /np/
    return false if name =~ /dg/
    return false if name =~ /^x/
    return false if name =~ /pz/
    return false if name =~ /cx/
    return false if name =~ /xd/
    return false if name =~ /ml/
    return false if name =~ /pm/
    return false if name =~ /zd/
    return false if name =~ /g[^aeiourhlg]/
    return false if name =~ /b[^aeiourlsbn]/
    return false if name =~ /z[^aeiouz]/
    return false if name =~ /[^aeiou]k[^aeiou]/

    return false if name =~ /kaco/
    return false if name =~ /caco/
    return false if name =~ /cako/
    return false if name =~ /kako/

    %w(w j k z x q).each do |i|
      return false if name.gsub(/[^#{i}]/, '').size > 1
    end

    return false if name.gsub(/[^wjkzxq]/, '').size > 2

    begin
      r = Whois.query "#{name}.com"
    rescue
      puts "WHOIS ERROR #{name}.com"
      return false
    end

    if r.available?
      puts "AVAILABLE (#{@current_generation.size}/200): #{name}.com"
    else
      puts "UNAVAILABLE: #{name}.com"
    end
    return r.available?
  end
end

g = Generator.new

g.current_generation.sort.in_groups_of(5) {|a| puts a.join "   "}
