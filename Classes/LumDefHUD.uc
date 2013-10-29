class LumDefHUD extends HUD;

//Armazena a textura que representa o cursor na tela
var const Texture2D CursorTexture;
//Armazena a cor do cursor
var const Color CursorColor;

//Sobrescrevemos o evento PostRender() da classe mae que atualiza o HUD a cada Tick
event PostRender()
{
        //Variavel pronta para fazer cast a LumDefPlayerInput
        local LumDefPlayerInput LumDefPlayerInput;
        
        //Com este teste aseguramos que temos um PlayerOwner e CursorTexture validos
        if (PlayerOwner != None && CursorTexture != None)
        {
                //Fazemos o cast de LumDefPlayerInput
                LumDefPlayerInput = LumDefPlayerInput(PlayerOwner.PlayerInput);
                
                //Com este teste garantimos que temos uma instacia valida de LumDefPlayerInput
                if (LumDefPlayerInput != None)
                {
                        //Definimos a posicao do canvas para a posicao do cursor do mouse
                        Canvas.SetPos(LumDefPlayerInput.MousePosition.X, LumDefPlayerInput.MousePosition.Y);
                        //Definimos a cor do cursor
                        Canvas.DrawColor = CursorColor;
                        //Finalmente pintamos a textura do cursor na tela
                        Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, True);
                }
        }
        
        //Executamos o evento PostRender da classe mae
        Super.PostRender();
}

DefaultProperties
{
        //Defimos por padrao a cor do cursor
        CursorColor=(R=255, G=255, B=255, A=255)
        //Definimos por padrao a textura do cursor
        CursorTexture=Texture2D'LumDefContent.Textures.cursor_png'
}