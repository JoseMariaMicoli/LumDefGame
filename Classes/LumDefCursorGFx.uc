class LumDefCursorGFx extends GFxMoviePlayer;

//variavel pronta para fazer cast de LumDefHUD
var LumDefHUD LumDefHUD;

//Sobrescrevemos a funcao Init da classe mae que inicia o ScaleForm Movie
function Init(optional LocalPlayer LocalPlayer)
{
        //Executamos a funcao Init da classe mae para iniciar o ScaleForm Movie
        Super.Init(LocalPlayer);
        
        Start();
        Advance(0);
}

//Aqui é onde a magica de passar as cordenadas do cursor pegas no ActionScript para o UnrealScript acontece
event UpdateMousePosition(float X, float Y)
{
        //variavel pronta para fazer cast de LumDefPlayerInput
        local LumDefPlayerInput LumDefPlayerInput;
        
        //Garantimos que temos um HUD valido e que o mesmo tem um PlayerController valido(PlayerOwner)
        if (LumDefHUD != None && LumDefHUD.PlayerOwner != None)
        {
                //Definimos o valor de LumDefPlayerInput para uma instancia do mesmo que faz referencia a PlayerInput em PlayerControler
                LumDefPlayerInput = LumDefPlayerInput(LumDefHUD.PlayerOwner.PlayerInput);
                
                //Testamos se tudo acima foi setado corretamente
                if (LumDefPlayerInput != None)
                {
                        //Passamos as cordenadas do mouse do ActionScript para o UnrealScript
                        LumDefPlayerInput.SetMousePosition(X, Y);
                }
        }
}

DefaultProperties
{
        bDisplayWithHudOff=false
        TimingMode=TM_Game
        MovieInfo=SwfMovie'LumDefFlashContent.LumDefCursor'
        bPauseGameWhileActive=false
}