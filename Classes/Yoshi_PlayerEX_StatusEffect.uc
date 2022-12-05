//EpicYoshiMaster

class Yoshi_PlayerEX_StatusEffect extends Hat_StatusEffect;
var Name effect;
var float intensity;


function bool Update(float delta) {
	
	if (!Super.Update(delta)) {
		return false;
	}
	
	if(Hat_Player(Owner).IsLocallyControlled()) {
		Hat_Player(Owner).SetMaterialScalarValue(effect, 0.0);
		switch(class'GameMod'.static.GetConfigValue(class'Yoshi_PlayerEX', 'player_effect')) {			
			case 0: effect = ''; break;		
			case 1: effect = 'RainbowOverlay'; break;
			case 2: effect = 'MudVertexShader'; break;
			case 3: effect = 'NoShading'; break;
			case 4: effect = 'CharacterInWater'; break;
			case 5: effect = 'ColdWater'; break;
			case 6: effect = 'Goop'; break;
			case 7: effect = 'Stone'; break;
			case 8: effect = 'FireBurn'; break;
			case 9: effect = 'Ashed'; break;
			case 10: effect = 'Charge'; break;
			case 11: effect = 'TimeStop'; break;
			case 12: effect = 'HurtScale'; break;
			default: effect = 'RainbowOverlay'; break;
			
		}

		switch(class'GameMod'.static.GetConfigValue(class'Yoshi_PlayerEX', 'effect_intensity')) {
			case 0: intensity = 0.0; break;
			case 1: intensity = 0.25; break;
			case 2: intensity = 0.5; break;
			case 3: intensity = 1.0; break;
			case 4: intensity = 2.0; break;
			case 5: intensity = 3.0; break;
			case 6: intensity = 4.0; break;
			case 7: intensity = 5.0; break;
			case 8: intensity = 10.0; break;
			case 9: intensity = 100.0; break;	
			//Yes it was ridiculous
			/*case 10: intensity = 1000.0; break;
			case 11: intensity = 10000.0; break;
			case 12: intensity = 1000000.0; break;
			case 13: intensity = 999999999999999999999999999999999.9; break;*/
			
			default: intensity = 1.0; break;
		}
		//Intensity override. MudVertexShader at 100 is possibly seizure inducing
		if(effect == 'MudVertexShader' && intensity == 100.0) {
			intensity = 15.0;
		}
		
		if(effect == '') return true;
		Hat_Player(Owner).SetMaterialScalarValue(effect, intensity);
	}
	else {
		Hat_Player(Owner).SetMaterialScalarValue('RainbowOverlay', 0.0);
	}

	return true;
}

simulated function OnRemoved(Actor a) {
	local Hat_Player ply;

	ply = Hat_Player(a);
	if(ply.IsLocallyControlled()) {
		RefreshAllPlayerEffects(ply);
	}
	Super.OnRemoved(a);
}

function RefreshAllPlayerEffects(Hat_Player ply) {
	ply.SetMaterialScalarValue('RainbowOverlay', 0.0);
	ply.SetMaterialScalarValue('MudVertexShader', 0.0);
	ply.SetMaterialScalarValue('NoShading', 0.0);
	ply.SetMaterialScalarValue('CharacterInWater', 0.0);
	ply.SetMaterialScalarValue('ColdWater', 0.0);
	ply.SetMaterialScalarValue('Goop', 0.0);
	ply.SetMaterialScalarValue('Stone', 0.0);
	ply.SetMaterialScalarValue('FireBurn', 0.0);
	ply.SetMaterialScalarValue('Ashed', 0.0);
	ply.SetMaterialScalarValue('Charge', 0.0);
	ply.SetMaterialScalarValue('TimeStop', 0.0);
	ply.SetMaterialScalarValue('HurtScale', 0.0);
}



defaultproperties
{
	Duration = -1;
}

