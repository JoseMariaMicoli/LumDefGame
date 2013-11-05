class LumDefGameInfo extends GameInfo DependsOn(SaveSystemString)
        config(LumDef);

//Create inventory
var array< class <Inventory> > DefaultInventory;

//SaveSystem and CharacterData vars
var SaveSystemString MySaveSystemString;
var SCharacterData CharacterData;


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

//Add default items to inventory of PlayerPawn
function AddDefaultInventory( pawn PlayerPawn )
{
    if(PlayerPawn.IsHumanControlled() )
    {
        PlayerPawn.CreateInventory(class'LumDefWeaponTeste',false);
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