class LumDefHUD extends HUD;

//Armazena a textura que representa o cursor na tela
var const Texture2D CursorTexture;
//Armazena a cor do cursor
var const Color CursorColor;
//Estamos usando ScaleForm?
var bool UsingScaleForm;
//variavel pronta para cast de LumDefCursorGFx
var LumDefCursorGFx LumDefCursorGFx;

simulated event PostBeginPlay()
{
        //Executamos o mesmo evento da classe mae
        Super.PostBeginPlay();

        //Testamos se UsingScaleForm retorna True
        if (UsingScaleForm)
        {
                //Testamos se temos uma instancia valida de LumDefCursorGFx
                if (LumDefCursorGFx != None)
                {
                        LumDefCursorGFx.LumDefHUD = Self;
                        LumDefCursorGFx.SetTimingMode(TM_Game);
                        
                        //Executamos a funcao Init de LumDefCursorGFx para iniciar o ScaleForm
                        LumDefCursorGFx.Init(class'Engine'.static.GetEngine().GamePlayers[LumDefCursorGFx.LocalPlayerOwnerIndex]);
                }
        }
}

//evento que é chamado quando o HUD é destruido e se encarrega de fechar o ScaleForm Movie
simulated event Destroyed()
{
        Super.Destroyed();

        if (LumDefCursorGFx != None)
        {
                LumDefCursorGFx.Close(True);
                LumDefCursorGFx = None;
        }
}

//Esta funcao se encarrega de ver se o tamanho da tela mundou e passar essas mudanças para o ScaleForm
function PreCalcValues()
{
        Super.PreCalcValues();
        
        if (LumDefCursorGFx != None)
        {
                LumDefCursorGFx.SetViewport(0, 0, SizeX, SizeY);
                LumDefCursorGFx.SetViewScaleMode(SM_NoScale);
                LumDefCursorGFx.SetAlignment(Align_TopLeft);
        }
}

//Sobrescrevemos o evento PostRender() da classe mae que atualiza o HUD a cada Tick
event PostRender()
{
        //Variavel pronta para fazer cast a LumDefPlayerInput
        local LumDefPlayerInput LumDefPlayerInput;

        //Aseguramos que nao usamos scaleform e que temos uma textura valida para o cursor
        if (!UsingScaleForm && CursorTexture != None)
        {
                //Aseguramos que temos um PlayerOwner valido
                if (PlayerOwner != None)
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
        UsingScaleForm=True;
}