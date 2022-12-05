//EpicYoshiMaster
//Shoutouts to yoshimo for helping me with learning how to script status effects
//Online Support is painful but I survived.

class Yoshi_PlayerEX extends GameMod;

var config int player_effect;
var config int effect_intensity;
var config int isFirstRun;

//Determines if we receive Online Party Commands (We still send commands)
var config int NoOnlineSupport;

const debug = false;

event OnModLoaded() {	
	if(isFirstRun == 0) {
		OnFirstRun();
	}

	if(`GameManager.GetCurrentMapFilename() == `GameManager.TitleScreenMapName) {
		return;
	}
	
	HookActorSpawn(class'Hat_Player', 'Hat_Player');
}

event OnModUnloaded() {
	local Hat_Player ply;

	foreach DynamicActors(class'Hat_Player', ply) {
		ply.RemoveStatusEffect(class'Yoshi_PlayerEX_StatusEffect');
		//Removing the Status Effect will only stop updating the effect, so we have to take it out entirely.
		ply.SetMaterialScalarValue('RainbowOverlay', 0.0);
	}
	ResetAllGhostPartyPlayerEX();
}

event OnHookedActorSpawn(Object NewActor, Name Identifier) {
	if(Identifier == 'Hat_Player') {
        Hat_Player(NewActor).GiveStatusEffect(class'Yoshi_PlayerEX_StatusEffect');
		SetTimer(3.0, false, NameOf(SendNewPlayerEXPackage));
    }
	
}

event OnConfigChanged(Name ConfigName) {
	//SpecialCase 1 tells other players we need to refresh our Scalar Values for a new effect
	if(ConfigName == 'player_effect') {
		Print("Player Effect Changed");
		SendPlayerEXPackage(1);
	}

	if(ConfigName == 'effect_intensity') {
		Print("Effect Intensity Changed");
		SendPlayerEXPackage();
	}
	
	if(ConfigName == 'NoOnlineSupport') {
		if(NoOnlineSupport == 1) {
			ResetAllGhostPartyPlayerEX();
		}
		if(NoOnlineSupport == 0) {
			//SpecialCase 2 tells other players we need their states
			Print("Requesting Player States");
			SendPlayerEXPackage(2);
		}
	}
}

function OnLoadoutChanged(PlayerController Controller, Object Loadout, Object BackpackItem) {
	Print("Loadout Changed");
	SendPlayerEXPackage();
}

//Used by the initial spawn of a player.
function SendNewPlayerEXPackage() {
	local String s;
	local Hat_Player ply;

	ply = Hat_Player(class'Engine'.static.GetEngine().GamePlayers[0].Actor.Pawn);

	s $= player_effect;
	s $= "+" $ effect_intensity;

	Print("Sending New Player EX Package with Request");
	SendOnlinePartyCommand(s, class'YoshiPrivate_OnlineParty_PlayerEX'.const.PlayerEXNewPlayer, ply);
}

//SpecialCase gives additional information
function SendPlayerEXPackage(optional int SpecialCase, optional Hat_GhostPartyPlayerStateBase Receiver) {
	local String s;
	local Hat_Player ply;

	ply = Hat_Player(class'Engine'.static.GetEngine().GamePlayers[0].Actor.Pawn);

	s $= player_effect;
	s $= "+" $ effect_intensity;
	if(SpecialCase > 0) s $= "+" $ SpecialCase;

	Print("Sending Player EX Package with Special Case " $ SpecialCase);
	SendOnlinePartyCommand(s, class'YoshiPrivate_OnlineParty_PlayerEX'.const.PlayerEXPlayerChange, ply, Receiver);
}

function ResetAllGhostPartyPlayerEX() {
	local Hat_GhostPartyPlayer GPply;

	foreach DynamicActors(class'Hat_GhostPartyPlayer', GPply) {
		if(GPPly.isA('Hat_GhostPartyPlayer') || GPPly.isA('Arg_GhostPartyPlayer')) {
			RefreshAllPlayerEffects(GPPly);
		}
	}
}

event OnOnlinePartyCommand(string Command, Name CommandChannel, Hat_GhostPartyPlayerStateBase Sender) {
	local Hat_GhostPartyPlayer GhostPlayer;

	if(NoOnlineSupport == 1) return;
	GhostPlayer = Hat_GhostPartyPlayer(Sender.GhostActor);
	if (GhostPlayer == None) return;

	//Source file not included for privacy of CommandChannels
	if(CommandChannel == class'YoshiPrivate_OnlineParty_PlayerEX'.const.PlayerEXPlayerChange) {
		SetOnlinePlayerEX(GhostPlayer, Command, Sender);
	}

	//New Players will send their information out, but they also need to receive it back from existing players.
	if(CommandChannel == class'YoshiPrivate_OnlineParty_PlayerEX'.const.PlayerEXNewPlayer) {
		SetOnlinePlayerEX(GhostPlayer, Command, Sender);
		Print("Sending Requested Package for a New Player");
		SendPlayerEXPackage(,Sender);
	}
}

