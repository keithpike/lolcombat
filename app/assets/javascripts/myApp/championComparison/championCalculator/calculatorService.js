/**
* myApp.services.championDpsCalculator Module
*
* Description
*/
angular.module('services.championDpsCalculator', ['models.items', 'models.champions'])
	.service('ChampionDpsCalculator', ['ItemsModel', 'ChampionsModel', function(itemsModel, championsModel){
		var model = this,
				currentTime;

		model.getDpsInfo = function(champions, items, levels, timeframe) {
			var dpsInfo = {};
			var firstChampion = setupChampion(champions[0], items[0], levels[0]);
			var secondChampion = setupChampion(champions[1], items[1], levels[1]);
			currentTime = 0;
			debugger
			simulateSimpleDps(firstChampion, secondChampion, timeframe);

		};

		model.test = function(champions, items, levels) {
			model.getDpsInfo(champions, items, levels, 10.0);
			console.log(calculateAfterResistDamageMultiplier(150, 26, .2, 25, .2));
		};

		function setupChampion(champion, items, level) {
			var newChampion = {};
			angular.extend(newChampion, championDefaultValues());
			addChampionStats(newChampion, champion, level);
			addItemStats(newChampion, items);
			addActions(newChampion, champion);
			return newChampion;
		}

		// TODO: calculate placement within eventsByTime based on time when it
		// effects the target
		function simulateSimpleDps(firstChampion, secondChampion, timeframe) {
			//calculates trades over a timeframe using greedy algorithm
			var eventsByTime = [],
					activeChampion = firstChampion,
					receivingChampion = secondChampion,
					ability,
					abilityUsageEvents;

			while (currentTime < timeframe) {
				if (checkChampionAvailable(firstChampion)) {
					ability = findBestAvailableAbility(firstChampion, secondChampion);
					debugger
					abilityUsageEvents = useAbility(ability, firstChampion, secondChampion);
					// eventsByTime.push();
				}	else if (checkChampionAvailable(secondChampion)) {
					ability = findBestAvailableAbility(secondChampion);
					// eventsByTime.push(useAbility(ability, secondChampion, firstChampion));
				} else {
					// handleEvent(eventsByTime)
				}
				currentTime = 100;
			}

		}

		function useAbility(ability, user, target) {
			var events = [];
			events.push(updateChampionAvailability(user, ability));
			events.push()
		}

		function updateChampionAvailability(champion, ability) {
			champion.nextAvailable = nextAvailable(ability.animationLockout) > champion.nextAvailable ? nextAvailable(ability.animationLockout) : champion.nextAvailable;
			ability.animationLockout;
		}

		function nextAvailable(lockout) {
			return currentTime + lockout;
		}

		function checkChampionAvailable(champion) {
			return champion.nextAvailable <= currentTime;
		}

		// TODO calculate for tickDamage as well as initial damage
		// add damage types for abilities, buffs, and ticks
		function findBestAvailableAbility(user, target) {
			debugger
			var bestAbility,
					bestDamage = 0;

			angular.forEach(user.actions, function(ability) {
				if (checkAbilityAvailability(ability) && bestDamage < ability.initialDamage) {
					bestDamage = calculateEffectiveDamage(ability.initialDamage, user, target);
					bestAbility = ability;
				} 
			});
			debugger
			return bestAbility;
		}

		function calculateEffectiveDamage(damage, user, target) {
			var resist = target.stats.baseArmor + target.stats.bonusArmor,
			//TODO: loop through debuffs and user.stats
			//to get resist reduction, and percentResistReduction
					resistReduction = 0,
					percentResistReduction = 0,
					resistPenetration = user.stats.bonusArmorpenetration,
					percentResistPenetration = user.stats.bonusPercentarmorpenetration;
			var effectiveResist = calculateEffectiveResist(	resist,
																											resistReduction,
																											percentResistReduction,
																											resistPenetration,
																											percentResistPenetration);
			return calculateDamage(damage, effectiveResist);
		}

		function calculateDamage(damage, resist) {
			if (resist >= 0) {
				return damage * (100 / (100 + resist));
			} else {
				return damage * (2 - (100 / (100 - resist)));
			}
		}

		function checkAbilityAvailability(ability) {
			return ability.nextAvailable <= currentTime;
		}

		function championDefaultValues() {
			return {
							'nextAvailable': 0,
							'attackSpeedDebuffs': [],
							'autoAttackModifiers': [],	
							'stats': {
								'baseHp': 0,
								'baseMp': 0,
								'baseMovespeed': 0,
								'baseArmor': 0,
								'baseSpellblock': 0,
								'baseAttackrange': 0,
								'baseHpregen': 0,
								'baseMpregen': 0,
								'baseCrit': 0,
								'baseCritdamage': 0,
								'baseAttackdamage': 0,
								'baseAttackspeed': 0,
								'bonusHp': 0,
								'bonusMp': 0,
								'bonusMovespeed': 0,
								'bonusArmor': 0,
								'bonusSpellblock': 0,
								'bonusAttackrange': 0,
								'bonusHpregen': 0,
								'bonusMpregen': 0,
								'bonusCrit': 0,
								'bonusCritdamage': 0,
								'bonusAttackdamage': 0,
								'bonusAttackspeed': 0,
								'bonusAbilitypower': 0,
								'bonusArmorpenetration': 0,
								'bonusPercentarmorpenetration': 0,
								'bonusSpellpenetration': 0,
								'bonusPercentspellpenetration': 0,
								'bonusCooldownreduction': 0,
								'bonusLifesteal': 0,
								'bonusSpellvamp': 0,
								'bonusPercentmovespeed': 0,
							},
							'actions': {
								'autoAttack': {
									'name': 'autoAttack',
									'initialDamage': 0,
									'tickDamage': 0,
									'duration': 0,
									'animationLockout': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0,
								},
								'ability1': {
									'name': '',
									'initialDamage': 0,
									'tickDamage': 0,
									'duration': 0,
									'animationLockout': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0
								},
								'ability2': {
									'name': '',
									'initialDamage': 0,
									'tickDamage': 0,
									'duration': 0,
									'animationLockout': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0
								},
								'ability3': {
									'name': '',
									'initialDamage': 0,
									'tickDamage': 0,
									'duration': 0,
									'animationLockout': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0
								},
								'ability4': {
									'name': '',
									'initialDamage': 0,
									'tickDamage': 0,
									'duration': 0,
									'animationLockout': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0
								},
							},
			}
		}

		function addActions(champion, base) {
			angular.extend(champion.actions, createActionList(champion, base));
		}

		// TODO: add abilities and actionable items check
		function createActionList(champion, base) {
				var actions = {};
				angular.extend(actions, getAbilityAttributes(champion, champion.actions.autoAttack, true));

				// angular.forEach(champion.actions, function(ability, idx) {
				//	angular.extend(champion.actions)
				// 	angular.extend(champions[idx], createAction(ability))
				// });
				// });
				return actions;
		}

		function getAbilityAttributes(champion, ability, initialSetup) {
			var damage = calculateAbilityDamage(champion.stats, ability);
			var abilityLockout = calculateAbilityAvailability(champion.stats, ability);

			var lastCast = initialSetup ? 0 : ability.lastCast;
			var nextAvailable = initialSetup ? 0 : calculateAbilityNextAvailablity(ability, abilityLockout);

			// TODO: implement per champion ability and auto attack animation times
			var animationLockout = calculateAnimationLockout(champion, ability);
			var stunDuration = 0;
			
			// calculateAnimationLockout(getAnimationTime(champion, 'autoAttack'))
			return {'autoAttack': {
														 'name': 'autoAttack',
														 'crittable': true,
														 'initialDamage': damage,
														 'tickDamage': 0,
														 'tickDuration': 0,
														 'animationLockout': animationLockout,
														 'lastCast': lastCast,
														 'nextAvailable': nextAvailable,
														 'abilityLockout': abilityLockout,
														 'stunDuration': stunDuration,
														 'debuffs': []
														}};
		}

		// TODO: get information on specific abilities and champions for accurate
		// animation lockout times (assumed to scale based on attack speed for autoAttacks)
		function calculateAnimationLockout(champion, ability) {
			return .2;
		}

		// TODO: add check for effect bonuses and champion passive bonuses
		// Setup to use functions for finding the stat and coefficient to use for base damage
		// CURRENTLY ONLY CALCULATES AUTOATTACKS with no modifiers
		function calculateAbilityDamage(stats, ability) {
			// TODO: add 
			var baseDamage = stats.baseAttackdamage + stats.bonusAttackdamage;
			var critDamage = (stats.baseAttackdamage + stats.bonusAttackdamage) * (stats.Critdamage + stats.bonusCritdamage);
			var critChance = stats.crit + stats.bonusCrit;
			return ability.crittable ? baseDamage + critDamage * critChance : baseDamage;
		}

		// TODO: Setup to use function to find delay based on ability
		// CURRENTLY ONLY SETS A DELAY FOR AUTO ATTACKS
		function calculateAbilityAvailability(stats, ability) {
			var delay = 1.0 / stats.attackspeed
			return delay;
		}

		function calculatePercentDelayRemaining(ability) {
			var remaining = (ability.nextAvailable - currentTime) / (ability.nextAvailable - ability.lastCast) * 1.0;
			return remaining <= 0 ? 0 : remaining; 
		}

		function calculateAbilityNextAvailability(ability, newLockout) {
			return currentTime + newLockout * calculatePercentDelayRemaining(ability);
		}


		// TODO //
		function createAction(name) {
			// damage, animationLockout, abilityLockout, stunDuration, nextAvailable
			return { name: '' };
		}



		function addChampionStats(champion, base, level) {
			angular.extend(champion.stats, getChampionStats(base, level));
		}

		function getChampionStats(champion, level) {
			var championBaseStats = championsModel.getChampionStats(champion);
			var championStats = {};
			angular.extend(championStats, getHp(championBaseStats, level));
			angular.extend(championStats, getMp(championBaseStats, level));
			angular.extend(championStats, getMovespeed(championBaseStats, level));
			angular.extend(championStats, getArmor(championBaseStats, level));
			angular.extend(championStats, getSpellblock(championBaseStats, level));
			angular.extend(championStats, getAttackrange(championBaseStats, level));
			angular.extend(championStats, getHpregen(championBaseStats, level));
			angular.extend(championStats, getMpregen(championBaseStats, level));
			angular.extend(championStats, getCrit(championBaseStats, level));
			angular.extend(championStats, getCritdamage(championBaseStats, level));
			angular.extend(championStats, getAttackdamage(championBaseStats, level));
			angular.extend(championStats, getBonusAttackspeed(championBaseStats, level));
			angular.extend(championStats, {'baseAttackspeed' : getBaseAttackspeed(championBaseStats.attackspeedoffset)});
			angular.extend(championStats, getAttackspeed(championStats, []));
			return championStats;
		}

		function addItemStats(champion, items) {
			addStatsToChampion(champion.stats, getItemStats(items));
			updateChampionAttackSpeed(champion);
		}

		function updateChampionAttackSpeed(champion) {
			angular.extend(champion.stats, getAttackspeed(champion.stats, champion.attackSpeedDebuffs));
		}

		function addStatsToChampion(stats, statsToAdd) {
			for ( var key in statsToAdd) {
				stats[key] += statsToAdd[key];
			};
		}


		// TODO: implement effect handling for items in terms of stats
		function getItemStats(items) {
			var bonusStats = {};
			angular.forEach(items, function(item) {
				var itemStats = itemsModel.getItemStats(item);

				// TODO: implement effect handling for items
				// checkEffectsForStats(item);

				for ( var key in itemStats) {
					bonusStats[key] = bonusStats[key] ? ((bonusStats[key] * 100) + (itemStats[key] * 100)) / 100 : itemStats[key];
				};
			});
			return bonusStats;
		}

		// calculates effective resistance after deductions
		function calculateEffectiveResist(resist,
																			resistReduction,
																			percentResistReduction,
																			resistPenetration,
																			percentResistPenetration) {
			var effectiveResist = (resist - resistReduction);
			if (effectiveResist > 0){
				effectiveResist = effectiveResist * (100 - percentResistReduction * 100) / 100;
			}
			effectiveResist = Math.min(effectiveResist, effectiveResist * (100 - percentResistPenetration * 100));

			if (effectiveResist <= 0.0) {
			} else if(effectiveResist - resistPenetration <= 0.0) {
				effectiveResist = 0;
			} else {
				effectiveResist = effectiveResist - resistPenetration;
			}
			return effectiveResist;
		}

		function getEffectiveArmor(armor, armorReduction, percentArmorReduction, armorPenetration, percentArmorPenetration) {
			return { 'effectiveArmor' : calculateAfterResistDamageMultiplier(armor, armorReduction, percentArmorReduction, armorPenetration, percentArmorPenetration) };
		}

		function getEffectiveSpellblock(spellblock, spellblockReduction, percentSpellblockReduction, spellblockPenetration, percentSpellblockPenetration) {
			return { 'effectiveSpellblock' : calculateAfterResistDamageMultiplier(spellblock, spellblockReduction, percentSpellblockReduction, spellblockPenetration, percentSpellblockPenetration) };
		}

		function getHp(stats, level) {
				return { 'baseHp': getStatAfterGrowth(stats.hp, stats.hp_per_level, level) };
		}
		
		function getMp(stats, level) {
				return { 'baseMp' : getStatAfterGrowth(stats.mp, stats.mp_per_level, level) };
		}

		function getMovespeed(stats, level) {
				return { 'baseMovespeed' : stats.movespeed };			
		}

		function getArmor(stats, level) {
				return { 'baseArmor' : getStatAfterGrowth(stats.armor, stats.armor_per_level, level) };
		}

		function getSpellblock(stats, level) {
				return { 'baseSpellblock' : getStatAfterGrowth(stats.spellblock, stats.spellblock_per_level, level) };	
		}

		function getAttackrange(stats, level) {
				return { 'baseAttackrange' : stats.attackrange };
		}

		function getHpregen(stats, level) {
				return { 'baseHpregen' : getStatAfterGrowth(stats.hpregen, stats.hpregen_per_level, level) };
		}

		function getMpregen(stats, level) {
				return { 'baseMpregen' : getStatAfterGrowth(stats.mpregen, stats.mpregen_per_level, level) };
		}

		function getCrit(stats, level) {
				return { 'baseCrit' : getStatAfterGrowth(stats.crit, stats.crit_per_level, level) };	
		}

		function getCritdamage(stats, level) {
				return { 'baseCritdamage' : 1.00 };	
		}

		function getAttackdamage(stats, level) {
				return { 'baseAttackdamage' : getStatAfterGrowth(stats.attackdamage, stats.attackdamage_per_level, level) };
		}

		// gets bonusAttackSpeed from levels in #.##
		function getBonusAttackspeed(stats, level) {
				var baseAttackSpeed = getBaseAttackspeed(stats.attackspeedoffset);
				var bonusAttackSpeed = getPerLevelChange(stats.attackspeed_per_level / 100.0, level);
				// var attackSpeed = getStatAfterGrowth( baseAttackSpeed, baseAttackSpeed * (stats.attackspeed_per_level / 100.0), level);
				return { 'bonusAttackspeed' : bonusAttackSpeed };
		}

		function getAttackspeed(stats, debuffs) {
			return { 'attackspeed' : getModifiedAttackSpeed(stats.baseAttackspeed, stats.bonusAttackspeed, debuffs) };
		}

		// Calculate the current value of stat based on level
		function getStatAfterGrowth(base, perLevelChange, level) {
			return base + getPerLevelChange(perLevelChange, level);
		}

		function getPerLevelChange(perLevelChange, level) {
			return 0.65 * perLevelChange * (level - 1) + 0.035 * perLevelChange * (1.5 + (0.5 * level - 0.5)) * (level - 1);
		}

		// Calculate the base attack speed for champion in attacks/second
		function getBaseAttackspeed(offset) {
			return 0.625 / (1 + offset);
		}

		// calculate current attack speed of champion based on base attack speed and attack speed bonuses
		// in attacks per second
		function getModifiedAttackSpeed(baseAttackSpeed, bonusAttackSpeed, attackSpeedDebuffs) {
			var debuffedAttackSpeed = 1;
			angular.forEach(attackSpeedDebuffs, function(debuff) {
				debuffedAttackSpeed = debuffedAttackSpeed * (((1.0 * 100) - (debuff * 100)) / 100);
			});
			return (baseAttackSpeed * (1 + bonusAttackSpeed)) * debuffedAttackSpeed;
		}

	}]);