describe('Service: championDpsCalculator', function(){
	var mockChampions,
			mockItems,
			ChampionDpsCalculator;

	beforeEach(function(){
		mockChampions = {
			name:'bob', value: 10
		};

		mockItems = { 
			getItemStats: function(item) {
				return item ? item.stats : {};
			}
		};
		module('services.championDpsCalculator', function($provide){
			$provide.value('ChampionsModel', mockChampions);
			$provide.value('ItemsModel', mockItems);
		});

	});

	beforeEach(inject(function(_ChampionDpsCalculator_){
		ChampionDpsCalculator = _ChampionDpsCalculator_;
	}));



	it('expect ChampionDpsCalculator to be injected successfully', function(){
		expect(ChampionDpsCalculator).toBeDefined();

	});

	describe('Function: getItemStats', function(){
		beforeEach(function(){
			spyOn(ChampionDpsCalculator, 'getItemStats').and.callThrough();
		});
		it('should return the bonus stats if provided a valid item', function(){
			var someItems = [{'stats': {"bonusArmor": 5}}];
			expect(ChampionDpsCalculator.getItemStats(someItems)).toEqual({"bonusArmor": 5}); //return item ? item.stats : {};
		});

		it('should return the bonus stats if provided a multiple valid items', function(){
			var someItems = [{'stats': {"bonusArmor": 5}}, {'stats': {"bonusArmor": 10, 'bonusMovespeed': 25}}];
			expect(ChampionDpsCalculator.getItemStats(someItems)).toEqual({"bonusArmor": 15, 'bonusMovespeed': 25}); //return item ? item.stats : {};
		});

		it('should return the bonus stats if provided valid items and undefined items', function(){
			var someItems = [{'name': 'cutlass', 'stats': {"bonusArmor": 5}}, {'name': 'boots', 'stats': {"bonusArmor": 10, 'bonusMovespeed': 25}}, undefined];
			expect(ChampionDpsCalculator.getItemStats(someItems)).toEqual({"bonusArmor": 15, 'bonusMovespeed': 25}); //return item ? item.stats : {};
		});

		it('should return an empty object if provided an undefined item', function(){
			var someItem = undefined;
			expect(ChampionDpsCalculator.getItemStats(someItem)).toEqual({}); //return item ? item.stats : {};
		});

	});

	
});
