class LumDefGameInfo extends GameInfo
        config(LumDef);
        
DefaultProperties
{
        //Definimos nosso proprio tipo de HUD
        HUDType=class'LumDefGame.LumDefHUD'
        //Definimos nossa propria classe PlayerController
        PlayerControllerClass=class'LumDefGame.LumDefPlayerController'
}