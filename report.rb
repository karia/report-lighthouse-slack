#!/usr/bin/env ruby

require "json"

def internalErf_(x)
  sign = x < 0 ? -1 : 1
  x = x.abs

  a1 = 0.254829592
  a2 = -0.284496736
  a3 = 1.421413741
  a4 = -1.453152027
  a5 = 1.061405429
  p = 0.3275911
  t = 1 / (1 + p * x)
  y = t * (a1 + t * (a2 + t * (a3 + t * (a4 + t * a5))))
  return sign * (1 - y * Math.exp(-x * x))
end

def QUANTILE_AT_VALUE(median, falloff, value)
  location = Math.log(median)
  logRatio = Math.log(falloff / median)

  shape = Math.sqrt(1 - 3 * logRatio - Math.sqrt((logRatio - 3) * (logRatio - 3) - 8)) / 2;

  standardizedX = (Math.log(value) - location) / (Math.sqrt(2) * shape);
  return ((1 - internalErf_(standardizedX)) / 2)    
end

def calcScore(fcp,fmp,fci,interactive,speedindex)
  # 浮動小数点にする必要がある
  score_fcp = QUANTILE_AT_VALUE(4000.0,2000.0,fcp)
  score_fmp = QUANTILE_AT_VALUE(4000.0,2000.0,fmp)
  score_fci = QUANTILE_AT_VALUE(6500.0,2900.0,fci)
  score_i = QUANTILE_AT_VALUE(7300.0,2900.0,interactive)
  score_si = QUANTILE_AT_VALUE(5800.0,2900.0,speedindex)
  
  return (((score_fcp * 3 + score_fmp * 1 + score_fci * 2 + score_i * 5 + score_si * 4)/15 ) * 100).floor
end

hash = {}

File.open("report.json") do |j|
  hash = JSON.load(j)
end

fcp = hash['audits']['first-contentful-paint']['numericValue']
fmp = hash['audits']['first-meaningful-paint']['numericValue']
fci =  hash['audits']['first-cpu-idle']['numericValue']
interactive = hash['audits']['interactive']['numericValue']
speedindex = hash['audits']['speed-index']['numericValue']

p calcScore(fcp,fmp,fci,interactive,speedindex)
