/**
* myApp.services.championDpsCalculator Module
*
* Description
*/
angular.module('services.championDpsCalculator', ['models.items', 'models.champions'])
	.service('ChampionDpsCalculator', ['ItemsModel', 'ChampionsModel', function(itemsModel, championsModel){
		var model = this
		
		model.getDpsInfo = function(champions, items, levels, timeframe){
			var dpsInfo = {};
			var firstChampion = getChampionStats(champions[0], levels[0]);
			var secondChampion = getChampionStats(champions[1], level[1]);
			addItemStats(firstChampion, items[0]);
			addItemStats(secondChampion, items[1]);
			calculateSimpleDps(getChampionStats(champion, level))

		};

		function getChampionStats(champion, level) {
			var championBaseStats = ChampionsModel.getChampionStats(champion.name);
			var championStats = {};
			Angular.extend(championStats, getHp(championBaseStats, level));
			Angular.extend(championStats, getMp(championBaseStats, level));
			Angular.extend(championStats, getMovespeed(championBaseStats, level));
			Angular.extend(championStats, getArmor(championBaseStats, level));
			Angular.extend(championStats, getSpellblock(championBaseStats, level));
			Angular.extend(championStats, getAttackrange(championBaseStats, level));
			Angular.extend(championStats, getHpregen(championBaseStats, level));
			Angular.extend(championStats, getMpregen(championBaseStats, level));
			Angular.extend(championStats, getCrit(championBaseStats, level));
			Angular.extend(championStats, getAttackdamage(championBaseStats, level));
			Angular.extend(championStats, getAttackspeed(championBaseStats, level));
			Angular.extend(championStats, {'baseAttackSpeed' : getBaseAttackSpeed(championBaseStats.attackspeedoffset)})
			return championStats;
		}

		function addItemStats(champion, items) {
			Angular.forEach(items, function(item) {

			});
		}

		function calculateSimpleDps(stats, timeframe) {
			//calculates auto attack trades over a timeframe
		}

		function calculateResistReduction(	resist,
																			resistReduction,
																			percentResistReduction,
																			resistPenetration,
																			percentResistPenetration) {

			var effectiveResist = (resist - resistReduction);
			if (effectiveResist > 0){
				effectiveResist = effectiveResist * (1.0 - percentResistReduction);
			}
			effectiveResist = Math.min(effectiveResist, effectiveResist * (1 - percentResistPenetration));

			if (effectiveResist <= 0) {
				return (2 - 100.0 / (100 - effectiveResist));
			} else if(effectiveResist - resistPenetration <= 0) {
				effectiveResist = 0;
			} else {
				effectiveResist = effectiveResist - resistPenetration;
			}
			return (100.0 / (100 + effectiveResist));
		}

		function getEffectiveArmor(armor, armorReduction, percentArmorReduction, armorPenetration, percentArmorPenetration) {
			return { 'effectiveArmor' : calculateResistReduction(armor, armorReduction, percentArmorReduction, armorPenetration, percentArmorPenetration) };
		}

		function getEffectiveSpellblock(spellblock, spellblockReduction, percentSpellblockReduction, spellblockPenetration, percentSpellblockPenetration) {
			return { 'effectiveSpellblock' : calculateResistReduction(spellblock, spellblockReduction, percentSpellblockReduction, spellblockPenetration, percentSpellblockPenetration) };
		}

		function getHp(stats, level) {
				return { 'baseHp': getStatAfterGrowth(stats.hp, stats.hp_per_level, level) };
		}
		
		function getMp(stats, level) {
				return { 'baseMp' : getStatAfterGrowth(stats.mp, stats.mp_per_level, level) };
		}

		function getMovespeed(stats, level) {
				return { 'movespeed' : stats.movespeed };			
		}

		function getArmor(stats, level) {
				return { 'baseArmor' : getStatAfterGrowth(stats.armor, stats.armor_per_level, level) };
		}

		function getSpellblock(stats, level) {
				return { 'baseSpellblock' : getStatAfterGrowth(stats.spellblock, stats.spellblock_per_level, level) };	
		}

		function getAttackrange(stats, level) {
				return { 'attackrange' : stats.attackrange };
		}

		function getHpregen(stats, level) {
				return { 'baseHpregen' : getStatAfterGrowth(stats.hpregen, stats.hpregen_per_level, level) };
		}

		function getMpregen(stats, level) {
				return { 'baseMpregen' : getStatAfterGrowth(stats.mpregen, stats.mpregen_per_level, level) };
		}

		function getCrit(stats, level) {
				return { 'crit' : getStatAfterGrowth(stats.crit, stats.crit_per_level, level) };	
		}

		function getAttackdamage(stats, level) {
				return { 'baseAttackdamage' : getStatAfterGrowth(stats.attackdamage, stats.attackdamage_per_level, level) };
		}

		// 
		function getAttackspeed(stats, level) {
				var baseAttackSpeed = getBaseAttackSpeed(stats.attackspeedoffset));
				var attackSpeed = getStatAfterGrowth( baseAttackSpeed, baseAttackSpeed * (stats.attackspeed_per_level / 100.0), level) };
				return { 'attackspeed' : attackSpeed };
		}

		// Calculate the current value of stat based on level
		function getStatAfterGrowth(base, perLevelChange, level) {
			return base + 0.65 * perLevelChange * (level - 1) + 0.035 * perLevelChange * (1.5 + (0.5 * level - 0.5)) * (level - 1);
		}

		// Calculate the base attack speed for champion 
		function getBaseAttackSpeed(offset) {
			return 0.625 / (1 + stats.attackspeedoffset);
		}

		function getModifiedAttackSpeed(baseAttackSpeed, currentAttackSpeed, bonusAttackSpeed) {
			return baseAttackSpeed * (1 + bonusAttackSpeed);
		}

	}]);