class LumDefGameInfo extends SimpleGame DependsOn(SaveSystemString)
        config(LumDef);

//Create inventory
var array< class <Inventory> > DefaultInventory;

//SaveSystem and CharacterData vars
var SaveSystemString MySaveSystemString;
var SCharacterData CharacterData;

// Variable which references the default pawn archetype stored within a package
var() const archetype Pawn DefaultPawnArchetype;
// Variable which references the default weapon archetype stored within a package
var() const archetype Weapon DefaultWeaponArchetype;

simulated function PostBeginPlay()
{
        Super.PostBeginPlay();
        MySaveSystemString = new class'SaveSystemString';
}


// This function have the keyword exec, telling that we can call if from console commands
exec function SaveMyCharacter(string FileName)
{
    // Calling the function inside our save system, and passing our character to be saved
    MySaveSystemString.SaveTheCharacter(FileName, CharacterData);
}

// Another exec function, now to load
exec function LoadMyCharacter(string FileName)
{
    // Calling the function inside our save system, and passing our character that will hold the loaded data
    MySaveSystemString.LoadTheCharacter(FileName, CharacterData);
}

event AddDefaultInventory(Pawn P)
{
	local LumDefInventoryManager LumDefInventoryManager;

	Super.AddDefaultInventory(P);

	// Ensure that we have a valid default weapon archetype
	if (DefaultWeaponArchetype != None)
	{
		// Get the inventory manager
		LumDefInventoryManager = LumDefInventoryManager(P.InvManager);
		if (LumDefInventoryManager != None)
		{
			// Create the inventory from the archetype
			LumDefInventoryManager.CreateInventoryArchetype(DefaultWeaponArchetype, false);
		}
	}
}


// Function that is executed after each kill
function ScoreKill(Controller Killer, Controller Other)
{
	local LumDefPlayerController PC;

	super.ScoreKill(Killer, Other);

	// Cast to the custom HDPlayerController class
	PC = LumDefPlayerController(Killer);
	// Give XP through our custom function to our PlayerController, change 100 to whatever amount you want
	PC.GiveXP(100);
}

DefaultProperties
{
        DefaultPawnClass=class'LumDefGame.LumDefPawn'
        //Definimos nosso proprio tipo de HUD
        HUDType=class'LumDefGame.LumDefHUD'
        //Definimos nossa propria classe PlayerController
        PlayerControllerClass=class'LumDefGame.LumDefPlayerController'
        bDelayedStart=False
	bRestartLevel=False
	bUseSeamlessTravel=true
}