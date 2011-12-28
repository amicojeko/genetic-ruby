#!/usr/bin env ruby

require "rubygems"
require "bundler/setup"
require "redis"

class String
  def vowel?
    self =~ /[aeiouy]/i
  end

  def consonant?
    self =~ /[^aeiouy]/i
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

R = Redis.new
patterns = {}

foo = File.readlines('6i.txt')
foo.collect! {|line| line.split}
foo.flatten!
foo.each do |w|
  pattern = w.split('').collect do |l|
    if l.vowel?
      "v"
    else
      "c"
    end
  end.join

  R.zincrby("patterns-it", 1, pattern)
  puts pattern
end
