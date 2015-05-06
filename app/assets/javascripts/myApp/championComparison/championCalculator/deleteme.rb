#file for testing certain functions quickly


baseAttackSpeed =  524.4 #0.625 #20.88 6
growth = (2.11 / 100.0) #3.5 0.8 80
level = 4

# def getStatAfterGrowth(base, perLevelChange, level)
# 	base + perLevelChange * ((7.0 / 400) * level**2) + (267.0 / 400) * level - (137.0 / 200)
# end
def getStatAfterGrowth(base, growth, level)
	base + 0.65 * growth * (level - 1) + 0.035 * growth * (1.5 + (0.5 * level - 0.5)) * (level-1)
end

puts getStatAfterGrowth(baseAttackSpeed, growth, level)
#puts "#{base} + #{perLevelChange * ((7.0 / 400)} + #{(267.0 / 400) * level} - #{(137.0 / 200)}"


# not 100% accurate function but within reason
# from testing fiddlesticks hp was off by 1HP on certain levels
def getStatAfterGrowth2(growth, level)
	0.65 * growth * (level - 1) + 0.035 * growth * (1.5 + (0.5 * level - 0.5)) * (level-1)
end

puts getStatAfterGrowth2(growth, level)
