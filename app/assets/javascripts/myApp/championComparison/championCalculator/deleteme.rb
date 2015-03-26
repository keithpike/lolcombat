baseAttackSpeed =  524.4 #0.625 #20.88 6
growth =   80 #(baseAttackSpeed * (2.11 / 100.0)) #3.5 0.8
level = 8

# def getStatAfterGrowth(base, perLevelChange, level)
# 	base + perLevelChange * ((7.0 / 400) * level**2) + (267.0 / 400) * level - (137.0 / 200)
# end
def getStatAfterGrowth(base, growth, level)
	base + 0.65 * growth * (level - 1) + 0.035 * growth * (1.5 + (0.5 * level - 0.5)) * (level-1)
end

puts getStatAfterGrowth(baseAttackSpeed, growth, level)
#puts "#{base} + #{perLevelChange * ((7.0 / 400)} + #{(267.0 / 400) * level} - #{(137.0 / 200)}"
