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
      @current_generation << name if validates(name)# && is_available(name)
    end while @current_generation.size < 200
  end

  def validates(name)
    return false unless @allowed_patterns.include? name.patternize
    
    #regole per l'inizio della parola
    return false if name =~ /^m[drf]/
    return false if name =~ /^r[f]/
    return false if name =~ /^x/
    return false if name =~ /^b[^aeiouhlry]/
    return false if name =~ /^c[^aeiouhlnrsty]/
    return false if name =~ /^d[^aeiouhjnrsvy]/
    return false if name =~ /^f[^aeiouhjlnrsty]/
    return false if name =~ /^g[^aeiouhlnrwy]/
    return false if name =~ /^h[^aeiouy]/
    return false if name =~ /^j[^aeiouhr]/
    return false if name =~ /^k[^aeiouhlnrswy]/  
    return false if name =~ /^l[^aeioujy]/
    return false if name =~ /^m[^aeiouhrswy]/
    return false if name =~ /^n[^aeiouhrswy]/
    return false if name =~ /^p[^aeioufhjlnrstwy]/
    #la regola della q è overridata piu avanti# return false if name =~ /^q[^aeiou]/ 
    return false if name =~ /^r[^aeiouhky]/
    return false if name =~ /^s[^aeioubcdfghklmnpqrtuvwy]/
    return false if name =~ /^t[^aeiouhrswyz]/
    return false if name =~ /^[vw][^aeiouhlnry]/    
    return false if name =~ /^x[^aeiouhsy]/
    return false if name =~ /^y[^aeiouhlmn]/
    return false if name =~ /^z[^aeiouhjlrwy]/
    
    #coppie di consonanti da evitare
    return false if name =~ /cx/    
    return false if name =~ /lx/
    return false if name =~ /np/
    return false if name =~ /pm/
    return false if name =~ /sr/
    return false if name =~ /zd/
    return false if name =~ /d[fgk]/
    return false if name =~ /k[wpg]/
    return false if name =~ /m[gfl]/
    return false if name =~ /p[dwzt]/
    return false if name =~ /t[fp]/
    return false if name =~ /v[x]/
    return false if name =~ /w[x]/

    #regole per le coppie di lettere all'interno della parola        
    return false if name =~ /b[^aeiourlsbn]/
    return false if name =~ /g[^aeiourhlg]/
    return false if name =~ /q[^uq]/
    return false if name =~ /z[^aeiouz]/

    return false if name =~ /[^aeiou]k[^aeiou]/

    #blacklist
    return false if name =~ /kaco/
    return false if name =~ /caco/
    return false if name =~ /cako/
    return false if name =~ /kako/
    return false if name =~ /fica/
    return false if name =~ /fika/
    


    %w(w j k z x q).each do |i|
      return false if name.gsub(/[^#{i}]/, '').size > 1
    end

    return false if name.gsub(/[^wjkzxq]/, '').size > 2
    
    return true
  end
  
  def is_available(name)
  
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

g.current_generation.sort.in_groups_of(8) {|a| puts a.join "   "}


