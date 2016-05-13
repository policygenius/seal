#!/usr/bin/env ruby

require './lib/seal'

Seal.new(team: ARGV[0], mode: ARGV[1]).bark
