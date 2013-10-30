class LumDefGameInfo extends GameInfo
        config(LumDef);

DefaultProperties
{
        DefaultPawnClass=class'LumDefGame.LumDefPawn'
        //Definimos nosso proprio tipo de HUD
        HUDType=class'LumDefGame.LumDefHUD'
        //Definimos nossa propria classe PlayerController
        PlayerControllerClass=class'LumDefGame.LumDefPlayerController'
        bDelayedStart=False
}