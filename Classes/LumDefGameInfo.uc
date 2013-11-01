class LumDefGameInfo extends GameInfo
        config(LumDef);

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