function SetOnlinePlayerEX(Hat_GhostPartyPlayer GPPly, String Payload, optional Hat_GhostPartyPlayerStateBase Sender) {
	local Array<String> arr;
	local Name ActualPlayerEffect;
	local float ActualEffectIntensity;

	arr = SplitString(Payload, "+");

	if(arr.Length > 0) ActualPlayerEffect = GetActualPlayerEffect(int(arr[0]));
	if(arr.Length > 1) ActualEffectIntensity = GetActualEffectIntensity(int(arr[1]), ActualPlayerEffect);
	if(arr.Length > 2) {
		if(int(arr[2]) == 1) {
			Print("Refreshing Ghost Party Player Effects");
			RefreshAllPlayerEffects(GPPly);
		}
		if(int(arr[2]) == 2) {
			Print("Sending Requested Package");
			SendPlayerEXPackage(,Sender);
		}
	}

	Print("Set Ghost Party Player on Settings: " $ ActualPlayerEffect $ " " $ ActualEffectIntensity);
	GPPly.SetMaterialScalarValue(ActualPlayerEffect, ActualEffectIntensity);
}

function RefreshAllPlayerEffects(Hat_GhostPartyPlayer GPPly) {
	GPPly.SetMaterialScalarValue('RainbowOverlay', 0.0);
	GPPly.SetMaterialScalarValue('MudVertexShader', 0.0);
	GPPly.SetMaterialScalarValue('NoShading', 0.0);
	GPPly.SetMaterialScalarValue('CharacterInWater', 0.0);
	GPPly.SetMaterialScalarValue('ColdWater', 0.0);
	GPPly.SetMaterialScalarValue('Goop', 0.0);
	GPPly.SetMaterialScalarValue('Stone', 0.0);
	GPPly.SetMaterialScalarValue('FireBurn', 0.0);
	GPPly.SetMaterialScalarValue('Ashed', 0.0);
	GPPly.SetMaterialScalarValue('Charge', 0.0);
	GPPly.SetMaterialScalarValue('TimeStop', 0.0);
	GPPly.SetMaterialScalarValue('HurtScale', 0.0);
}

function Name GetActualPlayerEffect(int Selection) {
	local Name effect;

	switch(Selection) {			
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

	return effect;
}

function float GetActualEffectIntensity(int Selection, Name effect) {
	local float TrueIntensity;

	switch(Selection) {
		case 0: TrueIntensity = 0.0; break;
		case 1: TrueIntensity = 0.25; break;
		case 2:	TrueIntensity = 0.5; break;
		case 3: TrueIntensity = 1.0; break;
		case 4: TrueIntensity = 2.0; break;
		case 5: TrueIntensity = 3.0; break;
		case 6: TrueIntensity = 4.0; break;
		case 7: TrueIntensity = 5.0; break;
		case 8: TrueIntensity = 10.0; break;
		case 9: TrueIntensity = 100.0; break;
		default: TrueIntensity = 1.0; break;
	}

	//Intensity override. MudVertexShader at 100 is possibly seizure inducing
	if(effect == 'MudVertexShader' && TrueIntensity >= 99.9) {
		TrueIntensity = 15.0;
	}

	return TrueIntensity;
}

function OnFirstRun() {
	//Because configuration options don't immediately select the default option, I check if the player is on their first run of the mod with a hidden config.
	//From there I simply force the config option that should be defaulted.
	
	//Prevents this running after the first launch.
	class'GameMod'.static.SaveConfigValue(class'Yoshi_PlayerEX', 'isFirstRun', 1);

	//Force Default Effect Option
	class'GameMod'.static.SaveConfigValue(class'Yoshi_PlayerEX', 'player_effect', 1);
	
	//Force Default Config Option
	class'GameMod'.static.SaveConfigValue(class'Yoshi_PlayerEX', 'effect_intensity', 3);

	//Force Online Party Active
	class'GameMod'.static.SaveConfigValue(class'Yoshi_PlayerEX', 'UseOnlineSupport', 0);
}

static function Print(string s)
{
	if(debug) {
		class'WorldInfo'.static.GetWorldInfo().Game.Broadcast(class'WorldInfo'.static.GetWorldInfo(), s);
	}
}