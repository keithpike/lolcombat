/**
* myApp.services.championDpsCalculator Module
*
* Description
*/
angular.module('services.championDpsCalculator', ['models.items', 'models.champions'])
	.service('ChampionDpsCalculator', ['ItemsModel', 'ChampionsModel', function(itemsModel, championsModel){
		var model = this,
				currentTime,
				firstChampion,
				secondChampion;

		model.getDpsInfo = function(champions, items, levels, timeframe) {
			var dpsInfo = {};
			currentTime = 0;
			firstChampion = setupChampion(champions[0], items[0], levels[0], 0);
			secondChampion = setupChampion(champions[1], items[1], levels[1], 1);
			return simulateSimpleDps(firstChampion, secondChampion, timeframe);
		};

		// model.test = function(champions, items, levels) {
		// 	model.getDpsInfo(champions, items, levels, 10);
		// 	console.log(calculateAfterResistDamageMultiplier(150, 26, .2, 25, .2));
		// };

		function setupChampion(champion, items, level, id) {
			var newChampion = {};
			angular.extend(newChampion, championDefaultValues());
			addChampionId(newChampion, id);
			addChampionStats(newChampion, champion, level);
			addItemStats(newChampion, items);
			newChampion.stats.currentHp = calculateMaxHp(newChampion);
			newChampion.stats.currentMp = calculateMaxResource(newChampion);
			newChampion.resourceType = champion.resource_type;
			newChampion.lastResourceChange = currentTime;
			addActions(newChampion, champion);
			return newChampion;
		}

		// event driven battle simulation, no movement considerations currently
		// Considering events take a target no consideration is taken for multiple enemies

		// I should rewrite this to be object oriented, would make variable modification
		// significantly easier
		function simulateSimpleDps(firstChampion, secondChampion, timeframe) {
			//calculates trades over a timeframe using greedy algorithm (aka highest damage ability)
			var eventsByTime = [],
					currentEventIndex = 0,
					eventCounter = 1,
					timeframe = timeframe * 10,
					ability,
					abilityUsageEvents,
					results,
					timeChange,
					createdEvents // a temporary events holder
					;
			while (currentTime < timeframe) {
				if (checkChampionAvailable(firstChampion) && checkAnyAbilityAvailable(firstChampion)) {
					ability = findBestAvailableAbility(firstChampion, secondChampion);
					abilityUsageEvents = useAbility(ability, firstChampion, secondChampion, eventCounter);
					eventCounter = updateByArrayLength(eventCounter, abilityUsageEvents);
					angular.forEach(abilityUsageEvents, function(event) {
						bInsertEvent(event, eventsByTime, sortLowToHigh);
					});
				}	else if (checkChampionAvailable(secondChampion) && checkAnyAbilityAvailable(secondChampion)) {
					ability = findBestAvailableAbility(secondChampion, firstChampion);
					abilityUsageEvents = useAbility(ability, secondChampion, firstChampion, eventCounter);
					eventCounter = updateByArrayLength(eventCounter, abilityUsageEvents);
					
					angular.forEach(abilityUsageEvents, function(event) {
						bInsertEvent(event, eventsByTime, sortLowToHigh);
					});
				} else {
					timeChange = moveForwardInTime(eventsByTime[currentEventIndex].activationTime)
					if (currentTime < timeframe) {
						createdEvents = handleEvent(eventsByTime[currentEventIndex], eventCounter);
						angular.forEach(createdEvents, function(event){
							bInsertEvent(event, eventsByTime, sortLowToHigh);
						});
						eventCounter = updateByArrayLength(eventCounter, createdEvents);
						currentEventIndex += 1;	
					}
				}	
			}
			return parseEventsForOutput(eventsByTime);
		}

		// TODO: Remove this and bake the split of events
		// 			 into the calculateDps function at handleEvent
		//       function, this will give accurate dps numbers
		//       including debuffs/buffs then
		function parseEventsForOutput(events) {
			var damageEvents = events.filter(function(event){
				return event.type == 'application';
			});
			var firstChampionEvents = damageEvents.filter(function(event){
				return event.chart == 0;
			});

			var secondChampionEvents = damageEvents.filter(function(event){
				return event.chart == 1;
			});

			return {
				'firstChampionEvents': formatOutputForGraph(firstChampionEvents), 
				'secondChampionEvents': formatOutputForGraph(secondChampionEvents)
			}
			// 
		}

		function formatOutputForGraph(events) {
			var data = [];
			angular.forEach(events, function(event) {
				data.push({
					'y': Math.round(calculateEffectiveDamage(event.ability.initialDamage, event.ability.damageType, event.user, event.target)),
					'x': (event.activationTime / 10),
					'name': event.ability.name,
					// placeholder ability name
					'image': getImageOfAbility(event.ability.image)
				});
			});
			return data;
		}

		function getImageOfAbility(url) {
			if(url == 'autoAttack') {
				return 'https://s3-us-west-1.amazonaws.com/lolcomparitor/Images/spell/AutoAttack.png';
			} else {
				return url;
			}
			
		}

		function updateByArrayLength(val, arr) {
			return val + arr.length;
		}

		function handleEvent(event, eventCounter) {
			switch(event.type) {
				case 'application':
					return handleApplicationEvent(event.ability, event.user, event.target, eventCounter);
					break;
				case 'castAnimationEnd':
					return handleCastAnimationEndEvent();
					break;
				case 'fallOff':
					return handleFalloffEvent(event.ability, event.target, eventCounter);
					break;
				case 'activationReset':
					return handleActivationResetEvent(event.ability, event.target, eventCounter);
					break;
				case 'death':
					return []; // TODO: implement
					break;
				default:
					return handleGenericEvent(event);
					break;
			}
		}

		function handleGenericEvent(event) {
			return [];
			// moveForwardInTime(event.activationTime)
		}

		function handleApplicationEvent(ability, user, target, eventCounter) {
			// handle damage application
			// handle debuff application
			// handle creation of other events that may be caused (damage ticks not associated to debuffs)
			return [];
		}

		function handleActivationResetEvent(ability, target, eventCounter) {
			return [];
		}

		function moveForwardInTime(time) {
			var timeChange = updateTime(time);
			handleChampionsRegen(timeChange);
		}

		function updateTime(time) {
			var diff = time - currentTime;
			currentTime = time;
			return diff;
		}

		function createEvent(type, ability, user, target, eventCounter) {
			switch(type) {
				case 'application':
					ability = updateAbility(ability, user); 
					return createApplicationEvent(ability, user, target, eventCounter);
					break;
				case 'castAnimationEnd':
					return createCastAnimationEndEvent();
					break;
				case 'fallOff':
					return createFalloffEvent(ability, target, eventCounter);
					break;
				case 'activationReset':
					return createActivationResetEvent(target, ability, eventCounter);
					break;
				case 'championReady':
					return createChampionReadyEvent(target, eventCounter);
					break;
			}
		}

		// params are currently the user intend to split this into seperate params that need to be updated
		function updateAbility(ability, user) {
			return getAbilityAttributes(user, ability, false)
		}

		function createChampionReadyEvent(user, eventCounter) {
			return {
				'activationTime': user.nextAvailable,
				'id': eventCounter,
				'type': 'championReady'
			};
		}

		function createApplicationEvent(ability, user, target, eventCounter) {
			return {
				'activationTime': currentTime + ability.animationLockout,
				'id': eventCounter,
				'chart': user.id,
				'actionCauseId': 0,
				'type': 'application',
				'target': target,
				'user': user,
				'ability': ability
				// 	{
				// 	'name': ability.name,
				// 	'initialDamage': ability.initialDamage,
				// 	'tickDamage': ability.tickDamage,
				// 	'tickDuration': ability.tickDuration,
				// 	'tickRate': ability.tickRate,
				// 	'stunDuration': ability.stunDuration,
				// 	'debuffs': ability.debuffs
				// }
			}
		}

		function createActivationResetEvent(champion, ability, eventCounter) {
			return  {
				'activationTime': ability.nextAvailable,
				'id': eventCounter,
				'actionCauseId': 0,
				'type': 'activationReset',
				'target': champion,
				'ability': ability
			}
		}

		// TODO WRITE IT!
		function createFalloffEvent(ability, target, timeOffset, eventCounter) {
			return {
				'activationTime': currentTime + timeOffset,
				'id': eventCounter,
				'actionCauseId': 0,
				'type': 'fallOff',
				'target': target,
				'ability': ability
			}
		}


		function useAbility(ability, user, target, eventCounter) {
			var events = [],
					action;
			updateChampionAvailability(user, ability);
			action = createEvent("application", ability, user, target, eventCounter);
			bInsertEvent(action, events, sortLowToHigh);
			eventCounter++;
			action = createEvent("championReady", null, null, user, eventCounter)
			bInsertEvent(action, events, sortLowToHigh);
			eventCounter++;
			action = createEvent("activationReset", ability, null, user, eventCounter);
			bInsertEvent(action, events, sortLowToHigh);

			return events;
		}

		// action = {
		// 	'activationTime': 0,
		//	'id': 1
		//  'actionCauseId: 0 || id of action that caused this'
		// 	'type': '', // 'application', 'fallOff', 'activationReset'
		// 	'target': '',
		// 	'effects': {
		// 		// application
		// 			// target
		// 			// update attributes of target
		// 			// 'name': '',
		// 			// 'initialDamage': 0,
		// 			// 'tickDamage': 0,
		// 			// 'tickDuration': 0,
		// 			// 'tickRate': 0,
		// 			// 'stunDuration': 0,
		// 			// 'debuffs': [],
		// 			// 'buffs':[],
		// 		// fallOff
		// 			// target
		// 			// 'debuff'
		// 			// 'buff'
		// 			// update attributes of target
		// 		// activationReset (essentially just moves time forward)
		// 			// target (for informational purposes)
		// 	}

		// }

		function handleChampionsRegen(timeChange) {

			// TODO: Set constant for regen tick timing currently .5
			var tickAmount = calculateNumberOfTicks(timeChange, 5);
			handleChampionRegen(firstChampion, tickAmount);
			handleChampionRegen(secondChampion, tickAmount);
		}

		// perhaps add an offset so ticks don't always start at 0?
		function calculateNumberOfTicks(change, tickTiming) {
			return Math.floor((change + (currentTime - change) % tickTiming) / tickTiming);
		}

		function handleChampionRegen(champion, tickAmount) {
			var healthChange = calculateChampionHealthRegen(champion) * tickAmount;
			updateChampionHealth(champion, healthChange);
			var resourceChange = calculateChampionResourceChange(champion) * tickAmount;
			updateChampionResource(champion, resourceChange);
		}

		function calculateChampionHealthRegen(champion) {
			// TODO: add debuff handling
			return (champion.stats.baseHpregen / 5 ) * (calculateHealingDebuffs(champion.debuffs))
		}

		function calculateHealingDebuffs(debuffs) {
			var debuffedHealing = 1;
			angular.forEach(debuffs, function(debuff) {
				if (debuff.type == 'healing') {
					debuffedHealing = debuffedHealing * (((1 * 100) - (debuff.amount * 100)) / 100 );
				} 
			});
			return debuffedHealing;
		}



		function updateChampionHealth(champion, change) {
			champion.stats.currentHp = Math.min(calculateMaxHp(champion), champion.stats.currentHp + change);
		}

		// needs logic to handle calculation of changes for different resource types
		function calculateChampionResourceChange(champion) {
			switch(champion.resourceType) {
				case 'mana':
				case 'energy':
			}
			return 0;
		}

		function updateChampionResource(champion, change) {

		}

		// needs update to handle any champion that is not mana based
		function calculateMaxResource(champion) {
			return champion.stats.baseMp + champion.stats.bonusMp;
		}

		// needs update to handle certain items that have % bonusHp increases
		function calculateMaxHp(champion) {
			return champion.stats.baseHp + champion.stats.bonusHp;
		}

		function updateChampionAvailability(champion, ability) {
			// console.log(ability);
			champion.nextAvailable = (nextAvailable(ability.animationLockout) > champion.nextAvailable) ? nextAvailable(ability.animationLockout) : champion.nextAvailable;
		}

		function nextAvailable(lockout) {
			return currentTime + lockout;
		}

		function checkChampionAvailable(champion) {
			return champion.nextAvailable <= currentTime;
		}

		function checkAnyAbilityAvailable(champion) {
			var flag = false;
			angular.forEach(champion.actions, function(ability) {
				if (checkAbilityAvailability(ability)) {
					flag = true;
				} 
			});
			return flag;
		}

    function bInsertEvent(value, arr, comparer, start, end) {
			// count = count + 1;	
      start = start || 0;
      end = typeof end == 'undefined' ? arr.length - 1 : end;
			var mid = (start + end) >> 1;
			var result = comparer(value, arr[mid]);
      if (end - start <= 0) {
				if (result < 0) {
				  arr.splice(mid, 0, value);
				} else {
					arr.splice(mid + 1, 0, value);
				}
        return;
			} 
			if (result < 0) {
				return bInsertEvent(value, arr, comparer, start, mid - 1);
			} else if (result > 0) {
				return bInsertEvent(value, arr, comparer, mid + 1, end);
			} else {
				arr.splice(mid, 0 , value);
			}
		}
		
		// deals with floating points, perhaps I should modify this for consistancy
		function sortLowToHigh(a, b) {
			if (typeof a == 'undefined' || typeof b == 'undefined') { return 0;}
		 	return a.activationTime - b.activationTime;
		};

		// TODO calculate for tickDamage as well as initial damage
		// add damage types for abilities, buffs, and ticks
		function findBestAvailableAbility(user, target) {
			var bestAbility,
					bestDamage = 0;
					damage = 0;
			angular.forEach(user.actions, function(ability) {
				damage = calculateEffectiveDamage(ability.initialDamage, ability.damageType, user, target)
				if (checkAbilityAvailability(ability) && bestDamage < damage) {
					bestDamage = damage;
					bestAbility = ability;
				} 
			});
			return bestAbility;
		}

		function calculateEffectiveDamage(damage, damageType, user, target) {
			var resist = 0;
			var effectiveResist = 0;
			if (damageType == 'physical') {
				resist = target.stats.baseArmor + target.stats.bonusArmor,
			// TODO: loop through debuffs and user.stats
			// to get resist reduction, and percentResistReduction
			// Handle more then just Armor
				resistReduction = 0,
				percentResistReduction = 0,
				resistPenetration = user.stats.bonusArmorpenetration, // genericafy
				percentResistPenetration = user.stats.bonusPercentarmorpenetration; // genericafy
			} else if (damageType == 'magic') {
				resist = target.stats.baseSpellblock + target.stats.bonusSpellblock,
			// TODO: loop through debuffs and user.stats
			// to get resist reduction, and percentResistReduction
			// Handle more then just Armor
				resistReduction = 0,
				percentResistReduction = 0,
				resistPenetration = user.stats.bonusSpellpenetration, // genericafy
				percentResistPenetration = user.stats.bonusPercentspellpenetration; // genericafy
			} else {
				return damage;
			}
			effectiveResist = calculateEffectiveResist(		resist,
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

		// TODO: Remove damage requirement once non-damaging abilities are implemented
		function checkAbilityAvailability(ability) {
			return ability.initialDamage > 0 ? ability.nextAvailable <= currentTime : false;
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
								'currentHp': 0,
								'currentMp': 0,
							},
							'actions': {
								'autoAttack': {
									'name': 'autoAttack',
									'initialDamage': 0,
									'damageFormula': undefined,
								 	'damageType': 'physical',
									'coefficients': [],
									'effects': [],
									'formulas': [],
									'sanitizedTooltip': '',
									'crittable': true,
									'tickDamage': 0,
									'tickDuration': 0,
									'tickRate': 0,
									'animationLockout': 0,
									'lastCast': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0,
									'debuffs': [],
									'abilityLevel': 0,
									'image': 'autoAttack'
								},
								'ability1': {
									'name': '',
									'initialDamage': 0,
									'damageFormula': undefined,
								 	'damageType': undefined,
									'coefficients': [],
									'effects': [],
									'formulas': [],
									'sanitizedTooltip': '',
									'crittable': false,
									'tickDamage': 0,
									'tickDuration': 0,
									'tickRate': 0,
									'animationLockout': 0,
									'lastCast': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'baseLockout': 0,
									'stunDuration': 0,
									'debuffs': [],
									'abilityLevel': 0
								},
								'ability2': {
									'name': '',
									'initialDamage': 0,
									'damageFormula': undefined,
								 	'damageType': undefined,
									'crittable': false,
									'coefficients': [],
									'effects': [],
									'formulas': [],
									'sanitizedTooltip': '',
									'tickDamage': 0,
									'tickDuration': 0,
									'tickRate': 0,
									'animationLockout': 0,
									'lastCast': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'baseLockout': 0,
									'stunDuration': 0,
									'debuffs': [],
									'abilityLevel': 0
								},
								'ability3': {
									'name': '',
									'initialDamage': 0,
									'damageFormula': undefined,
								 	'damageType': undefined,
									'crittable': false,
									'coefficients': [],
									'effects': [],
									'formulas': [],
									'sanitizedTooltip': '',
									'tickDamage': 0,
									'tickDuration': 0,
									'tickRate': 0,
									'animationLockout': 0,
									'lastCast': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'baseLockout': 0,
									'stunDuration': 0,
									'debuffs': [],
									'abilityLevel': 0
								},
								'ability4': {
									'name': '',
									'initialDamage': 0,
									'damageFormula': undefined,
								 	'damageType': undefined,
									'crittable': false,
									'coefficients': [],
									'effects': [],
									'formulas': [],
									'sanitizedTooltip': '',
									'tickDamage': 0,
									'tickDuration': 0,
									'tickRate': 0,
									'animationLockout': 0,
									'baseLockout': 0,
									'lastCast': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0,
									'debuffs': [],
									'abilityLevel': 0
								},		
							},
			}
		}

		function addActions(champion, base) {
			angular.extend(champion.actions, createActionList(champion, base));
		}

		// TODO: add abilities and actionable items check
		function createActionList(champion, base) {
				var actions = champion.actions;
				angular.extend(actions.autoAttack, getAbilityAttributes(champion, champion.actions.autoAttack, true));
				angular.forEach(base.abilities, function(ability, idx) {
					
					// angular.extend(champion.actions)
					angular.extend(actions, createAction(champion, ability, idx + 1))
				});
				return actions;
		}

		function createAction(champion, ability, index) {
			result = {};
			actionName = 'ability' + index.toString();
			action = 	{
									'name': ability.name,
									'crittable': false, // make function to check spell specifically against enumerated list
									'coefficients': ability.coefficients,
									'effects': ability.effect,
									'formulas': ability.formulas,
									'damageFormula': ability.damageFormula,
									'damageType': ability.damageType,
									'initialDamage': 0,
									'tickDamage': 0,
									'tickDuration': 0,
									'tickRate': 0,
									'animationLockout': 0,
									'lastCast': 0,
									'nextAvailable': 0,
									'abilityLockout': 0,
									'stunDuration': 0,
									'debuffs': [],
									'baseLockout': ability.cooldown[2],
									'abilityLevel': 3,
									'image': ability.image.full
								}
			result[actionName] = getAbilityAttributes(champion, action, true);
			return result;
		}

		function getAbilityAttributes(champion, ability, initialSetup) {
			var damage = calculateAbilityDamage(champion.stats, ability);
			var abilityLockout = calculateAbilityLockout(champion.stats, ability);

			var lastCast = initialSetup ? 0 : ability.lastCast;
			var nextAvailable = initialSetup ? 0 : calculateAbilityNextAvailability(ability, abilityLockout);

			// TODO: implement per champion ability and auto attack animation times
			var animationLockout = calculateAnimationLockout(champion, ability);
			var stunDuration = 0;
			
			// return ability
			return {
								'name': ability.name,
								'crittable': ability.crittable,
								'coefficients': ability.coefficients,
								'effects': ability.effects,
								'formulas': ability.formulas,
								'damageFormula': ability.damageFormula,
								'damageType': ability.damageType,
								'initialDamage': damage,
								'tickDamage': 0,
								'tickDuration': 0,
								'tickRate': 0,
								'animationLockout': animationLockout,
								'lastCast': lastCast,
								'nextAvailable': nextAvailable,
								'abilityLockout': abilityLockout,
								'baseLockout': ability.baseLockout,
								'stunDuration': stunDuration, // roll into debuffs
								'debuffs': [],
								'abilityLevel': 3, // change to user defined value
								'image': ability.image
							};
		}
							

		function calculateAbilityNextAvailability(ability, lockout) {
			ability.nextAvailable = currentTime + lockout;
		}

		// TODO: get information on specific abilities and champions for accurate
		// animation lockout times (assumed to scale based on attack speed for autoAttacks)
		function calculateAnimationLockout(champion, ability) {
			return 2;
		}

		// TODO: add check for effect bonuses and champion passive bonuses
		// Setup to use functions for finding the stat and coefficient to use for base damage
		// CURRENTLY ONLY CALCULATES AUTOATTACKS with no modifiers by always adding
		// the crit damage based on % of crit chance
		function calculateAbilityDamage(stats, ability) {
			// TODO: add 
			var baseDamage = 0;
			if(ability.name == 'autoAttack') {
				var roll = Math.floor(Math.random() * (101 - 1) + 1);
				baseDamage = stats.baseAttackdamage + stats.bonusAttackdamage;
				var critDamage = (stats.baseAttackdamage + stats.bonusAttackdamage) * (stats.baseCritdamage + stats.bonusCritdamage);
				var critChance = stats.baseCrit + stats.bonusCrit;
				if (roll > (critChance * 100)) {
					critDamage = 0;
				}
			} else {
				if (ability.damageFormula !== null) {
					baseDamage = applyFormula.call(ability, stats, getIndexFromString("formula".length, ability.damageFormula));
				}
			}
			return ability.crittable ? baseDamage + critDamage : baseDamage;	
		}

		function applyFormula(championStats, formulaIndex) {
			var elements = [];
			var baseDamage = 0;
			var that = this;
			this.formulas[formulaIndex] ? elements = this.formulas[formulaIndex].split('+') : undefined;
			angular.forEach(elements, function(element) {
				baseDamage += getFormulaElementValue(that, championStats, element);
			});
			return baseDamage;
		}

		function getFormulaElementValue(ability, championStats, element) {
			var value = 0;
			var coefficient = undefined;
			var elementType = getElementTypeFromString(element);
			if(elementType == 'effects') {
				value = getEffectValue(ability.effects, [getIndexFromString(1, element)], ability.abilityLevel )
			} else {
				coefficient = _.find(ability.coefficients, function(coefficient) {
					return coefficient.key == element;
				})
				if (coefficient) {
					value = handleCoefficientCalculations(coefficient, championStats, ability.abilityLevel)
				} else {
					value = 0;
				}
			}
			return value;
		}

		// TODO: Add the unique scenario handling, handle Karma, change Heimerdinger enumeration
		function handleCoefficientCalculations(coefficient, championStats, abilityLevel) {
			var value = 0;
			switch (coefficient['link']) {
			  case 'spelldamage':
			  	value = coefficient['coeff'][0] * championStats.bonusAbilitypower;
			    break;
			  case 'attackdamage':
			  	value = coefficient['coeff'][0] * (championStats.baseAttackdamage + championStats.bonusAttackdamage);
				  break;
			  case 'bonusattackdamage':
				  value = coefficient['coeff'][0] * championStats.bonusAttackdamage;
			    break;
			  default:
				  break;
			}
			return value
		}

		function getEffectValue(effects, effectIndex, abilityLevel) {
			if(effects[effectIndex].length >= abilityLevel) {
				return effects[effectIndex][abilityLevel - 1];
			}
			return undefined;
		}

		function getElementTypeFromString(text) {
			var elementType = undefined;
			switch (text[0]) {
			  case 'a':
			  	elementType = 'coefficients';
			    break;
			  case 'e':
			  	elementType = 'effects';
				  break;
			  case 'f':
				  elementType = 'coefficients';
			    break;
			  default:
				  break;
			}
			return elementType;
		}

		function getIndexFromString(startIdx, text) {
			return parseInt(text.substr(startIdx));
		}

		// TODO: Setup to use function to find delay based on ability
		// CURRENTLY ONLY SETS A DELAY FOR AUTO ATTACKS
		function calculateAbilityLockout(stats, ability) {
			delay = 0;
			if (ability.name == 'autoAttack') {
				delay = 1.0 / stats.attackspeed;
			} else {
				delay = ability.baseLockout * (1 - stats.bonusCooldownreduction);
			}
			return delay * 10;	
		}

		function calculatePercentDelayRemaining(ability) {
			var remaining = (ability.nextAvailable - currentTime) / (ability.nextAvailable - ability.lastCast) * 1.0;
			return remaining <= 0 ? 0 : remaining; 
		}

		function calculateAbilityNextAvailable(ability, newLockout) {
			return currentTime + newLockout * calculatePercentDelayRemaining(ability);
		}

		function addChampionStats(champion, base, level) {
			angular.extend(champion.stats, getChampionStats(base, level));
		}

		function addChampionId(champion, id) {
			angular.extend(champion, { 'id' : id });
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
			return { 'effectiveArmor' : calculateEffectiveResist(armor, armorReduction, percentArmorReduction, armorPenetration, percentArmorPenetration) };
		}

		function getEffectiveSpellblock(spellblock, spellblockReduction, percentSpellblockReduction, spellblockPenetration, percentSpellblockPenetration) {
			return { 'effectiveSpellblock' : calculateEffectiveResist(spellblock, spellblockReduction, percentSpellblockReduction, spellblockPenetration, percentSpellblockPenetration) };
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

		// formula calculated to get the stat change for a specific level. Wish riot released this info directly.
		function getPerLevelChange(perLevelChange, level) {
			return 0.65 * perLevelChange * (level - 1) + 0.035 * perLevelChange * (1.5 + (0.5 * level - 0.5)) * (level - 1);
		}

		// Calculate the base attack speed for champion in attacks/second
		// .625 is base for all champions without offset, subject to Riot's will
		// TODO: Add .625 to constant for ease of change and allowing for usage
		// 			 at other parts of the code without worry
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

		// to be deleted before distribution
		// for jasmine to test private functions
		// TODO: make gulp tasks for deployment such as deleting this
		var __testOnly__ = this;
		__testOnly__.setupChampion = setupChampion;
		__testOnly__.simulateSimpleDps = simulateSimpleDps;
		__testOnly__.createEvent = createEvent;
		__testOnly__.createApplicationEvent = createApplicationEvent;
		__testOnly__.createFalloffEvent = createFalloffEvent;
		__testOnly__.useAbility = useAbility;
		__testOnly__.updateChampionAvailability = updateChampionAvailability;
		__testOnly__.nextAvailable = nextAvailable;
		__testOnly__.checkChampionAvailable = checkChampionAvailable;
		__testOnly__.bInsertEvent = bInsertEvent;
		__testOnly__.sortLowToHigh = sortLowToHigh;
		__testOnly__.findBestAvailableAbility = findBestAvailableAbility;
		__testOnly__.calculateEffectiveDamage = calculateEffectiveDamage;
		__testOnly__.calculateDamage = calculateDamage;
		__testOnly__.checkAbilityAvailability = checkAbilityAvailability;
		__testOnly__.championDefaultValues = championDefaultValues;
		__testOnly__.addActions = addActions;
		__testOnly__.createActionList = createActionList;
		__testOnly__.getAbilityAttributes = getAbilityAttributes;
		__testOnly__.calculateAnimationLockout = calculateAnimationLockout;
		__testOnly__.calculateAbilityDamage = calculateAbilityDamage;
		__testOnly__.calculateAbilityLockout = calculateAbilityLockout;
		__testOnly__.calculatePercentDelayRemaining = calculatePercentDelayRemaining;
		__testOnly__.calculateAbilityNextAvailable = calculateAbilityNextAvailable;
		__testOnly__.addChampionStats = addChampionStats;
		__testOnly__.getChampionStats = getChampionStats;
		__testOnly__.addItemStats = addItemStats;
		__testOnly__.updateChampionAttackSpeed = updateChampionAttackSpeed;
		__testOnly__.addStatsToChampion = addStatsToChampion;
		__testOnly__.getItemStats = getItemStats;
		__testOnly__.calculateEffectiveResist = calculateEffectiveResist;
		__testOnly__.getEffectiveSpellblock = getEffectiveSpellblock;
		__testOnly__.getHp = getHp;
		__testOnly__.getMp = getMp;
		__testOnly__.getMovespeed = getMovespeed;
		__testOnly__.getArmor = getArmor;
		__testOnly__.getSpellblock = getSpellblock;
		__testOnly__.getAttackrange = getAttackrange;
		__testOnly__.getHpregen = getHpregen;
		__testOnly__.getMpregen = getMpregen;
		__testOnly__.getCrit = getCrit;
		__testOnly__.getCritdamage = getCritdamage;
		__testOnly__.getAttackdamage = getAttackdamage;
		__testOnly__.getBonusAttackspeed = getBonusAttackspeed;
		__testOnly__.getAttackspeed = getAttackspeed;
		__testOnly__.getStatAfterGrowth = getStatAfterGrowth;
		__testOnly__.getPerLevelChange = getPerLevelChange;
		__testOnly__.getBaseAttackspeed = getBaseAttackspeed;
		__testOnly__.getModifiedAttackSpeed = getModifiedAttackSpeed;



	}]);
